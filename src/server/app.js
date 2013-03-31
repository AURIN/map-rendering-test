/*
 * app.js
 * 
 * Server part of map-rendering-test application
 */

/*
 * Reads settings
 */
var Properties = require("node-properties");

var propStore = (new Properties()).load("./src/app.properties", function(err) {
	if (err != null) {
		console.log(err);
		return;
	}

	var env = (typeof process.argv[2] === "undefined") ? "lan" : process.argv[2];
	this.getProperty = function get(propName) {
		if (typeof this.get(propName) === "undefined") {
			return this.get(propName + "." + env);
		} else {
			return this.get(propName);
		}
	};

	startServer(this);
});

/*
 * Starts server
 */
function startServer(props) {

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
		app.set("views", "src/client/views");
		app.set("view engine", "html");
		app.use(express.bodyParser());
		app.use(express.methodOverride());
		app.use(express.static("src/client/resources"));
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
	app.get('/index.html', function(req, res) {
		res.render("index.html", {
			props : props,
			layout : "layout.html"
		});

	});

	/*
	 * PostGIS query 
	 */
	app
			.get(
					"/pg",
					function(req, res) {

						function resSend(jsonOutput) {

							if (callback) {
								if (typeof jsonOutput == 'string') {
									res.send(callback + "(" + jsonOutput + ");", {
										'Content-Type' : 'text/javascript'
									});
								} else {
									res.send(callback + "(" + JSON.stringify(jsonOutput) + ");",
											{
												'Content-Type' : 'text/javascript'
											});
								}
							} else {
								res.send(jsonOutput, {
									'Content-Type' : 'application/json'
								});
							}
						}

						setHeaders(res);

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
													cor[1], cor[0], cor[3], cor[0], cor[3], cor[2],
													cor[1], cor[2], cor[1], cor[0]);

											var sqlCommand = sprintf(
													"SELECT ST_AsGeoJSON(%s) AS geometry "
															+ "FROM %s WHERE ST_Intersects(%s, ST_Envelope(ST_GeomFromText('%s', %s)))",
													$("pg.geom"), req.param("table", null), $("pg.geom"),
													poly, $("epsg"));

											console.log("XXX sqlCommand: " + sqlCommand);
											var query = client
													.query(
															sqlCommand,
															function(err, result) {
																if (err != null) {
																	console.log(err);
																	return;
																}
																if (!result || !("rows" in result)) {
																	resSend(callback, {
																		"error" : "No result found"
																	});
																	return;
																}
																var jsonOutput = '{"type": "FeatureCollection", "crs":{"type":"name","properties":{"name":"EPSG:4283"}}, "features": [';
																for ( var i = 0; i < result.rows.length; i++) {
																	var iFeatureKey = result.rows[i].code;
																	var iFeature = '{"type": "Feature", "properties":'
																			+ '{"FeatureCode": "'
																			+ iFeatureKey
																			+ '"}';
																	var geomJson = result.rows[i].geometry; // this
																	iFeature += ', "geometry": ' + geomJson;
																	iFeature += ' }';
																	jsonOutput += iFeature;
																	if (i < result.rows.length - 1) {
																		jsonOutput += ',';
																	}
																}
																jsonOutput += ']}';
																resSend(jsonOutput);
															});
										});

					});

	app.listen(2000);
	console.log("Express server listening on port %d in %s mode",
			app.address().port, app.settings.env);

	/**
	 * Sets stanrd headers
	 */
	setHeaders = function(res) {
		res.header("Content-Type", "application/json");
		res.header("Cache-Control", "no-cache");
	}

	$ = function(propName) {
		return props.getProperty(propName);
	}

}