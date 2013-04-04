var map = null;
var start, end;
var ngeoms = 0;
var npoints = 0;
var responseSize = 0;
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

      var onComboChange = function() {
        if (vecLayer) {
          map.removeLayer(vecLayer);
          vecLayer = null;
        }
      };
      var BODY_WIDTH = 900;

      main = Ext
          .create(
              "Ext.panel.Panel",
              {
                layout : "vbox",
                renderTo : document.body,
                width : BODY_WIDTH,
                border: false,
                items : [
                    {
                      xtype : "toolbar",
                      width: BODY_WIDTH,
                      height : 50,
                      //renderTo : document.body,
                      layout : {
                        type : "hbox"
                        //align : "stretch"
                      },
                      defaults: {
                        width: 160,
                        labelWidth: 60,
                        labelAlign: 'right'
                      },

                      items : [
                          {
                            xtype : "combo",
                            id : "requestType",
                            fieldLabel : "Request",
                            store : new Ext.data.SimpleStore({
                              data : [ [ "pg", "PostGIS" ],
                                  [ "couchdb", "CouchDB" ] ],
                              fields : [ "value", "text" ]
                            }),
                            valueField : "value",
                            displayField : "text",
                            triggerAction : "all",
                            editable : false,
                            value : "pg",
                            onChange : onComboChange
                          },
                          {
                            xtype : "combo",
                            id : "precision",
                            fieldLabel : "Precision",
                            store : new Ext.data.SimpleStore({
                              data : [ [ 15, "Full prec." ],
                                  [ 4, "Red. prec." ] ],
                              fields : [ "value", "text" ]
                            }),
                            valueField : "value",
                            displayField : "text",
                            triggerAction : "all",
                            editable : false,
                            value : 15,
                            onChange : onComboChange
                          },
                          {
                            xtype : "combo",
                            id : "requestData",
                            fieldLabel : "Data",
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
                            store : new Ext.data.SimpleStore({
                              data : [ [ "no", "Ungeneralized" ],
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
                            onChange : onComboChange
                          } ]
                    },
                    {
                      id : "logger",
                      xtype : "panel",
                      width: BODY_WIDTH,
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

      var options = {
        maxExtent : zoomToBounds,
        projection : new OpenLayers.Projection("EPSG:900913"),
        displayProjection : new OpenLayers.Projection("EPSG:4326"),
        units : "m",
        maxResolution : 156543.0339
      };

      map = new OpenLayers.Map("map", options);

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

      // Re-creates and re-load a vector layer at every map movement
      map.events.register("movestart", map, function(map2) {
        if (Ext.getCmp("requestData").getValue() !== "no") {
          if (vecLayer !== null) {
            map.removeLayer(vecLayer);
          }
          vecLayer = createVecLayer();
          map.addLayers([ vecLayer ]);
        }
      });
    });

function log(args) {
  if (args.size > 0) {
    Ext.getCmp("logger").update(args);
    Ext.getCmp("logger").scrollBy({
      x : 0,
      y : 16
    }, true);
  }
}

function buildRequestUrl(type, data, gen) {
  // TODO: add COuchDB things, add fixed zoom level if the user selected that
  if (type === "pg") {
    var table = pgTables[data].ungeneralized;
    if (gen !== "no") {
      table = pgTables[data].generalized
          + String(gen).replace(".", "_").replace(" ", "");
    }
    return "pg/" + table;
  }
  if (type === "newGeoInfoFull") {
    return "https://dev-api.aurin.org.au/geoinfo/feature/" + data + "/2006";
  }

}

function createVecLayer() {

  return new OpenLayers.Layer.Vector("GeoJSON", {
    projection : new OpenLayers.Projection("EPSG:4326"),
    strategies : [ new OpenLayers.Strategy.BBOX() ],
    protocol : new OpenLayers.Protocol.HTTP({
      format : new OpenLayers.Format.GeoJSON(),
      url : buildRequestUrl(Ext.getCmp("requestType").getValue(), Ext.getCmp(
          "requestData").getValue(), Ext.getCmp("requestGen").getValue()),
      params : {
        includegeom : "true",
        zoom : map.zoom,
        compression : Ext.getCmp("requestComp").getValue(),
        precision : Ext.getCmp("precision").getValue(),
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
        end = new Date();
        var seconds = (end - start) / 1000;
        var throughput = Math.round(npoints / seconds, 0);
        log({
          requesttype : '"' + Ext.getCmp("requestType").getValue() + '"',
          precision : Ext.getCmp("precision").getValue(),
          requestdata : '"' + Ext.getCmp("requestData").getValue() + '"',
          generalization : '"' + Ext.getCmp("requestGen").getValue() + '"',
          compression :  + (Ext.getCmp("requestComp").getValue() === 1) ? true : false,
          size : responseSize,
          points : npoints,
          geoms : ngeoms,
          elapsed : seconds,
          throughput : throughput
        });
      },
      "featureadded" : function(elem) {
        ngeoms++;
        npoints += elem.feature.geometry.getVertices().length;
      }
    }
  });
};
