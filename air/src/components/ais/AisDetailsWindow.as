/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.10.05.
 * Time: 11:36
 * To change this template use File | Settings | File Templates.
 */
package components.ais {
import com.common.AppProperties;

import flash.display.NativeWindow;
import flash.display.NativeWindowInitOptions;
import flash.display.NativeWindowSystemChrome;
import flash.display.NativeWindowType;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.geom.Point;

public class AisDetailsWindow extends NativeWindow {
    protected static var options:NativeWindowInitOptions;

    public function AisDetailsWindow(w:int, h:int) {
        createOptions()
        super(options);
        this.stage.align = StageAlign.TOP_LEFT;
        this.stage.scaleMode = StageScaleMode.NO_SCALE;
        this.width = w;
        this.height = h;
        this.minSize = new Point(w, h)
        this.alwaysInFront = true;
    }

    private function createOptions():void {
        if (options == null) {
            options = new NativeWindowInitOptions();
            options.systemChrome = NativeWindowSystemChrome.NONE
            options.type = NativeWindowType.LIGHTWEIGHT
            options.transparent = false;
            options.resizable = false;
            options.maximizable = false;
            options.renderMode = AppProperties.renderMode

        }
    }
}
}
