/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.04.03.
 * Time: 13:36
 * To change this template use File | Settings | File Templates.
 */
package com.ui.controls {
public class AlarmDownBtn extends BitmapButton {
    [Embed(source="../../../../assets/images/alarmlist/btn1_up.png")]
    private static var btnUp:Class;
    [Embed(source="../../../../assets/images/alarmlist/btn1_down.png")]
    private static var btnDown:Class;
    [Embed(source="../../../../assets/images/alarmlist/btn1_dis.png")]
    private static var btnDis:Class;

    public function AlarmDownBtn(label:String = "", fontSize:uint = 12, alphaDisabled:Boolean = false) {
        super(btnUp, btnDown, btnDown, btnDown, btnDis, label, null, fontSize, 0xDEDEDE, "center", 0, true, alphaDisabled);
    }
}
}
