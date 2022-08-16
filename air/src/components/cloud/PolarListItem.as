/**
 * Created by seamantec on 04/02/15.
 */
package components.cloud {
import com.common.AppProperties;
import com.harbor.PolarFile;
import com.polar.PolarContainer;
import com.polar.PolarEvent;
import com.utils.FontFactory;

import components.list.ListItem;

import flash.events.Event;

import flash.events.MouseEvent;
import flash.filesystem.File;

public class PolarListItem extends ListItem {

    [Embed(source="../../../assets/images/msglist/closedlist_element.png")]
    private static var closed:Class;

    public static const HEIGHT:int = 24;

    private var _polarFile:PolarFile;

    private var _active:Boolean;

    public function PolarListItem(polarFile:PolarFile) {
        super(PolarWindow.WIDTH, HEIGHT, 0x0);

        _polarFile = polarFile;

        addLabel(_polarFile.name, FontFactory.nmeaMSGfont(), 7,2);

        deactivate();

        this.addEventListener(MouseEvent.CLICK, selectHandler);
    }

    public function get polarFile():PolarFile {
        return _polarFile;
    }

    public function get id():String {
        return _polarFile.id;
    }

    public function get active():Boolean {
        return _active;
    }

    public function deactivate():void {
        activate(false);
    }

    public function activate(active:Boolean = true):void {
        _active = active;

        this.graphics.clear();
        this.graphics.beginBitmapFill(new closed().bitmapData);
        this.graphics.drawRect(0,0, PolarWindow.WIDTH, HEIGHT);
        if(active) {
            this.graphics.beginFill(0x17456b, 0.5);
            this.graphics.drawRect(0, 0, PolarWindow.WIDTH, HEIGHT);
            this.getLabel(0).textColor = 0xffffff;
        } else {
            this.getLabel(0).textColor = 0x000000;
        }
        this.graphics.endFill();
    }

    private function selectHandler(event:MouseEvent):void {
        if(_polarFile.hasFile() && AppProperties.polarWin.selected!=_polarFile) {
            PolarContainer.instance.addEventListener(PolarEvent.POLAR_FILE_LOADED, polarFileLoadedHandler, false, 0, true);
            PolarContainer.instance.addEventListener("bad-extension", polarFileWarningHandler, false, 0, true);
            PolarContainer.instance.addEventListener("bad-file", polarFileWarningHandler, false, 0, true);
            PolarContainer.instance.addEventListener("too-large", polarFileWarningHandler, false, 0, true);
            PolarContainer.instance.openPolarFromFile(new File(_polarFile.filePath), false, _polarFile.name + "." + _polarFile.extension);
        }
    }

    private function polarFileLoadedHandler(event:PolarEvent):void {
        if(AppProperties.polarWin.selected!=_polarFile) {
            AppProperties.polarWin.deactivate();
            activate();

            AppProperties.polarWin.selected = _polarFile;
            AppProperties.polarWin.setButtons();
        }

        PolarContainer.instance.removeEventListener(PolarEvent.POLAR_FILE_LOADED, polarFileLoadedHandler, false);
        PolarContainer.instance.removeEventListener("bad-extension", polarFileWarningHandler, false);
        PolarContainer.instance.removeEventListener("bad-file", polarFileWarningHandler, false);
        PolarContainer.instance.removeEventListener("too-large", polarFileWarningHandler, false);
    }

    private function polarFileWarningHandler(event:Event):void {
        PolarContainer.instance.removeEventListener(PolarEvent.POLAR_FILE_LOADED, polarFileLoadedHandler, false);
        PolarContainer.instance.removeEventListener("bad-extension", polarFileWarningHandler, false);
        PolarContainer.instance.removeEventListener("bad-file", polarFileWarningHandler, false);
        PolarContainer.instance.removeEventListener("too-large", polarFileWarningHandler, false);
    }
}
}
