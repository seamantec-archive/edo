/**
 * Created by seamantec on 16/07/14.
 */
package com.notification {

import com.common.AppProperties;
import com.events.AppClick;
import com.utils.FontFactory;

import components.windows.FloatWindow;

import flash.display.Bitmap;
import flash.display.NativeWindowInitOptions;
import flash.display.NativeWindowSystemChrome;
import flash.display.NativeWindowType;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;

public class NotificationWindow extends FloatWindow {

    private var _type:int;
    private var _priority:int;

    public function NotificationWindow(type:int, msg:String, priority:int, title:String, iconPNG:Class) {
        super(title);
        this.alwaysInFront = true;
        this.addEventListener(Event.CLOSING, closingHandler, false, 0, true);
        _type = type;
        _priority = priority;

        var field:TextField = FontFactory.getCustomFont({ color: 0x000000, size: 15 });
        field.x = 30;
        field.y = 30;
        field.text = msg;
        _content.addChild(field);

        var icon:Bitmap = new Bitmap((new iconPNG() as Bitmap).bitmapData);
        icon.x = 9;
        icon.y = 32;
        icon.width = 19;
        icon.height = 16;
        _content.addChild(icon);

        this.resizeable = false;
        var h:Number = field.textHeight + 60 + _frame.getHeightAndContentDiff();
        this.resize(L_WIDTH + _frame.getWidthAndContentDiff(), (h < MIN_HEIGHT) ? MIN_HEIGHT : h);
        this.width = _w;
        this.height = _h;
        this.repositionElements();

        _content.graphics.beginFill(0xffffff);
        _content.graphics.drawRect(0, 0, _content.width, _content.height);
        _content.graphics.endFill();

        field.width = _content.width - 30;

        this.setTitleX(_frame.windowBottomSprite.x - 10);
    }

//    protected override function createOptions():void {
//        if (options == null) {
//            options = new NativeWindowInitOptions();
//            options.systemChrome = NativeWindowSystemChrome.NONE
//            options.type = NativeWindowType.NORMAL;
//            options.transparent = true;
//            options.resizable = false;
//            options.maximizable = false;
//            options.renderMode = AppProperties.renderMode
//            options.owner = null;
//        }
//    }

    protected override function close_clickHandler(event:MouseEvent):void {
        NotificationHandler.close(this);
        this.close();
        dispatchEvent(new AppClick(event.target));
    }

    public function getType():int {
        return _type;
    }

    public function getPriority():int {
        return _priority;
    }

    private function closingHandler(event:Event):void {
        event.preventDefault();
        NotificationHandler.close(this);
        this.close();
        dispatchEvent(new AppClick(event.target));
    }
}
}
