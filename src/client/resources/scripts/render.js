var map = null;              
var start, end;

Ext.onReady(function(){

  var options = {
    maxExtent: zoomToBounds,
    projection: new OpenLayers.Projection("EPSG:900913"),
    displayProjection: new OpenLayers.Projection("EPSG:4326"),
    units : 'm',
    maxResolution: 156543.0339 // follow google
  };
  map = new OpenLayers.Map('map',options);
 
  var googlePhysical = new OpenLayers.Layer.Google(
      "Google Physical",
    { "sphericalMercator": true
    , type: google.maps.MapTypeId.TERRAIN
    }
  );
  map.addLayers([googlePhysical]);
  
  // australia bbox
  var zoomToBounds = new OpenLayers.Bounds(108.0, -45.0,155.0,-10.0).transform(
    new OpenLayers.Projection("EPSG:4326"),
    map.getProjectionObject()
  );
  map.zoomToExtent(zoomToBounds);
  
});

var wfslayer = null;

function refresh() {
  
  
  var myStyles = new OpenLayers.StyleMap({
    "default": new OpenLayers.Style({
      fillColor: "red",
      strokeColor: "black",
      strokeWidth: 3
    })
  });  

  if (wfslayer)
    wfslayer.destroy();
    
  wfslayer = new OpenLayers.Layer.Vector("Test", {
    // styleMap: myStyles,
    projection: new OpenLayers.Projection("EPSG:4326"),
    strategies: [new OpenLayers.Strategy.BBOX()],
    eventListeners: {
      "loadend": function() {
        console.log("LOADEND");
        end = new Date();
        Ext.get("logconsole").insertHtml("beforeEnd", "loadend "+(end-start)/1000+"\n")  
      },
      'loadstart': function() {
        console.log("LOADSTART");
        start = new Date();        
        Ext.get("logconsole").insertHtml("beforeEnd", "loadstart "+"\n")  
      },
      'featuresadded': function() {
        console.log("ADDED");
      }  
    },      
    protocol: new OpenLayers.Protocol.Script({
      url: "http://192.43.209.46:2000/geojson",
      callbackKey: "format_options", // must be set to this
      callbackPrefix: "callback:",                                    
      params: {
        host: Ext.get("host").getValue(),
        db: Ext.get("db").getValue(),
        port: Ext.get("port").getValue(),
        user: Ext.get("user").getValue(),
        password: Ext.get("password").getValue(),
        table: Ext.get("table").getValue(),
        key: Ext.get("key").getValue(),
        geom: Ext.get("geom").getValue()
      },
      filterToParams: function(filter, params) {
        // example to demonstrate BBOX serialization
        // bbox=-235.14844954,-55.46555255425,477.11717546,7.6711225881483,EPSG%3A4326
        if (filter.type === OpenLayers.Filter.Spatial.BBOX) {
          params.bbox = filter.value.toArray();
          if (filter.projection) {
            params.bbox.push(filter.projection.getCode());
          }
        }            
        params.zoom = map.zoom;
        return params;
      }               
    })
  })  
  map.addLayers([wfslayer]);
  
  return false;            
};
