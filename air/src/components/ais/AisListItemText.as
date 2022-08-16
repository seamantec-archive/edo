/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.10.08.
 * Time: 15:02
 * To change this template use File | Settings | File Templates.
 */
package components.ais {
import com.utils.FontFactory;

import flash.display.Sprite;
import flash.text.TextField;

public class AisListItemText extends Sprite {
    private var labelTf:TextField;
    private var valueTf:TextField;


    public function AisListItemText(label:String, value:String, w:int, h:int, x:int, y:int, borders = null) {
        super();
        labelTf = FontFactory.getCustomFont({size: 10, color: 0x9bdfff, align: "left", autoSize: "left"});
        labelTf.text = label + ":";
        labelTf.x = 0;
        labelTf.height = 10;
        labelTf.y = -1;
        valueTf = FontFactory.getCustomFont({size: 10, color: 0xffffff, align: "left", autoSize: "left", leading:0.2});
        valueTf.text = value;
        valueTf.x = 0;
        valueTf.height = 10;
        valueTf.y = 10;


        this.x = x;
        this.y = y;
        this.addChild(labelTf);
        this.addChild(valueTf)
        if (borders != null) {
            this.graphics.lineStyle(1, 0x696969);

            for (var i:int = 0; i < borders.length; i++) {
                switch (borders[i]) {
                    case "right":
                        this.graphics.moveTo(w - 1, 0);
                        this.graphics.lineTo(w - 1, h);
                        break;
                    case "bottom":
                        this.graphics.moveTo(0, h-1);
                        this.graphics.lineTo(w, h-1);
                        break;
                }
            }
        }
    }

    public function setValue(value:String):void {
        valueTf.text = value;
    }
}
}
