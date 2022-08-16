/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.11.
 * Time: 12:34
 * To change this template use File | Settings | File Templates.
 */
package components.ais {
import com.common.AppProperties;
import com.events.AisVesselSelected;
import com.layout.Layout;
import com.layout.LayoutHandler;
import com.sailing.ais.AisContainer;
import com.sailing.ais.Vessel;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;

public class AisComponent extends Sprite implements IAisComponent {
    private var coordinateSystem:AisCoordinateSystem;
    [Embed(source="../../../assets/images/ais.png")]
    private static var aisBg:Class;
    private var _layout:Layout;
    private var _width:Number = 400;
    private var _height:Number = 400;
    public function AisComponent() {

        setBackground();
        coordinateSystem = new AisCoordinateSystem(this);
//        coordinateSystem.addEventListener("maxDistanceChanged", coordinateSystem_maxDistanceChangedHandler);
        AisContainer.instance.addEventListener("own-ship-heading-changed", ownShipHeadingChangedHandler, false, 0, true);
        AisContainer.instance.addEventListener(AisVesselSelected.AIS_VESSEL_SELECTED, aisVesselSelectedMMSIHandler, false, 0, true);

        this.addChild(coordinateSystem);
        this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true);
    }


    private var bg:Sprite;
    private var bgBitmap:MovieClip;

    public function isParentClosed():Boolean {
        if (_layout.isFullscreen) {
            return false;
        } else {
            return stage.nativeWindow.closed
        }
    }

    public function getParentBounds():Rectangle {
        if (_layout.isFullscreen) {
            return new Rectangle(parent.x, parent.y, parent.width, parent.height)
        } else {
            return new Rectangle(stage.nativeWindow.x, stage.nativeWindow.y, stage.nativeWindow.width, stage.nativeWindow.height);
        }
    }


    public function isEnoughSpaceOnTheRight():Boolean {
        if (_layout.isFullscreen) {
            return parent.x + parent.width + AisDetails.INFO_WIDTH < AppProperties.screenWidth
        } else {
            return stage.nativeWindow.x + stage.nativeWindow.width + AisDetails.INFO_WIDTH < AppProperties.screenWidth
        }
    }


    public function isEnoughSpaceOnTheLeft():Boolean {
        if (_layout.isFullscreen) {
            return parent.x - AisDetails.INFO_WIDTH > 0;
        } else {
            return stage.nativeWindow.x - AisDetails.INFO_WIDTH > 0;
        }

    }

    public function setBackground():void {
        bg = new Sprite();

        bgBitmap = new ais();
        bgBitmap.y = 0;
        bgBitmap.x = 0;
        addClickListeners();
//        bg.x = 0
//        bg.y = 0
        bg.addChild(bgBitmap)
        this.addChild(bg);
        drawBgBg()
    }

    private function drawBgBg():void {
        bg.graphics.clear();
        bg.graphics.beginFill(0xff00ff, 0.0)
        bg.graphics.drawRect(0, 0, _width, _height)

    }

    private function addClickListeners():void {
        bgBitmap.analog.zoom_minus_switch_btn.addEventListener("custom-click", minusClickHandler, false, 0, true);
        bgBitmap.analog.zoom_plus_switch_btn.addEventListener("custom-click", plusClickHandler, false, 0, true);
    }

    private function removeClickListeners():void {
        bgBitmap.analog.zoom_minus_switch_btn.removeEventListener("custom-click", minusClickHandler);
        bgBitmap.analog.zoom_plus_switch_btn.removeEventListener("custom-click", plusClickHandler);
    }

    public function resize(w:int, h:int):void {
//        this.height = h;
//        this.width = w;
        this._width = w;
        this._height = h
        drawBgBg()
        coordinateSystem.visible = false;
        coordinateSystem.resize(w)
        coordinateSystem.visible = true;
//
        bgBitmap.height = w;
        bgBitmap.width = h;
    }


    private function ownShipHeadingChangedHandler(event:Event):void {
        if (isNaN(AisContainer.instance.ownShip.heading)) {
            return;
        }
        (bgBitmap.analog.heading as MovieClip).rotation = -AisContainer.instance.ownShip.heading;
    }

    private function minusClickHandler(event:Event):void {
        /**
         * frame 1: 10,20,30 nm
         * frame10: 5,10 nm
         * frame20: 2,4,6 nm
         * frame30: 1,2 nm
         */
        var frameFrom:int = 0;
        var frameTo:int = 0;
        var tempMaxDistance:int = 0
        switch (coordinateSystem.max_distance) {
            case 30:
                frameFrom = 1
                frameTo = 1;
                tempMaxDistance = 30;
                break;
//            case 20:
//                tempMaxDistance = 30;
//                frameFrom = 6;
//                frameTo = 1;
//                break;
            case 10:
                tempMaxDistance = 30;
                frameFrom = 10;
                frameTo = 1;
                break;
            case 6:
                tempMaxDistance = 10;
                frameFrom = 20
                frameTo = 10;
                break;
            case 2:
                tempMaxDistance = 6;
                frameFrom = 30;
                frameTo = 20;
                break;
        }
        playAnim(frameFrom, frameTo)
        coordinateSystem.max_distance = tempMaxDistance;
    }

    private function plusClickHandler(event:Event):void {
        /**
         * frame 1: 10,20,30 nm
         * frame10: 5,10 nm
         * frame20: 2,4,6 nm
         * frame30: 1,2 nm
         */
        var frameTo:int = 0;
        var frameFrom:int = 0;
        var tempMaxDistance:int = 0
        switch (coordinateSystem.max_distance) {
            case 30:
                tempMaxDistance = 10;
                frameFrom = 1;
                frameTo = 10;
                break;
//            case 20:
//                tempMaxDistance = 10;
//                frameFrom = 6;
//                frameTo = 10;
//                break;
            case 10:
                tempMaxDistance = 6;
                frameFrom = 10;
                frameTo = 20;
                break;
            case 6:
                tempMaxDistance = 2;
                frameFrom = 20;
                frameTo = 30;
                break;
            case 2:
                tempMaxDistance = 2;
                frameFrom = 30;
                frameTo = 30;
                break;
        }
        playAnim(frameFrom, frameTo)
        coordinateSystem.max_distance = tempMaxDistance;
    }

    private var moveAnimTo:int = 0;
    private var animDirectionIsFor:Boolean = true;

    private function playAnim(from:int, to:int):void {
        if (from > to) {
            animDirectionIsFor = false;
        } else {
            animDirectionIsFor = true;
        }
        moveAnimTo = to;

        removeClickListeners();
        (bgBitmap.analog.zoomanim as MovieClip).addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
    }

    private function enterFrameHandler(event:Event):void {
        if (bgBitmap.analog.zoomanim.currentFrame === moveAnimTo) {
            (bgBitmap.analog.zoomanim as MovieClip).removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
            addClickListeners();
            return;
        }
        if (animDirectionIsFor) {
            (bgBitmap.analog.zoomanim as MovieClip).gotoAndStop(bgBitmap.analog.zoomanim.currentFrame + 1)
        } else {
            (bgBitmap.analog.zoomanim as MovieClip).gotoAndStop(bgBitmap.analog.zoomanim.currentFrame - 1)
        }
    }

    private function addedToStageHandler(event:Event):void {
        if (!LayoutHandler.instance.activeLayout.isFullscreen) {
            stage.nativeWindow.addEventListener("controlMoveStarted", parent_controlMoveStartedHandler, false, 0, true);
        }
    }

    private function parent_controlMoveStartedHandler(event:Event):void {
        LayoutHandler.instance.activeLayout.deselectVessel();
    }

    public function get layout():Layout {
        return _layout;
    }

    public function set layout(value:Layout):void {
        _layout = value;
    }

    private function aisVesselSelectedMMSIHandler(event:AisVesselSelected):void {
        var isShipInCoordinateSystem:Boolean = coordinateSystem.setShipSelected(event.mmsi);
        if (isShipInCoordinateSystem) {
            if (_layout.isActiveLayout()) {
                if (event.mmsi != null) {
                    openShipDetails(event.mmsi)
                } else {
                    LayoutHandler.instance.activeLayout.closeAisDetails();
                }
            }
        } else {
            LayoutHandler.instance.activeLayout.closeAisDetails();
        }
    }

    public function openShipDetails(mmsi:String):void {
        if (isParentClosed()) {
            return;
        }

        var parentBounds:Rectangle = getParentBounds();
        var ship:Vessel = AisContainer.instance.container[mmsi] as Vessel;
        if (isEnoughSpaceOnTheRight()) {
            LayoutHandler.instance.activeLayout.openAisDetails(ship, this.width + parentBounds.x, parentBounds.y)
        } else if (isEnoughSpaceOnTheLeft()) {
            LayoutHandler.instance.activeLayout.openAisDetails(ship, parentBounds.x - AisDetails.INFO_WIDTH, parentBounds.y)
        } else {
            LayoutHandler.instance.activeLayout.openAisDetails(ship, parentBounds.x, parentBounds.y);
        }
    }

    public function removeAllListeners():void {
        AisContainer.instance.removeEventListener("own-ship-heading-changed", ownShipHeadingChangedHandler);
        AisContainer.instance.removeEventListener(AisVesselSelected.AIS_VESSEL_SELECTED, aisVesselSelectedMMSIHandler);
    }


    override public function get width():Number {
        return _width;
    }


    override public function get height():Number {
        return _height;
    }


    public function get originWidth():Number {
        return _width;
    }

    public function get originHeight():Number {
        return _height;
    }
}
}
