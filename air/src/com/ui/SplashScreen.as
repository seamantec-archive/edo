/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.03.21.
 * Time: 14:40
 * To change this template use File | Settings | File Templates.
 */
package com.ui {
import com.common.AppProperties;
import com.utils.FontFactory;

import flash.display.NativeWindow;
import flash.display.NativeWindowInitOptions;
import flash.display.NativeWindowSystemChrome;
import flash.display.NativeWindowType;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.system.Capabilities;
import flash.text.TextField;

public class SplashScreen extends NativeWindow {
    public static const W_HEIGHT:int = 436;
    public static const W_WIDTH:int = 650;
    [Embed(source="../../../assets/loading.png")]
    var loadingPng:Class;
    public function SplashScreen() {
        var options:NativeWindowInitOptions = new NativeWindowInitOptions();
        options.systemChrome = NativeWindowSystemChrome.NONE
        options.type = NativeWindowType.NORMAL
        options.transparent = true;
        options.resizable = false;
        options.maximizable = false;
        options.renderMode = AppProperties.renderMode
        super(options);
        this.stage.align = StageAlign.TOP_LEFT;
        this.stage.scaleMode = StageScaleMode.NO_SCALE;

        this.width = W_WIDTH;
        this.height = W_HEIGHT;
        this.x = Capabilities.screenResolutionX/2-W_WIDTH/2
        this.y = Capabilities.screenResolutionY/2-W_HEIGHT/2

        this.addEventListener(Event.ACTIVATE, activateHandler, false, 0, true);
    }

    private function addVersionText():void{
        var version:TextField = FontFactory.getCustomFont({color:0xe9a909,size:18, align:"left", autoSize: "left", selectable:false});
        version.text = "v"+AppProperties.getVersionLabel();
        version.y = 41;
        version.x = 435;
        this.stage.addChild(version);
    }

    private function activateHandler(event:Event):void {
        stage.addChild(new loadingPng());
        addVersionText();
    }
}
}
