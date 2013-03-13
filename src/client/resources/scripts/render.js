var map = null;
var start, end;
var ngeoms = 0;
var npoints = 0;

Ext.onReady(function() {

	var options = {
		maxExtent : zoomToBounds,
		projection : new OpenLayers.Projection("EPSG:900913"),
		displayProjection : new OpenLayers.Projection("EPSG:4326"),
		units : 'm',
		maxResolution : 156543.0339
	// follow google
	};
	map = new OpenLayers.Map('map', options);

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

	map.events.register('movestart', map, function(map) {
		refresh();
	});

});

var wfslayer = null;

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

	wfslayer = new OpenLayers.Layer.Vector("Test", {
		// styleMap: myStyles,
		projection : new OpenLayers.Projection("EPSG:4326"),
		strategies : [ new OpenLayers.Strategy.BBOX() ],
		protocol : new OpenLayers.Protocol.Script({
			url : Ext.get("protocol").getValue() + Ext.get("host").getValue() + "/"
					+ Ext.get("app").getValue() + "/" + Ext.get("feature").getValue()
					+ "/" + Ext.get("year").getValue(),
			callbackKey : "format_options", // must be set to this
			callbackPrefix : "callback:",
			params : {
				includegeom : "true",
				zoom : map.zoom,
				epsg : map.displayProjection.projCode.split(":")[1]
			// IFXME:
			// displayProjection
			// or projection ?
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
			'loadstart' : function() {
				console.log("LOADSTART");
				start = new Date();
				Ext.get("logconsole").insertHtml("beforeEnd", "loadstart " + "\n")
			},
			"loadend" : function() {
				console.log("LOADEND");
				end = new Date();
				var seconds = (end - start) / 1000;
				var throughput = Math.round(npoints / seconds, 0);
				Ext.get("logconsole").insertHtml(
						"beforeEnd",
						"Time: " + seconds + " Geometries: " + ngeoms + " Points: "
								+ npoints + " Throughput: " + throughput + "\n")
			},
			'featureadded' : function(elem) {
				ngeoms++;
				npoints += elem.feature.geometry.getVertices().length;
			}
		}
	})
	map.addLayers([ wfslayer ]);

	return false;
};
