/**
 * Created by seamantec on 26/02/14.
 */
package components {
import com.ui.controls.BitmapButton;

public class RadioButton extends BitmapButton {

    [Embed(source="../../assets/images/Layout pngs/radiobtn_on.png")] private static var on:Class;
    [Embed(source="../../assets/images/Layout pngs/radiobtn_off.png")] private static var off:Class;

    private var _index:int;
    private var _clickable:Boolean;

    public function RadioButton(index:int = 0, text:String = null, fontSize:int = 10, clickable:Boolean = true) {
        _clickable = clickable;

        super(off, off, off, on, on, text, null, fontSize, 0xDEDEDE, "left", -5, true, false);

        _index = index;
//        _labelText = text;
//        _labelFontSize = fontSize;

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
