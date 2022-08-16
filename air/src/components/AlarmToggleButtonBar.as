/**
 * Created by pepusz on 2014.08.01..
 */
package components {
import flash.events.MouseEvent;

public class AlarmToggleButtonBar extends ToggleButtonBar {
    public function AlarmToggleButtonBar(xIn:int, yIn:int, labelIn:Array = null, lblFontSize:int = 9, short:Boolean = true) {
        super(xIn, yIn, labelIn, lblFontSize, short);
    }

    override public function addButton(lbl:String) {
        lbl == "" ? _enableFlag = false : _enableFlag = true;
        _buttonsArray.push(new AlarmToggleButton(_buttonsArray.length, lbl, labelFontSize, _enableFlag, _shortBtns));
        _buttonsArray[_buttonsArray.length - 1].addEventListener(MouseEvent.CLICK, mouseClickHandler, false, 0, true);
        _buttonsArray[_buttonsArray.length - 1].x = (_buttonsArray.length - 1) * 35;
        this.addChild(_buttonsArray[_buttonsArray.length - 1]);
    }
}
}
