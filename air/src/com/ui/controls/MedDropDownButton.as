/**
 * Created by pepusz on 2014.08.04..
 */
package com.ui.controls {
public class MedDropDownButton extends BitmapButton {
    [Embed(source="../../../../assets/images/Layout pngs/dropdown_med_02.png")]
    private static var dropDown02:Class;
    [Embed(source="../../../../assets/images/Layout pngs/dropdown_med_03.png")]
    private static var dropDown03:Class;
//    [Embed(source="../../../../assets/images/Layout pngs/dropdown_03.png")]
//    private static var dropDown03:Class;

    public function MedDropDownButton() {
        super(dropDown02, dropDown03, dropDown03, dropDown03, dropDown03, "", null, 12, 0xDEDEDE, "left");
    }

    public override function resetStates():void {
        if (enabled && _customEnabled) {
            this.upState = initUpState;
            this.overState = initOverState;
            this.downState = initDownState;
            this.hitTestState = initHitTestState
        } else {
            this.upState = initDisableState;
            this.overState = initOverState;
            this.downState = initDownState;
            this.hitTestState = initHitTestState;
        }
        this.useHandCursor = true;
    }

}
}
