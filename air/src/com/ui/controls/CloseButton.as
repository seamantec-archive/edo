/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.04.03.
 * Time: 12:13
 * To change this template use File | Settings | File Templates.
 */
package com.ui.controls {
public class CloseButton extends BitmapButton {
    [Embed(source="../../../../assets/images/alarmlist/window_close_up.png")]
    private static var closeUp:Class;
    [Embed(source="../../../../assets/images/alarmlist/window_close_down.png")]
    private static var closeDown:Class;

    public function CloseButton() {
        super(closeUp, closeDown, closeDown, closeDown,closeDown);
    }
}
}
