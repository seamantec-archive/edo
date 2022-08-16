/**
 * Created by seamantec on 09/02/15.
 */
package com.ui.controls {
public class CloudBtn extends BitmapButton {

    [Embed(source="../../../../assets/images/settings_btn0.png")]
    private static var Btn0:Class;
    [Embed(source="../../../../assets/images/settings_btn1.png")]
    private static var Btn1:Class;
    [Embed(source="../../../../assets/images/settings_longbtn0.png")]
    private static var LongBtn0:Class;
    [Embed(source="../../../../assets/images/settings_longbtn1.png")]
    private static var LongBtn1:Class;

    public static const TYPE_SIMPLE:uint = 0;
    public static const TYPE_LONG:uint = 1;

    public function CloudBtn(type:uint, label:String = "", fontSize:uint = 11) {
        var btn0:Class;
        var btn1:Class;
        if(type==TYPE_SIMPLE) {
            btn0 = Btn0;
            btn1 = Btn1;
        } else {
            btn0 = LongBtn0;
            btn1 = LongBtn1;
        }
        super(btn0, btn0, btn1, btn1, btn0, label, null, fontSize);
    }
}
}
