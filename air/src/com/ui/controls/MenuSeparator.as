/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.06.27.
 * Time: 14:34
 * To change this template use File | Settings | File Templates.
 */
package com.ui.controls {
import flash.display.Shape;

public class MenuSeparator extends Shape {
    private static var _w:int = Menu.MENU_WIDTH;
    private static var _h:int = 16;

    public function MenuSeparator() {
        drawSeparator()
    }

    private function drawSeparator():void {
        this.graphics.clear();
        this.graphics.beginFill(0xc9c9c9);
        this.graphics.drawRect(0, 0, _w, _h);
        this.graphics.endFill();
        this.graphics.lineStyle(1, 0xe2e2e2);
        this.graphics.moveTo(2, (_h - 2) / 2 + 1);
        this.graphics.lineTo(_w - 4, (_h - 2) / 2 + 1);
        this.graphics.lineStyle(1, 0x9f9f9f);
        this.graphics.moveTo(2, (_h - 2) / 2);
        this.graphics.lineTo(_w - 4, (_h - 2) / 2);

    }
}
}
