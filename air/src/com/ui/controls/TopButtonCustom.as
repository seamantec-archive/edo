
/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.03.22.
 * Time: 12:16
 * To change this template use File | Settings | File Templates.
 */
package com.ui.controls {
public class TopButtonCustom extends BitmapButton {
    [Embed(source='../../../../assets/images/layoutsw_btn0.png')]
    static const upStateClass:Class;
    [Embed(source='../../../../assets/images/layoutsw_btn1.png')]
    static const disabledStateClass:Class;
    [Embed(source='../../../../assets/images/layoutsw_btn2.png')]
    static const overStateClass:Class;
    [Embed(source='../../../../assets/images/layoutsw_btn3.png')]
    static const downStateClass:Class;

    public function TopButtonCustom(iconClass:Class = null, label:String = "") {
        super(upStateClass, overStateClass, downStateClass, downStateClass, disabledStateClass, label, iconClass);
        this.resetStates();
        this.enabled = true;


    }
}

}
