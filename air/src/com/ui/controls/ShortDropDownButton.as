/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.01.
 * Time: 16:55
 * To change this template use File | Settings | File Templates.
 */
package com.ui.controls {
public class ShortDropDownButton extends BitmapButton {

    [Embed(source="../../../../assets/images/Layout pngs/dropdown_small_02.png")]
    private static var dropDown02:Class;
    [Embed(source="../../../../assets/images/Layout pngs/dropdown_small_03.png")]
    private static var dropDown03:Class;

    public function ShortDropDownButton(margin:Number = 0) {
        super(dropDown02, dropDown03, dropDown03, dropDown03, dropDown02, "", null, 12, 0xDEDEDE, "left", margin);
    }

    public override function resetStates():void {
        if (enabled && _customEnabled) {
            this.upState = initUpState;
            this.overState = initOverState
            this.downState = initDownState
            this.hitTestState = initHitTestState
        } else {
            this.upState = initDisableState;
            this.overState = initOverState
            this.downState = initDownState
            this.hitTestState = initHitTestState;
        }
        this.useHandCursor = true;
    }


}
}
