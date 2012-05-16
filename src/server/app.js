/*
 * app.js
 * 
 * Server part of map-rendering-test application
 */

/*
 * Reads settings
 */
var Properties = require("node-properties");
var propStore = (new Properties()).load("./target/classes/app.properties",
		function(err) {
			if (err != null) {
				console.log(err);
				return;
			}

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
	app
			.get(
					'/index.html',
					function(req, res) {
						res.render("index.html", {
							props : props,
							layout : "layout.html"
						});
						
					}
				);

	/*
	 * Database query mounted on /geojson
	 */
	app
			.get(
					'/geojson',
					function(req, res) {

						function resSend(jsonOutput) {
							// Allowing x-domain request
							res.header("Access-Control-Allow-Origin", "*");
							res.header("Access-Control-Allow-Credentials", "true");
							res.header("Access-Control-Allow-Methods", "OPTIONS, GET, POST");
							res
									.header(
											"Access-Control-Allow-Headers",
											"Content-Type, Depth, User-Agent, X-File-Size, X-Requested-With, If-Modified-Since, X-File-Name, Cache-Control");

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

						console.log("Request: " + req); // XXX
						var host = req.param("host", props.get("host"));
						var db = req.param("db", props.get("db.name"));
						var port = req.param("port", props.get("db.port"));

						var user = req.param("user", props.get("db.user"));
						var password = req.param("password", props.get("db.password"));

						var table = req.param("table", "lga11aaustgen005");
						var featureKey = req.param("key", "lga_code11");
						var featureGeom = req.param("geom", "wkb_geometry");
						var bbox = req.param("bbox", null);
						var callback = req.param("callback", null);

						// special callback for OpenLayers
						var formatOptions = req.param("format_options", null);
						if (formatOptions) {
							callback = formatOptions.substr(formatOptions.indexOf(':') + 1)
						}

						var config = {
							user : user,
							password : password,
							host : host,
							database : db,
							port : port
						};

						var whereClause = 'TRUE';
						if (bbox && bbox.length > 0) { // filtering by bbox
							var coordinates = bbox.split(",");
							whereClause = sprintf(
									"ST_Intersects(%s,ST_Envelope(ST_GeomFromText('LINESTRING(%s %s, %s %s)',4283)))",
									featureGeom, coordinates[0], coordinates[1], coordinates[2],
									coordinates[3]);
						}

						pg
								.connect(
										config,
										function(err, client) {
											if (err != null) {
												console.log(err);
												return;
											}

											var sqlCommand = sprintf(
													"SELECT TRIM(TRAILING ' ' FROM %s) AS %s",
													featureKey, featureKey);
											sqlCommand += sprintf(
													", ST_AsGeoJSON(1,%s,15,1) AS geom_json ",
													featureGeom);
											sqlCommand += sprintf("FROM %s WHERE %s", table,
													whereClause);

											console.log("pg.connect: " + sqlCommand);
											var query = client
													.query(
															sqlCommand,
															function(err, result) {
																if (err != null) {
																	console.log(err);
																	return;
																}
																console.log("client.query result: " + result);
																if (!result || !("rows" in result)) {
																	resSend(callback, {
																		"error" : "No result found"
																	});
																	return;
																}
																var jsonOutput = '{"type": "FeatureCollection", "crs":{"type":"name","properties":{"name":"EPSG:4283"}}, "features": [';
																for ( var i = 0; i < result.rows.length; i++) {
																	var iFeatureKey = result.rows[i][featureKey];
																	var iFeature = '{"type": "Feature", "properties":{"feature_code": "'
																			+ iFeatureKey + '"}';
																	var geomJson = result.rows[i]["geom_json"]; // this
																																							// is
																																							// returned
																																							// as
																																							// non-parsed
																																							// JSON
																																							// text,
																																							// keep
																																							// it
																																							// that
																																							// way
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
}