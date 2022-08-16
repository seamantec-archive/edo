/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.01.22.
 * Time: 13:47
 * To change this template use File | Settings | File Templates.
 */
package components {
import com.common.InstrumentMouseHandler;
import com.layout.LayoutHandler;
import com.ui.TopBar;
import com.ui.controls.InstrumentsGroup;
import com.utils.FontFactory;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;

public class InstrumentSelector extends Sprite {
    private var klass:Class;
    private var controllName:String;
    private var controllClass:String;
    private var bitmap:Bitmap;
    private var wrapper:Sprite;
    public static const BITMAP_HEIGHT = 70;

    public function InstrumentSelector(bitmap:Bitmap, klass:Class, controllName:String, controllClass:String) {
        super();

        var rate:Number = (bitmap.width / bitmap.height)
        this.bitmap = bitmap;
        this.bitmap.height = rate <= 1 ? BITMAP_HEIGHT : BITMAP_HEIGHT / rate;
        this.bitmap.width = rate >= 1 ? BITMAP_HEIGHT : BITMAP_HEIGHT * rate;

        this.bitmap.x = (BITMAP_HEIGHT - this.bitmap.width) / 2;
        this.bitmap.y = (BITMAP_HEIGHT - this.bitmap.height) / 2;


        this.klass = klass;
        this.controllName = controllName;
        this.controllClass = controllClass;
        this.addChild(this.bitmap);

        var _labelText:TextField = FontFactory.getCenter10BlackTextField();
        _labelText.multiline = true;
        _labelText.y = BITMAP_HEIGHT;
        _labelText.x = 0;
        _labelText.width = BITMAP_HEIGHT;
        _labelText.height = 20;
        _labelText.text = controllName;

        this.addChild(_labelText);

        this.graphics.beginFill(0xFFFFFF, 0);
        this.graphics.drawRect(0,0, BITMAP_HEIGHT,BITMAP_HEIGHT+_labelText.height);
        this.graphics.endFill();

        this.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler, false, 0, true);
        this.addEventListener(MouseEvent.CLICK, doubleClickHandler, false, 0, true);
        this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
        this.bitmap.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler, false, 0, true)

    }

    private function doubleClickHandler(event:MouseEvent):void {

    }

    private function mouseDownHandler(event:MouseEvent):void {
        wrapper = new Sprite();
        stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
        //wrapper.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
        var wBitmap:Bitmap = new Bitmap(bitmap.bitmapData)
        wBitmap.width = this.bitmap.width;
        wBitmap.height = this.bitmap.height;
        wBitmap.alpha = 0.7
        wrapper.x = event.stageX-mouseX;
        wrapper.y = event.stageY-mouseY;
        wrapper.addChild(wBitmap);
        parent.parent.addChild(wrapper)
        wrapper.startDrag()

    }

    private function mouseUpHandler(event:MouseEvent):void {
        stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler)
        wrapper.stopDrag();
        var wrapperCoordinate:Point = wrapper.localToGlobal(new Point())
        parent.parent.removeChild(wrapper)
        wrapper = null;
        if(wrapperCoordinate.y>(TopBar.barHeight+InstrumentsGroup.height)) {
            wrapperCoordinate.x -= wrapperCoordinate.x%InstrumentMouseHandler.SNAP_GRID_SIZE;
            wrapperCoordinate.y -= wrapperCoordinate.y%InstrumentMouseHandler.SNAP_GRID_SIZE;
            LayoutHandler.instance.activeLayout.openControlWindowByMouse(controllClass, wrapperCoordinate.x, wrapperCoordinate.y - BITMAP_HEIGHT);
        }
    }




}
}
