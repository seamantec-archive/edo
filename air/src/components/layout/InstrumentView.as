/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.27.
 * Time: 15:15
 * To change this template use File | Settings | File Templates.
 */
package components.layout {
import com.utils.FontFactory;

import components.InstrumentSelector;

import flash.display.Sprite;
import flash.text.TextField;

public class InstrumentView extends Sprite {

    [Embed(source="../../../assets/images/alarmlist/list_element.png")]
    private static var elementBg:Class;
    private var _instrumentSelector:InstrumentSelector;

    public static const DEF_HEIGHT:int = 60;


    public function InstrumentView(instrumentSelector:InstrumentSelector) {
        super();
        this._instrumentSelector = instrumentSelector;
        addChild(new elementBg());
        _instrumentSelector.x = 0;
        _instrumentSelector.y = 5;
        addChild(this._instrumentSelector)
        createHeaderLabel();
        createLabelText();
        createInfoLabelText()
    }


    private function createHeaderLabel():void {
        var text2:TextField = FontFactory.getLeftTextField()
        text2.text =""
        text2.y = 0;
        text2.x = 80;
        text2.width = 180;
        addChild(text2);
    }


    private function createLabelText():void {



    }


    private function createInfoLabelText():void {



    }


}
}
