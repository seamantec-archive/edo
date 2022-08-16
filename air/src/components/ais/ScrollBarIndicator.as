/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.10.08.
 * Time: 13:31
 * To change this template use File | Settings | File Templates.
 */
package components.ais {
import flash.display.Shape;

public class ScrollBarIndicator extends Shape {
    private var _windowHeight:uint;
    private var _listHeight:uint;
    private var _yOffset:uint;


    public function ScrollBarIndicator() {
        super();
    }

    private function drawIndicator():void {
        var calculatedHeight:uint = _windowHeight * (_windowHeight / _listHeight);
        if (calculatedHeight > _windowHeight) {
            calculatedHeight = _windowHeight;
        }
        this.graphics.clear();
        this.graphics.beginFill(0x0e0e0e, 0.5);
        this.graphics.drawRoundRect(0, 0, 6, calculatedHeight, 6);
        this.graphics.endFill();
    }


    public function get windowHeight():uint {
        return _windowHeight;
    }

    public function set windowHeight(value:uint):void {
        _windowHeight = value;
        drawIndicator();
    }

    public function get listHeight():uint {
        return _listHeight;
    }

    public function set listHeight(value:uint):void {
        _listHeight = value;
        drawIndicator();
    }

    public function setY(y:uint) {
        this.y = y * getRatio() + _yOffset;
    }

    public function getRatio():Number {
        var ratio:Number = (_windowHeight / _listHeight);
        return ratio <= 1 ? ratio : 1;
    }


    public function get yOffset():uint {
        return _yOffset;
    }

    public function set yOffset(value:uint):void {
        _yOffset = value;
    }
}
}
