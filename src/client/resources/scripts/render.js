var map = null;
var start, end;
var ngeoms = 0;
var npoints = 0;
var wfslayer = null;
var main;

Ext.require([ "Ext.direct.*", "Ext.panel.Panel", "Ext.form.field.Text",
		"Ext.toolbar.TextItem" ]);

Ext
		.onReady(function() {

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
														value : "oldGeoInfo"
													},
													{
														xtype : "combo",
														id : "requestData",
														fieldLabel : "Data",
														labelWidth : 100,
														flex : 1,
														store : new Ext.data.SimpleStore({
															data : [ [ "state", "STE" ], [ "ccd", "PBC" ],
																	[ "sla", "SLA" ] ],
															fields : [ "value", "text" ]
														}),
														valueField : "value",
														displayField : "text",
														triggerAction : "all",
														editable : false,
														value : "state"
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
														value : true
													},
													{
														xtype : "combo",
														id : "requestZoom",
														fieldLabel : "Zoom",
														labelWidth : 100,
														flex : 1,
														store : new Ext.data.SimpleStore({
															data : [ [ 0, "Auto" ], [ 5, "5" ], [ 6, "6" ],
																	[ 7, "7" ], [ 8, "8" ], [ 9, "9" ],
																	[ 10, "10" ], [ 11, "11" ], [ 12, "12" ],
																	[ 13, "13" ], [ 14, "14" ], [ 15, "15" ],
																	[ 16, "16" ], [ 17, "17" ] ],
															fields : [ "value", "text" ]
														}),
														valueField : "value",
														displayField : "text",
														triggerAction : "all",
														editable : false,
														value : 0
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
											tpl : '<p>{requesttype},{requestdata},{zoom},{compression},{elapsed},{points},{geoms}</p>',
											tplWriteMode : "append",
											autoScroll : true,
											data : {
												requesttype : "Type",
												requestdata : "Dataset",
												zoom : "Zoom",
												compression : "Compression",
												elapsed : "Time",
												points : "Npoints",
												geoms : "Ngeoms"
											}
										} ]
							});

			var options = {
				maxExtent : zoomToBounds,
				projection : new OpenLayers.Projection("EPSG:900913"),
				displayProjection : new OpenLayers.Projection("EPSG:4326"),
				units : "m",
				maxResolution : 156543.0339
			// follow google
			};
			map = new OpenLayers.Map("map-body", options);

			var googlePhysical = new OpenLayers.Layer.Google("Google Physical", {
				"sphericalMercator" : true,
				type : google.maps.MapTypeId.TERRAIN
			});
			map.addLayers([ googlePhysical ]);

			// australia bbox
			var zoomToBounds = new OpenLayers.Bounds(108.0, -45.0, 155.0, -10.0)
					.transform(new OpenLayers.Projection("EPSG:4326"), map
							.getProjectionObject());
			map.zoomToExtent(zoomToBounds);

			map.events.register("movestart", map, function(map) {
				refresh();
			});

		});

function log(args) {
	Ext.getCmp("logger").update(args);
	Ext.getCmp("logger").scrollBy({
		x : 0,
		y : 16
	}, true);
}

function buildRequestUrl(type, data) {
	// TODO: add COuchDB things, add fixed zoom level if the user selected that
	if (type === "oldGeoInfo") {
		return "https://dev-api.aurin.org.au/node/feature/" + data + "/2006";
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

	if (wfslayer) {
		wfslayer.destroy();
		ngeoms = 0;
		npoints = 0;
	}

	// TODO: add compression (or lack thereof) in the headers
	wfslayer = new OpenLayers.Layer.Vector("Test", {
		projection : new OpenLayers.Projection("EPSG:4326"),
		strategies : [ new OpenLayers.Strategy.BBOX() ],
		protocol : new OpenLayers.Protocol.Script({
			url : buildRequestUrl(Ext.getCmp("requestType").getValue(), Ext.getCmp(
					"requestData").getValue()),
			callbackKey : "format_options", // must be set to this
			callbackPrefix : "callback:",
			params : {
				includegeom : "true",
				zoom : map.zoom,
				epsg : map.displayProjection.projCode.split(":")[1]
			}
		/*
		 * , filterToParams : function(filter, params) { // example to demonstrate
		 * BBOX serialization //
		 * bbox=-235.14844954,-55.46555255425,477.11717546,7.6711225881483,EPSG%3A4326
		 * if (filter.type === OpenLayers.Filter.Spatial.BBOX) { params.bbox =
		 * filter.value.toArray(); if (filter.projection) {
		 * params.bbox.push(filter.projection.getCode()); } } params.zoom =
		 * map.zoom; return params; }
		 */
		}),
		eventListeners : {
			"loadstart" : function() {
				start = new Date();
			},
			"loadend" : function() {
				end = new Date();
				var seconds = (end - start) / 1000;
				var throughput = Math.round(npoints / seconds, 0);
				log({
					requesttype : '"' + Ext.getCmp("requestType").getValue() + '"',
					requestdata : '"' + Ext.getCmp("requestData").getValue() + '"',
					zoom : '"' + Ext.getCmp("requestZoom").getValue() + '"',
					compression : '"' + Ext.getCmp("requestComp").getValue() + '"',
					elapsed : seconds,
					points : npoints,
					geoms : ngeoms
				});
			},
			"featureadded" : function(elem) {
				ngeoms++;
				npoints += elem.feature.geometry.getVertices().length;
			}
		}
	})
	map.addLayers([ wfslayer ]);

	return false;
};
