/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 7/8/13
 * Time: 2:30 PM
 * To change this template use File | Settings | File Templates.
 */
package components {

import com.ui.controls.BitmapButton;

public class ToggleButton extends BitmapButton {

    [Embed(source="../../assets/images/settings_btn0.png")] private static var ICO0:Class;
    [Embed(source="../../assets/images/settings_btn1.png")] private static var ICO1:Class;
    [Embed(source="../../assets/images/settings_longbtn0.png")] private static var ICO0Long:Class;
    [Embed(source="../../assets/images/settings_longbtn1.png")] private static var ICO1Long:Class;

    private var _index:int;
    private var _clickable:Boolean;
    private var _tmpIcon:Class;
    private var _tmpICO0:Class;
    private var _tmpICO1:Class;

    public function ToggleButton(ind:int = 0, text:String = null, lblFontSize:int = 10, clck:Boolean = true, shrtBtns:Boolean = true) {

        _clickable = clck;

        if(shrtBtns){
            _tmpICO0 = ICO0;
            _tmpICO1 = ICO1;
        }else{
            _tmpICO0 = ICO0Long;
            _tmpICO1 = ICO1Long;
        }

        !_clickable ? _tmpIcon = _tmpICO0 : _tmpIcon = _tmpICO1

        super(_tmpICO0, _tmpICO0, _tmpIcon, _tmpICO0, _tmpIcon, text, null, lblFontSize);

        _index = ind;
//        _labelText = text;
//        _labelFontSize = lblFontSize;

        resetStates();
    }

    public function get index():int {
        return _index;
    }

    public function set index(value:int):void {
        _index = value;
    }

    public function get clickable():Boolean {
        return _clickable;
    }

}
}