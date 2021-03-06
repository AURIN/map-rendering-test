var map = null;
var start, end;
var ngeoms = 0;
var npoints = 0;
var responseSize = 0;
var vecLayer = null;
var baseLayer = null;
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

			main = createForm();

			var options = {
				maxExtent : zoomToBounds,
				projection : new OpenLayers.Projection("EPSG:900913"),
				displayProjection : new OpenLayers.Projection("EPSG:4326"),
				units : "m",
				maxResolution : 156543.0339
			};

			map = new OpenLayers.Map("map", options);

			// Adds a base layer that is small and hosted on AURIN's LAN
			var baseLayer = new OpenLayers.Layer.WMS("OpenLayers WMS",
					"http://192.43.209.46:8080/geoserver/wms", {
						'layers' : 'usa'
					});
			map.addLayer(baseLayer);

			// Australia's bbox
			var zoomToBounds = new OpenLayers.Bounds(108.0, -45.0, 155.0, -10.0)
					.transform(new OpenLayers.Projection("EPSG:4326"), map
							.getProjectionObject());
			map.zoomToExtent(zoomToBounds);

			// Records size of response
			OpenLayers.Request.events.on({
				success : countFeatures
			});

			// Re-creates and re-load a vector layer at  the start of every pan/zoom
			map.events.register("movestart", map, startCollectingData);

			window
					.alert("Loading completed: switch on a layer, zoom or pan to see data");
		});

function countFeatures(evt) {
	var geojson_format = new OpenLayers.Format.GeoJSON();
	responseSize = evt.request.responseText.length;
	var features = geojson_format.read(evt.request.responseText);

	for ( var i = 0; i < features.length; i++) {
		ngeoms++;
		if (typeof features[i].geometry === "undefined"
				|| features[i].geometry === null) {
			// alert("Empty geometry");
		} else {
			var vertices = features[i].geometry.getVertices();
			npoints += vertices.length;
		}
	}
	endCollectingData();
}

function startCollectingData(evt) {
	start = new Date();
	ngeoms = 0;
	npoints = 0;
	if (Ext.getCmp("requestData").getValue() !== "no") {
		removeVectorLayer();
		vecLayer = createVecLayer();
		map.addLayer(vecLayer);
	}
}

function endCollectingData(evt) {
	end = new Date();
	var seconds = (end - start) / 1000;
	var throughput = Math.round(npoints / seconds, 0);
	log({
		requesttype : '"' + Ext.getCmp("requestType").getValue() + '"',
		precision : Ext.getCmp("precision").getValue(),
		requestdata : '"' + Ext.getCmp("requestData").getValue() + '"',
		generalization : '"' + Ext.getCmp("requestGen").getValue() + '"',
		compression : Ext.getCmp("requestComp").getValue(),
		size : responseSize,
		points : npoints,
		geoms : ngeoms,
		elapsed : seconds,
		throughput : throughput
	});
}

function log(args) {
	if (args.size > 0 && args.geoms > 0) {
		Ext.getCmp("logger").update(args);
		Ext.getCmp("logger").scrollBy({
			x : 0,
			y : 16
		}, true);
	}
}

function buildRequestUrl(type, data, gen) {
	if (type === "pg" || type === "tj") {
		var table = pgTables[data].ungeneralized;
		if (gen !== 0) {
			table = pgTables[data].generalized
					+ String(gen).replace(".", "_").replace(" ", "");
		}
		return type + "/" + table;
	} else {
		return type;
	}
}

function buildRequestParams(data, zoom, compression, precision, gen, epsg) {
	return {
		includegeom : true,
		epsg : epsg,
		genlevel : gen,
		compression : compression,
		precision : precision,
		zoom : zoom,
		featuretype : "polygon"
	};
}

function createVecLayer() {
	return new OpenLayers.Layer.Vector("GeoJSON", {
		projection : new OpenLayers.Projection("EPSG:4326"),
		strategies : [ new OpenLayers.Strategy.BBOX() ],
		protocol : new OpenLayers.Protocol.HTTP({
			format : new OpenLayers.Format.GeoJSON(),
			url : buildRequestUrl(Ext.getCmp("requestType").getValue(), Ext.getCmp(
					"requestData").getValue(), Ext.getCmp("requestGen").getValue()),
			params : buildRequestParams(Ext.getCmp("requestData").getValue(),
					map.zoom, Ext.getCmp("requestComp").getValue(), Ext.getCmp(
							"precision").getValue(), Ext.getCmp("requestGen").getValue(),
					map.displayProjection.projCode.split(":")[1])
		})
	});
}

function removeVectorLayer() {
	if (vecLayer) {
		map.removeLayer(vecLayer);
		vecLayer = null;
	}
}

function createForm() {
	var BODY_WIDTH = 900;
	Ext
			.create(
					"Ext.panel.Panel",
					{
						layout : "vbox",
						renderTo : document.body,
						width : BODY_WIDTH,
						border : false,
						items : [
								{
									xtype : "toolbar",
									width : BODY_WIDTH,
									height : 50,
									//renderTo : document.body,
									layout : {
										type : "hbox"
									//align : "stretch"
									},
									defaults : {
										width : 160,
										labelWidth : 60,
										labelAlign : 'right'
									},

									items : [
											{
												xtype : "combo",
												id : "requestType",
												fieldLabel : "Request",
												store : new Ext.data.SimpleStore({
													data : [ [ "pg", "PostGIS" ], [ "tj", "TopoJSON" ],
															[ "couchdbexact", "CouchDB exact index" ] ],
													fields : [ "value", "text" ]
												}),
												valueField : "value",
												displayField : "text",
												triggerAction : "all",
												editable : false,
												value : "pg",
												onChange : removeVectorLayer
											},
											{
												xtype : "combo",
												id : "precision",
												fieldLabel : "Precision",
												store : new Ext.data.SimpleStore({
													data : [ [ 15, "Full prec." ], [ 4, "Red. prec." ] ],
													fields : [ "value", "text" ]
												}),
												valueField : "value",
												displayField : "text",
												triggerAction : "all",
												editable : false,
												value : 15,
												onChange : removeVectorLayer
											},
											{
												xtype : "combo",
												id : "requestData",
												fieldLabel : "Data",
												store : new Ext.data.SimpleStore({
													data : [ [ "no", "No feature" ], [ "pbc", "PBC" ] ],
													fields : [ "value", "text" ]
												}),
												valueField : "value",
												displayField : "text",
												triggerAction : "all",
												editable : false,
												value : "no",
												onChange : removeVectorLayer
											},
											{
												xtype : "combo",
												id : "requestComp",
												fieldLabel : "Comp.",
												store : new Ext.data.SimpleStore({
													data : [ [ true, "Yes" ], [ false, "No" ] ],
													fields : [ "value", "text" ]
												}),
												valueField : "value",
												displayField : "text",
												triggerAction : "all",
												editable : false,
												value : false,
												onChange : removeVectorLayer
											},
											{
												xtype : "combo",
												id : "requestGen",
												fieldLabel : "Gen.level",
												store : new Ext.data.SimpleStore(
														{
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
												value : 0.05,
												onChange : removeVectorLayer
											} ]
								},
								{
									id : "logger",
									xtype : "panel",
									width : BODY_WIDTH,
									height : 300,
									bodyStyle : {
										padding : "10px"
									},
									tpl : '<p>{requesttype},{precision},{requestdata},{generalization},{compression},{size},{points},{geoms},{elapsed},{throughput}</p>',
									tplWriteMode : "append",
									autoScroll : true,
									data : {
										requesttype : "Type",
										precision : "Precision",
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
}
