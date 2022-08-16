/**
 * Created by seamantec on 03/07/14.
 */
package com.notification {

import com.events.AppClick;
import flash.events.MouseEvent;

public class AlertWindow extends NotificationWindow {

    [Embed(source="../../../assets/images/exclamation_red.png")]
    private static var iconPNG:Class;

    private var _noCallback;
    private var _yesCallback;

    public function AlertWindow(type:int, msg:String, priority:int, yesCallback:Function, noCallback:Function, options:Object) {
        super(type, msg, priority, (options!=null && options.hasOwnProperty("title")) ? options["title"] : "Confirmation", iconPNG);

        _noCallback = noCallback;
        _yesCallback = yesCallback;

        this.addDownButton(1, "Yes", yes_clickHandler);
        this.addDownButton(2, "No", close_clickHandler);
    }

    private function yes_clickHandler(event:MouseEvent):void {
        _yesCallback.call();
        closeWindow(event);
    }

    protected override function close_clickHandler(event:MouseEvent):void {
        if(_noCallback!=null) {
            _noCallback.call();
        }
        closeWindow(event);
    }

    private function closeWindow(event:MouseEvent):void {
        NotificationHandler.close(this);
        this.close();
        dispatchEvent(new AppClick(event.target));
    }
}
}
