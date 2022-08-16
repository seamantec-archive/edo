/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.03.21.
 * Time: 16:00
 * To change this template use File | Settings | File Templates.
 */
package com.ui {
import com.layout.LayoutHandler;
import com.sailing.WindowsHandler;
import com.ui.controls.TopButtonCustom;

import flash.display.Sprite;
import flash.events.MouseEvent;

public class LayoutChangeBar extends Sprite {

    /*
     *
     * 	<s:BitmapImage source="@Embed(source='../../../assets/images/layoutsw_btn0.png')" includeIn="up " />
     <s:BitmapImage source="@Embed(source='../../../assets/images/layoutsw_btn1.png')" includeIn="disabled" />
     <s:BitmapImage source="@Embed(source='../../../assets/images/layoutsw_btn2.png')" includeIn="over" />
     <s:BitmapImage source="@Embed(source='../../../assets/images/layoutsw_btn3.png')" includeIn="down" />
     * */

    [Embed(source='../../../assets/images/layoutsw_btn0.png')] var upState:Class;
    [Embed(source='../../../assets/images/layoutsw_btn1.png')] var disabledState:Class;
    [Embed(source='../../../assets/images/layoutsw_btn2.png')] var overState:Class;
    [Embed(source='../../../assets/images/layoutsw_btn3.png')] var downState:Class;
    [Embed(source='../../../assets/images/ico_sailing.png')] var iconSh:Class;
    [Embed(source='../../../assets/images/ico_navigating.png')] var iconWh:Class;
    [Embed(source='../../../assets/images/ico_racing.png')] var iconSt:Class;

    private var ship:TopButtonCustom;
    private var wheel:TopButtonCustom;
    private var stopwatch:TopButtonCustom;
    private var usr1:TopButtonCustom;
    private var usr2:TopButtonCustom;
    private var usr3:TopButtonCustom;
    private var usr4:TopButtonCustom;

    public function LayoutChangeBar(offsetX:int) {
        this.x = offsetX;
        createButtons();
        init()


    }

    private function createButtons():void {
        var buttonWidthPlusOffset:int = 30;
        ship = new TopButtonCustom(iconSh);
        ship.x = 0;
        ship.y = 2;
        ship.id = "ship"
        ship.addEventListener(MouseEvent.CLICK, buttonClickHandler, false, 0, true);
        addChild(ship)

        wheel = new TopButtonCustom(iconWh);
        wheel.x = buttonWidthPlusOffset;
        wheel.y = 2;
        wheel.id = "wheel"
        wheel.addEventListener(MouseEvent.CLICK, buttonClickHandler, false, 0, true);
        addChild(wheel)

        stopwatch = new TopButtonCustom(iconSt);
        stopwatch.x = buttonWidthPlusOffset*2;
        stopwatch.y = 2;
        stopwatch.id = "stopwatch"
        stopwatch.addEventListener(MouseEvent.CLICK, buttonClickHandler, false, 0, true);
        addChild(stopwatch)
        usr1 = new TopButtonCustom(null, "1");
        usr1.x = buttonWidthPlusOffset*3;
        usr1.y = 2;
        usr1.id = "usr1"
        usr1.addEventListener(MouseEvent.CLICK, buttonClickHandler, false, 0, true);
        addChild(usr1)

        usr2 = new TopButtonCustom(null, "2");
        usr2.x = buttonWidthPlusOffset*4;
        usr2.y = 2;
        usr2.id = "usr2"
        usr2.addEventListener(MouseEvent.CLICK, buttonClickHandler, false, 0, true);
        addChild(usr2)

        usr3 = new TopButtonCustom(null, "3");
        usr3.x = buttonWidthPlusOffset*5;
        usr3.y = 2;
        usr3.id = "usr3"
        usr3.addEventListener(MouseEvent.CLICK, buttonClickHandler, false, 0, true);
        addChild(usr3)

        usr4 = new TopButtonCustom(null, "4");
        usr4.x = buttonWidthPlusOffset*6;
        usr4.y = 2;
        usr4.id = "usr4"
        usr4.addEventListener(MouseEvent.CLICK, buttonClickHandler, false, 0, true);
        addChild(usr4)


    }

    protected function buttonClickHandler(event:MouseEvent):void {
        if (LayoutHandler.instance.editMode) {
            LayoutHandler.instance.editEnabled = false;
        } else {
           // LayoutHandler.instance.activeLayout.saveLayout();
        }
        //LayoutHandler.instance.activeLayout.closeAllWindows()
        LayoutHandler.instance.activeBtn = event.target as TopButtonCustom;
        LayoutHandler.instance.switchLayout();
    }

    protected function init():void {
        WindowsHandler.instance.loadSavedBarButton();
        var name:String = LayoutHandler.instance.loadedButtonName;
        if (name != "" && name != null) {
            LayoutHandler.instance.activeBtn = this[name];
        } else {
            LayoutHandler.instance.activeBtn = this["ship"];
        }
    }

    private function muteBtn_clickHandler(event:MouseEvent):void {
        event.currentTarget.enabled = !event.currentTarget.enabled;
    }
}
}
