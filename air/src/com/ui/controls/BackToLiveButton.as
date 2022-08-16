/**
 * Created by seamantec on 04/08/14.
 */
package com.ui.controls {
public class BackToLiveButton extends ZoomButton {

    [Embed(source='../../../../assets/images/backtolive_icon.png')]
    static const icon:Class;

    public function BackToLiveButton() {
        super(icon,"");
        this.resetStates();
        this.enabled = true;
    }
}
}
