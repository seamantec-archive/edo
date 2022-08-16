/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.07.25.
 * Time: 16:22
 * To change this template use File | Settings | File Templates.
 */
package com.graphs {
public class YData {
    public static const LINE_GRAPH:String = "line";
    public static const AREA_GRAPH:String = "area";
    public static const DEPTH_GRAPH:String = "depth";

    public var label:String;
    public var dataKey:String;
    public var min:Array;
    public var max:Array;
    public var graphType:String;
    public var pLineColor:uint = 0x00ff00;
    public var pLineWidth:int = 1;
    public var pLineAlpha:Number = 1;
    public var pAreaColor:uint = 0x00ff00;
    public var pAreaAlpha:Number = 0.3;
    public var nLineColor:uint = 0xff0000;
    public var nLineWidth:int = 1;
    public var nLineAlpha:Number = 1;
    public var nAreaColor:uint = 0xff0000;
    public var nAreaAlpha:Number = 0.3;
    public var quantalZoom:int = 1;
    public var squaredDraw:Boolean = true;



    public function YData(label:String, dataKey:String, min:Array, max:Array, graphType:String, options:Object = null) {
        this.label = label;
        this.dataKey = dataKey;
        this.min = min;
        this.max = max;
        this.graphType = graphType;
        if (options != null) {
            if (options.hasOwnProperty("pLineColor")) this.pLineColor = options["pLineColor"];
            if (options.hasOwnProperty("pLineWidth")) this.pLineWidth = options["pLineWidth"];
            if (options.hasOwnProperty("pLineAlpha")) this.pLineAlpha = options["pLineAlpha"];
            if (options.hasOwnProperty("pAreaColor")) this.pAreaColor = options["pAreaColor"];
            if (options.hasOwnProperty("pAreaAlpha")) this.pAreaAlpha = options["pAreaAlpha"];
            if (options.hasOwnProperty("nLineColor")) this.nLineColor = options["nLineColor"];
            if (options.hasOwnProperty("nLineWidth")) this.nLineWidth = options["nLineWidth"];
            if (options.hasOwnProperty("nLineAlpha")) this.nLineAlpha = options["nLineAlpha"];
            if (options.hasOwnProperty("nAreaColor")) this.nAreaColor = options["nAreaColor"];
            if (options.hasOwnProperty("nAreaAlpha")) this.nAreaAlpha = options["nAreaAlpha"];
            if (options.hasOwnProperty("quantalZoom")) this.quantalZoom = options["quantalZoom"];
            if (options.hasOwnProperty("squaredDraw")) this.squaredDraw = options["squaredDraw"];
        }
    }
}
}
