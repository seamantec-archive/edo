/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 6/27/13
 * Time: 2:00 PM
 * To change this template use File | Settings | File Templates.
 */
package com.timeline {
import flash.display.Bitmap;
import flash.display.Sprite;

public class MarkerforSmallTimeline extends Marker {

    [Embed(source="../../../assets/images/alarmlist/slider_knob.png")] var sliderKnobPNG:Class;

    var sliderSp:Sprite = new Sprite();
    var bitmap:Bitmap = new sliderKnobPNG();

    public function MarkerforSmallTimeline(minX:Number, markerHeight:Number, lineColor:uint = 0xFFFF00, lineWidth:Number = 1, vertical:Boolean = false) {
        super(minX, 1, lineColor, lineWidth, vertical);
        bitmap.x = -bitmap.width/2;
        this.addChild(bitmap);
    }
}
}
