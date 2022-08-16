/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.05.
 * Time: 14:27
 * To change this template use File | Settings | File Templates.
 */
package com.ui.controls {
public class ZoomButton extends BitmapButton {
    [Embed(source='../../../../assets/images/grzoom_btn0.png')]
    static const upStateClass:Class;
    [Embed(source='../../../../assets/images/grzoom_btn1.png')]
    static const disabledStateClass:Class;
    [Embed(source='../../../../assets/images/grzoom_btn2.png')]
    static const overStateClass:Class;
    [Embed(source='../../../../assets/images/grzoom_btn3.png')]
    static const downStateClass:Class;

    public function ZoomButton(iconClass:Class = null, label:String = "") {

        // up. over. down. hittest. disabled.
        super(upStateClass, overStateClass, downStateClass, downStateClass, disabledStateClass, label, iconClass);
        this.resetStates();
        this.enabled = true;


    }
}
}
