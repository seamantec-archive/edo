/**
 * Created by seamantec on 25/06/14.
 */
package com.ui.controls {

public class BitmapButtonOptions {

    public var fontSize:Number;
    public var text:String;
    public var icon:Class;
    public var color:uint;
    public var align:String;
    public var margin:Number;
    public var bold:Boolean;

    public function BitmapButtonOptions(text:String, fontSize:Number = 14, color:uint = 0xffffff, icon:Class = null, align:String = "center", margin:Number = 0, bold = true) {
        this.text = text;
        this.fontSize = fontSize;
        this.color = color;
        this.icon = icon;
        this.align = align;
        this.margin = margin;
        this.bold = bold;
    }
}
}
