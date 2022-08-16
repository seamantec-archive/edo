/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.10.01.
 * Time: 14:28
 * To change this template use File | Settings | File Templates.
 */
package components.ais {
import com.utils.FontFactory;

import flash.display.Sprite;
import flash.text.TextField;

public class AisDetailItem extends Sprite {
    private var labelTf:TextField;
    private var valueTf:TextField;
    private var valueTf2:TextField = null;

    private var _isBreak:Boolean;

    public function AisDetailItem(label:String, value:String, isBreak:Boolean = false) {
        _isBreak = isBreak;

        labelTf = FontFactory.getRightBlackTextField();
        labelTf.text = label + ":";
        labelTf.x = 75-labelTf.width;
        this.addChild(labelTf);
        valueTf = FontFactory.getCustomFont({size: 12, bold: true, align:"left", autoSize: "left"});
        valueTf.x = labelTf.width+5+labelTf.x;
        this.addChild(valueTf);
        if(_isBreak && value.length>14) {
            valueTf.text = value.substr(0,14);
            valueTf2 = FontFactory.getCustomFont({size: 12, bold: true, align:"left", autoSize: "left"});
            valueTf2.text = value.substr(14);
            valueTf2.x = valueTf.x;
            valueTf2.y = valueTf.height - 5;
            this.addChild(valueTf2);
        } else {
            valueTf.text = value;
        }
    }

    public function setValue(value:String):void {
        if(_isBreak && value.length>14) {
            valueTf.text = value.substr(0,14);
            if(valueTf2==null) {
                valueTf2 = FontFactory.getCustomFont({size: 12, bold: true, align:"left", autoSize: "left"});
                valueTf2.x = valueTf.x;
                valueTf2.y = valueTf.height - 5;
                this.addChild(valueTf2);
            }
            valueTf2.text = value.substr(14);
        } else {
            valueTf.text = value;
        }
    }
}
}
