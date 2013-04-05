/*
 * app.js
 * 
 * Server part of map-rendering-test application
 */

var zlib = require('zlib');

/*
 * Reads settings
 */
require("properties").load("./app.properties", function(err, p) {
	if (err != null) {
		console.log(err);
		return;
	}

	var env = (typeof process.argv[2] === "undefined") ? "lan" : process.argv[2];
	p.getProperty = function(propName) {
		if (typeof p[propName] === "undefined") {
			return p[propName + "." + env];
		} else {
			return p[propName];
		}
	};

	startServer(p);
});

/*
 * Starts server
 */
function startServer(props) {

	$ = function(propName) {
		return props.getProperty(propName);
	}

	/*
	 * Loads stuff
	 */
	var express = require('express');
	var sprintf = require('sprintf').sprintf;
	var pg = require('pg');
	var jqtpl = require("jqtpl");

	var app = module.exports = express.createServer();

	// Configuration
	app.configure(function() {
		app.register(".html", jqtpl.express);
		app.set("views", "./client/views");
		app.set("view engine", "html");
		app.use(express.bodyParser());
		app.use(express.methodOverride());
		app.use(express.static("./client/resources"));
	});

	app.configure('development', function() {
		app.use(express.errorHandler({
			dumpExceptions : true,
			showStack : true
		}));
	});

	app.configure('production', function() {
		app.use(express.errorHandler());
	});

	/*
	 * Home page mounted on /index.html
	 */
	app
			.get(
					'/index.html',
					function(req, res) {
						res
								.header(
										"Content-Security-Policy",
										"script-src https://maps.google.com https://apps.aurin.org.au; style-src https://apps.aurin.org.au");

						res.render("index.html", {
							props : props,
							layout : "layout.html"
						});

					});

	/*
	 * CouchDB query
	 */
	app
			.get(
					/\/couchdb\/(.+)/,
					function(req, res) {
						var url = "http://db2.aurin.org.au:5984/geoinfo/_design/geoinfo/_spatial/_list/geojson/"
						var a = "pbcExtent?bbox=140,-35,145,-30&featuretype=point&genlevel=0;";
						
/*
/pbcExtent?bbox=140,-35,145,-30&featuretype=polygon&genlevel=0.05

{
    "type": "FeatureCollection",
    "features": [
        {
            "type": "Feature",
            "geometry": {
                "type": "MultiPolygon",
                "coordinates": [
                    [
                        [
                            [
                                145.254719392,
                                -33.6503944665
                            ],
...
                       [
                                140.367452896,
                                -34.757615859
                            ]
                        ]
                    ]
                ]
            },
            "properties": {
                "poll_id": 6769,
                "dataset": "pbc",
                "ced": [
                    "Barker"
                ]
            }
        }
    ]
}
  
 */						
					});

	/*
	 * PostGIS query 
	 */
	app
			.get(
					/\/pg\/(.+)/,
					function(req, res) {

						var config = {
							user : $("pg.user"),
							password : $("pg.password"),
							host : $("pg.host"),
							database : $("pg.db"),
							port : $("pg.port")
						};

						pg
								.connect(
										config,
										function(err, client) {
											if (err != null) {
												console.log(err);
												return;
											}

											var cor = req.param("bbox", null).split(",");
											var poly = sprintf(
													"POLYGON ((%s %s, %s %s, %s %s, %s %s, %s %s))",
													cor[0], cor[1], cor[0], cor[3], cor[2], cor[3],
													cor[2], cor[1], cor[0], cor[1]);

											var sqlCommand = sprintf(
													"SELECT ST_AsGeoJSON(%s, %s) AS geometry, ogc_fid "
															+ "FROM %s WHERE ST_Intersects(%s, ST_Envelope(ST_GeomFromText('%s', %s)))",
													$("pg.geom"), req.param("precision", "full"),
													req.params[0], $("pg.geom"), poly, $("epsg"));

											console.log("-- sqlCommand: " + sqlCommand);

											var query = client
													.query(
															sqlCommand,
															function(err, result) {
																if (err != null) {
																	console.log(err);
																	return;
																}
																if (!result || !("rows" in result)) {
																	resSend({
																		"error" : "No result found"
																	});
																	console.log("ERROR: " + "No result found");
																	return;
																}
																console.log("-- N rows " + result.rows.length);
																var jsonOutput = '{"type": "FeatureCollection", "crs":{"type":"name","properties":{"name":"EPSG:4326"}}, "features": [';
																for ( var i = 0; i < result.rows.length; i++) {
																	var iFeature = '{"type": "Feature", "properties":'
																			+ '{"FeatureCode": "'
																			+ result.rows[i].ogc_fid + '"}';
																	var geomJson = result.rows[i].geometry;
																	iFeature += ', "geometry": ' + geomJson;
																	iFeature += ' }';
																	jsonOutput += iFeature;
																	if (i < result.rows.length - 1) {
																		jsonOutput += ',';
																	}
																}
																jsonOutput += ']}';
																sendData(req, res, jsonOutput);
															});
										});

					});

	app.listen($("port"));
	console.log("Express server listening on port %d in %s mode",
			app.address().port, app.settings.env);

	/**
	 * Sends data out
	 */
	sendData = function(req, res, data) {
		res.header("Content-Type", "application/json");
		res.header("Cache-Control", "no-cache");
		if (req.param("compression", "false") === "true") {
			res.header("Content-Encoding", "gzip");
			zlib.gzip(data, function(err, zippedData) {
				if (err) {
					res.headers.statusCode = 500;
					res.send("ERRROR");
				} else {
					res.send(zippedData);
				}
			});
		} else {
			res.send(data);
		}
	}
}