/**
 * Created by pepusz on 2013.12.10..
 */
package components {
import com.common.InstrumentMouseHandler;
import com.layout.Layout;
import com.ui.controls.BitmapButton;

import flash.geom.Point;

public interface IInstrument {
    function move(x:int, y:int):void;

    function open(parent:Layout):void;

    function resize(w:Number, h:Number):void;

    function addControl(element:*, initWidth:int, initHeight:int):void;

    function addToStageControl():void ;

    function get closeBtn():BitmapButton;

    function get resizeBtn():BitmapButton;

    function get isChart():Boolean;

    function get mouseHandler():InstrumentMouseHandler;

    function set controlType(value:String):void;

    function get controlType():String

    function get width():Number;

    function get height():Number;

    function set width(value:Number):void;

    function set height(value:Number):void;

    function get control():*;

    function getCoordinates():Point;

    function set controlState(state:String):void;

    function set visible(value:Boolean):void;

//    function get moveButton():BitmapButton;

    function get scaleX():Number;

    function get scaleY():Number;

    function set originWidth(value:int):void;

    function set originHeight(value:int):void;

    function get originHeight():int;

    function get originWidth():int;

    function drawBg(width:uint, height:uint):void;

}
}
