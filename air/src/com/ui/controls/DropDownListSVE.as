/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 7/19/13
 * Time: 10:35 AM
 * To change this template use File | Settings | File Templates.
 */
package com.ui.controls {
public class DropDownListSVE extends SpriteVisualElement {
    public function DropDownListSVE() {
        var a:DropDownListElementVector = new DropDownListElementVector();
        a.addRawElement("Alma", "10");
        a.addRawElement("Korte", "20");
        a.addRawElement("Dio", "30");
        a.addRawElement("Mogyoro", "40");
        a.addRawElement("Szilva", "50");

        a.setSelectedThis("Korte");

        var b:DropDownList = new DropDownList(a, 500, 100)
        b.visible = true;

        this.addChild(b);

        var c:DropDownListElementVector = new DropDownListElementVector(400,40,17,10);
        for(var i:uint = 0; i < 20; i++){
            c.addRawElement(i.toString(), i.toString());
        }

        var d:ListMenu = new ListMenu(c);
        d.x = 700;
        d.y = 100;

        this.addChild(d);
    }
}
}
