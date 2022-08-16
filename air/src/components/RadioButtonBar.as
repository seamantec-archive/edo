/**
 * Created by seamantec on 26/02/14.
 */
package components {
import flash.events.MouseEvent;

public class RadioButtonBar extends ToggleButtonBar {

    public function RadioButtonBar(x:int, y:int, labels:Array = null, fontSize:int = 12) {
        super(x,y, labels, fontSize, false);
    }

    override public function addButton(label:String) {
        label == "" ? _enableFlag = false : _enableFlag = true;
        _buttonsArray.push(new RadioButton(_buttonsArray.length, label, _labelFontSize, _enableFlag));
        _buttonsArray[_buttonsArray.length - 1].addEventListener(MouseEvent.CLICK, mouseClickHandler, false, 0, true);
        _buttonsArray[_buttonsArray.length - 1].x = (_buttonsArray.length==1) ? 0 : (_buttonsArray[_buttonsArray.length-2].x + _buttonsArray[_buttonsArray.length-2].width);
        this.addChild(_buttonsArray[_buttonsArray.length - 1]);
    }

    public function setButtonsX(index:int, x:Number):void {
        _buttonsArray[index].x = x;
    }

    public function getButton(index:int):RadioButton {
        return (index>=0 && index<_buttonsArray.length) ? _buttonsArray[index] as RadioButton : null;
    }
}
}
