package components.list {
import com.utils.FontFactory;

import flash.display.Sprite;
import flash.text.TextField;

public class ListItem extends Sprite {

    private var _color:uint;
    private var _alpha:Number;

    protected var _labels:Vector.<TextField>;

    public function ListItem(width:Number, height:Number, color:uint=0xFFFFFF, alpha:Number=1) {
        super();

        this.x = 0;
        this.y = 0;
        _color = color;
        _alpha = alpha;
        drawBg(color, alpha, width, height);
        this.width = width;
        this.height = height;

        _labels = new Vector.<TextField>();
    }

    protected function drawBg(color:uint, alpha:Number, width:Number, height:Number):void {
        this.graphics.beginFill(color, alpha);
        this.graphics.drawRect(x, y, width, height);
        this.graphics.endFill();
    }

    public function addLabel(label:String, font:TextField=null, x:Number=0, y:Number = 0):TextField {
        if(font==null) {
            font = FontFactory.getLeftTextField();
        }
        font.x = x;
        font.y = y;
        font.text = label;
        this.addChild(font);

        _labels.push(font);

        return font;
    }

    public function getLabel(index:int):TextField {
        if(_labels!=null && index<_labels.length) {
            return _labels[index];
        }
        return null;
    }

    public function getLabelByText(text:String):TextField {
        for(var i:int=0; i<_labels.length; i++) {
            var label:TextField = _labels[i];
            if(label.text==text) {
                return label;
            }
        }
        return null;
    }

    public function getHeight():Number {
        return this.height;
    }

    public function get color():uint {
        return _color;
    }

    public function setWidth(width:Number):void {
        var widthDiff:Number = width - this.width;
        var height:Number = this.height;

        this.graphics.clear();
        this.graphics.beginFill(_color, _alpha);
        this.graphics.drawRect(x,y, width,height);
        this.graphics.endFill();
        /*
        for(var i:int=0; i<this.numChildren; i++) {
            var child:DisplayObject = this.getChildAt(i);
            child.x += widthDiff;
        }
        */
    }

}
}
