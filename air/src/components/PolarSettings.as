/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.11.20.
 * Time: 10:34
 * To change this template use File | Settings | File Templates.
 */
package components {
import com.polar.PolarContainer;
import com.polar.PolarTable;
import com.ui.controls.Slider;
import com.utils.FontFactory;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;

public class PolarSettings extends Sprite {

    public function PolarSettings() {
        super();
        PolarContainer.instance;
        initControls();

    }

    public function hide():void {
        this.visible = false;
    }



    private function initControls():void {

        var l1:TextField = FontFactory.getLeftTextField();
        l1.text = "Horizontal Interpolation";
        l1.x = 10;
        l1.y = 10;
        this.addChild(l1);
        var hinterpolation:ToggleButtonBar = new ToggleButtonBar(10, 30, ["on", "off"], 12);
        hinterpolation.selectedIndex = PolarTable.horizontalInterpolationEnabled ? 0 : 1;
        hinterpolation.addEventListener(MouseEvent.CLICK, function (event:MouseEvent) {
            PolarContainer.instance.onOffHorizontalInterpolation(event.currentTarget.selectedIndex === 0 ? true : false);

        }, false, 0, true)

        var l2:TextField = FontFactory.getLeftTextField();
        l2.text = "Vertical Interpolation";
        l2.x = 200;
        l2.y = 10;
        this.addChild(l2);
        var vertical:ToggleButtonBar = new ToggleButtonBar(200, 30, ["on", "off"], 12);
        vertical.selectedIndex = PolarTable.verticalInterpolationEnabled ? 0 : 1;
        vertical.addEventListener(MouseEvent.CLICK, function (event:MouseEvent) {
            PolarContainer.instance.onOffVerticalInterpolation(event.currentTarget.selectedIndex === 0 ? true : false);

        }, false, 0, true)
        this.addChild(hinterpolation);
        this.addChild(vertical);

        addSlider(0, polarx_actualValueChangedHandler, 0, 3, 0.1, "white max force", PolarTable.measuredMaxWeight);
        addSlider(1, polarInterpolatedWeight_actualValueChangedHandler, 0, 30, 1, "forcefields", PolarTable.vInterpolatedWeight);
//        addSlider(2, hinterpolated_actualValueChangedHandler, 1, 30, 1, "h suly", PolarTable.hInterpolatedWeight);
//        addSlider(3, minterpolated_actualValueChangedHandler, 1, 30, 1, "mnagys", PolarTable.mInterpolatedWeight);
        addSlider(2, wangle_ChangeHandler, 0, 30, 2, "wangle", PolarTable.angleAvg);


        var l3:TextField = FontFactory.getLeftTextField();
        l3.x = 10;
        l3.y = 340;
        l3.text = "Wind filter";


        var tg1:ToggleButtonBar = new ToggleButtonBar(10, 360, ["off", "light", "med.", "hard"], 12);
        tg1.selectedIndex = PolarContainer.instance.windFilterSelectedIndex;
        tg1.addEventListener(MouseEvent.CLICK, function (event:MouseEvent) {
            PolarContainer.instance.setWindFilter(event.currentTarget.selectedIndex);
        }, false, 0, true);
        this.addChild(tg1);
        this.addChild(l3);


        var l4:TextField = FontFactory.getLeftTextField();
        l4.text = "Show force fields";
        l4.x = 10;
        l4.y = 405;
        this.addChild(l4);
        var ffields:ToggleButtonBar = new ToggleButtonBar(10, 425, ["on", "off"], 12);
        ffields.selectedIndex = PolarTable.showForceFields ? 0 : 1;
        ffields.addEventListener(MouseEvent.CLICK, function (event:MouseEvent) {
            PolarContainer.instance.showForceFields = event.currentTarget.selectedIndex === 0 ? true : false;

        }, false, 0, true)
        this.addChild(ffields)


    }


    private function addSlider(i:int, handler:Function, min:uint, max:uint, step:Number, labelTxt:String, avalue:Number):void {
        var slider:Slider = new Slider(min, max, step, 250, Slider.LOW_LIMIT);
        slider.y = 120 + i * 80;
        slider.x = 10;
        slider.actualValue = avalue
        var label:TextField = FontFactory.getLeftTextField();
        label.x = 10;
        label.y = 80 + i * 80;
        label.text = labelTxt;

        slider.addEventListener("actualValueChanged", handler, false, 0, true);
        this.addChild(slider);
        this.addChild(label)
    }

    private function polarx_actualValueChangedHandler(event:Event):void {
        PolarContainer.instance.changemeasuerdWeights((event.currentTarget as Slider).actualValue)
    }

    private function polarInterpolatedWeight_actualValueChangedHandler(event:Event):void {
        PolarContainer.instance.changemeasuerdVInterpolatedWeights((event.currentTarget as Slider).actualValue)
    }

    private function hinterpolated_actualValueChangedHandler(event:Event):void {
        PolarContainer.instance.changemeasuerdHInterpolatedWeights((event.currentTarget as Slider).actualValue)
    }

    private function minterpolated_actualValueChangedHandler(event:Event):void {
        PolarContainer.instance.changemeasuerdMInterpolatedWeights((event.currentTarget as Slider).actualValue)
    }

    private function wangle_ChangeHandler(event:Event):void {
        var value:int = (event.currentTarget as Slider).actualValue;
        if (value === 0) {
            value = 1
        }
        PolarContainer.instance.wAngle(value)
    }



}
}
