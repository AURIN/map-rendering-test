var map = null;
var start, end;
var ngeoms = 0;
var npoints = 0;
var responseSize = 0;
var firstResponse = true;
var vecLayer = null;
var main;

var pgTables = {
	"cd" : {
		"ungeneralized" : "abs_asgc.ste06aaust",
		"generalized" : "abs_asgc.ste06gen"
	},
	"lga" : {
		"ungeneralized" : "abs_asgc.lga06aaust",
		"generalized" : "abs_asgc.lga06gen"
	},
	"pbc" : {
		"ungeneralized" : "public.pbc10aaust",
		"generalized" : "public.pbc10gen"
	},
	"sd" : {
		"ungeneralized" : "abs_asgc.sd06aaust",
		"generalized" : "abs_asgc.sd06gen"
	},
	"sla" : {
		"ungeneralized" : "abs_asgc.sla06aaust",
		"generalized" : "abs_asgc.sla06gen"
	},
	"ste" : {
		"ungeneralized" : "abs_asgc.ste06aaust",
		"generalized" : "abs_asgc.ste06gen"
	}
};

Ext.require([ "Ext.direct.*", "Ext.panel.Panel", "Ext.form.field.Text",
		"Ext.toolbar.TextItem" ]);

Ext
		.onReady(function() {

			// TODO: add compression (or lack thereof) in the headers
			var onComboChange = function() {
				if (vecLayer) {
					map.removeLayer(vecLayer);
					vecLayer = null;
				}

				if (Ext.getCmp("requestData").getValue() !== "no") {
					firstResponse = true;
					vecLayer = new OpenLayers.Layer.Vector("GeoJSON", {
						projection : new OpenLayers.Projection("EPSG:4326"),
						strategies : [ new OpenLayers.Strategy.BBOX() ],
						protocol : new OpenLayers.Protocol.HTTP({
							format : new OpenLayers.Format.GeoJSON(),
							url : buildRequestUrl(Ext.getCmp("requestType").getValue(), Ext
									.getCmp("requestData").getValue(), Ext.getCmp("requestGen")
									.getValue()),
							params : {
								includegeom : "true",
								zoom : map.zoom,
								epsg : map.displayProjection.projCode.split(":")[1]
							}
						}),
						eventListeners : {
							"loadstart" : function() {
								start = new Date();
								ngeoms = 0;
								npoints = 0;
							},
							"loadend" : function(evt) {
								if (firstResponse) {
									firstResponse = false;
								} else {
									end = new Date();
									var seconds = (end - start) / 1000;
									var throughput = Math.round(npoints / seconds, 0);
									log({
										requesttype : '"' + Ext.getCmp("requestType").getValue()
												+ '"',
										requestdata : '"' + Ext.getCmp("requestData").getValue()
												+ '"',
										generalization : '"' + Ext.getCmp("requestGen").getValue()
												+ '"',
										compression : '"' + Ext.getCmp("requestComp").getValue()
												+ '"',
										size : responseSize,
										points : npoints,
										geoms : ngeoms,
										elapsed : seconds,
										throughput : throughput
									});
								}
							},
							"featureadded" : function(elem) {
								ngeoms++;
								npoints += elem.feature.geometry.getVertices().length;
							}
						}
					});

					map.addLayers([ vecLayer ]);
				}
			};

			main = Ext
					.create(
							"Ext.panel.Panel",
							{
								layout : "fit",
								width : 600,
								height : 800,
								bodyStyle : {
									padding : "10px"
								},
								items : [
										{
											xtype : "toolbar",
											renderTo : document.body,
											layout : {
												type : "hbox",
												align : "stretch"
											},
											items : [
													{
														xtype : "combo",
														id : "requestType",
														fieldLabel : "Request",
														labelWidth : 100,
														flex : 1,
														store : new Ext.data.SimpleStore({
															data : [ [ "oldGeoInfo", "PostGIS" ],
																	[ "newGeoInfoFull", "CouchDB full prec." ],
																	[ "newGeoInfoRed", "CouchDB red. prec." ] ],
															fields : [ "value", "text" ]
														}),
														valueField : "value",
														displayField : "text",
														triggerAction : "all",
														editable : false,
														value : "oldGeoInfo",
														onChange : onComboChange
													},
													{
														xtype : "combo",
														id : "requestData",
														fieldLabel : "Data",
														labelWidth : 100,
														flex : 1,
														store : new Ext.data.SimpleStore({
															data : [ [ "no", "No feature" ],
																	[ "ste", "STE" ], [ "lga", "LGA" ],
																	[ "pbc", "PBC" ], [ "sd", "SD" ],
																	[ "sla", "SLA" ], [ "cd", "CD" ] ],
															fields : [ "value", "text" ]
														}),
														valueField : "value",
														displayField : "text",
														triggerAction : "all",
														editable : false,
														value : "no",
														onChange : onComboChange
													},
													{
														xtype : "combo",
														id : "requestComp",
														fieldLabel : "Comp.",
														labelWidth : 100,
														flex : 1,
														store : new Ext.data.SimpleStore({
															data : [ [ true, "Yes" ], [ false, "No" ] ],
															fields : [ "value", "text" ]
														}),
														valueField : "value",
														displayField : "text",
														triggerAction : "all",
														editable : false,
														value : true,
														onChange : onComboChange
													},
													{
														xtype : "combo",
														id : "requestGen",
														fieldLabel : "Gen.level",
														labelWidth : 100,
														flex : 1,
														store : new Ext.data.SimpleStore({
															data : [ [ 0, "Ungeneralized" ],
																	[ 0.001, "0.001 degree" ],
																	[ 0.005, "0.005 degree" ],
																	[ 0.01, "0.01 degree" ],
																	[ 0.05, "0.05 degree" ], ],
															fields : [ "value", "text" ]
														}),
														valueField : "value",
														displayField : "text",
														triggerAction : "all",
														editable : false,
														value : 0,
														onChange : onComboChange
													} ]
										},
										{
											id : "map",
											xtype : "panel",
											renderTo : document.body,
											bodyStyle : {
												padding : "10px"
											},
											height : 490,
											width : 580
										},
										{
											id : "logger",
											xtype : "panel",
											renderTo : document.body,
											height : 200,
											bodyStyle : {
												padding : "10px"
											},
											tpl : '<p>{requesttype},{requestdata},{generalization},{compression},{size},{points},{geoms},{elapsed},{throughput}</p>',
											tplWriteMode : "append",
											autoScroll : true,
											data : {
												requesttype : "Type",
												requestdata : "Dataset",
												generalization : "Generalization",
												compression : "Compression",
												size : "Size",
												points : "Npoints",
												geoms : "Ngeoms",
												elapsed : "Time",
												throughput : "PointsPerSec"
											}
										} ]
							});

			var options = {
				maxExtent : zoomToBounds,
				projection : new OpenLayers.Projection("EPSG:900913"),
				displayProjection : new OpenLayers.Projection("EPSG:4326"),
				units : "m",
				maxResolution : 156543.0339
			};

			map = new OpenLayers.Map("map-body", options);

			var googlePhysical = new OpenLayers.Layer.Google("Google Physical", {
				"sphericalMercator" : true,
				type : google.maps.MapTypeId.TERRAIN
			});
			map.addLayers([ googlePhysical ]);

			// Australia's bbox
			var zoomToBounds = new OpenLayers.Bounds(108.0, -45.0, 155.0, -10.0)
					.transform(new OpenLayers.Projection("EPSG:4326"), map
							.getProjectionObject());
			map.zoomToExtent(zoomToBounds);

			// Records size of response
			OpenLayers.Request.events.on({
				success : function(evt) {
					responseSize = evt.request.responseText.length;
				}
			});

			/*
			map.events.register("movestart", map, function(map) {
				refresh();
			});
			*/
		});

function log(args) {
	Ext.getCmp("logger").update(args);
	Ext.getCmp("logger").scrollBy({
		x : 0,
		y : 16
	}, true);
}

function buildRequestUrl(type, data, gen) {
	// TODO: add COuchDB things, add fixed zoom level if the user selected that
	if (type === "oldGeoInfo") {
		var table = pgTables[data].ungeneralized;
		if (gen !== 0) {
			table = pgTables[data].generalized
					+ String(gen).replace(".", "_").replace(" ", "");
		}
		return "http://localhost:2000/pg/" + table;
	}
	if (type === "newGeoInfoFull") {
		return "https://dev-api.aurin.org.au/geoinfo/feature/" + data + "/2006";
	}

}

function refresh() {

	var myStyles = new OpenLayers.StyleMap({
		"default" : new OpenLayers.Style({
			fillColor : "red",
			strokeColor : "black",
			strokeWidth : 3
		})
	});

	// TODO: add compression (or lack thereof) in the headers

	if (Ext.getCmp("requestData").getValue() === "no") {
		if (vecLayer) {
			map.removeLayer(vecLayer);
			vecLayer = null;
		}
	} else {
	}

	return false;
};
