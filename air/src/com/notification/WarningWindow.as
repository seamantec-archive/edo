/**
 * Created by seamantec on 03/07/14.
 */
package com.notification {

import com.events.AppClick;
import flash.events.MouseEvent;

public class WarningWindow extends NotificationWindow {

    [Embed(source="../../../assets/images/exclamation_yellow.png")]
    private static var iconPNG:Class;

    public function WarningWindow(type:int, msg:String, priority:int, options:Object) {
        super(type, msg, priority, (options!=null && options.hasOwnProperty("title")) ? options["title"] : "Warning", iconPNG);

        this.addDownButton(2, "OK", close_clickHandler);
    }

    protected override function close_clickHandler(event:MouseEvent):void {
        NotificationHandler.close(this);
        this.close();
        dispatchEvent(new AppClick(event.target));
    }
}
}
