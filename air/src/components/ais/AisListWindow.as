/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.10.07.
 * Time: 14:57
 * To change this template use File | Settings | File Templates.
 */
package components.ais {
import com.utils.FontFactory;

import components.alarm.Badge;
import components.windows.FloatWindow;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;

public class AisListWindow extends FloatWindow {
    public static const HEADER_HEIGHT:uint = 20;
    protected static var lastHeight:int = -1;
    protected static var _aisList:AisList;
    protected static var _header:Sprite;
    private var _underWayBubble:Badge;


    public function AisListWindow() {
        super("Ais vessel list");
        if (_aisList === null) {
            _aisList = new AisList();
        }
        this.resizeable = false;
        _content.addChild(_aisList);
        createListHeader();
        this.addEventListener(Event.CLOSE, closeHandler, false, 0, true);
        createDownButtons();
        if(_aisList.isAllView()) {
            disableDownButton(0);
        } else {
            disableDownButton(1);
        }
        _aisList.isWindowOpen = true;
        _aisList.addEventListener("UnderWayCounterChanged", aisList_UnderWayCounterChangedHandler, false, 0, true);
    }

    private function createListHeader():void {
        if (_header === null) {
            _header = new Sprite();
            _header.graphics.beginFill(0xffffff);
            _header.graphics.drawRect(0, 0, FloatWindow.L_WIDTH, HEADER_HEIGHT);
            _header.graphics.endFill();
            _header.x = 0;
            _header.y = 0;

            var name:TextField = FontFactory.getCustomFont({size: 12, color: 0x267ba1, align: "left", autoSize: "left"})
            name.text = "Name"
            name.x = 26;
            _header.addChild(name);

            var brg:TextField = FontFactory.getCustomFont({size: 12, color: 0x267ba1, align: "left", autoSize: "left"})
            brg.text = "Brg."
            brg.x = 126;
            _header.addChild(brg);

            var dist:TextField = FontFactory.getCustomFont({size: 12, color: 0x267ba1, align: "left", autoSize: "left"})
            dist.text = "Distance"
            dist.x = 161;
            _header.addChild(dist);

            var cog:TextField = FontFactory.getCustomFont({size: 12, color: 0x267ba1, align: "left", autoSize: "left"})
            cog.text = "COG"
            cog.x = 226;
            _header.addChild(cog);
            var sog:TextField = FontFactory.getCustomFont({size: 12, color: 0x267ba1, align: "left", autoSize: "left"})
            sog.text = "SOG"
            sog.x = 256;
            _header.addChild(sog);
        }
        _content.addChild(_header);
    }

    private function createDownButtons():void {
//        downButtonsContainer = new Sprite();
//        positionateDownButtons(this.height);
//        var allVessels:AlarmDownBtn = new AlarmDownBtn("All vessels");
//        var xOffset:uint = 21;
//        allVessels.x = 20;
//        allVessels.y = 0;
//        allVessels.addEventListener(MouseEvent.CLICK, allVessels_clickHandler);
//
//        downButtonsContainer.addChild(allVessels);
//        var underwayVessels:AlarmDownBtn = new AlarmDownBtn("Underway");
//        underwayVessels.x = 110 + xOffset;
//        underwayVessels.y = 0;
//        underwayVessels.addEventListener(MouseEvent.CLICK, activeAlarms_clickHandler);
//        downButtonsContainer.addChild(underwayVessels);
//
//        _underWayBubble = new Badge();
//        _underWayBubble.x = 110 + xOffset + underwayVessels.width - _underWayBubble.width / 2;
//        _underWayBubble.y = -5;
//        downButtonsContainer.addChild(_underWayBubble);
//
//        this.stage.addChild(downButtonsContainer);

        this.setButtonAlign(BUTTON_ALIGN_LEFT);
        this.addDownButton(0, "All vessels", allVessels_clickHandler);
        this.addDownButton(1, "Underway", activeAlarms_clickHandler);
        _underWayBubble = this.addBubble(1);
    }

    private function positionateDownButtons(_h:int):void {
        var y:int = _h === 0 ? W_HEIGHT : _h
        downButtonsContainer.y = y - W_Y_OFFSET * 2 - 40;
    }


    private function allVessels_clickHandler(event:MouseEvent):void {
        disableDownButton(0);
        _aisList.showAllVessel()
    }

    private function activeAlarms_clickHandler(event:MouseEvent):void {
        disableDownButton(1);
        _aisList.showUnderwayShips()
    }

    private function closeHandler(event:Event):void {
        _aisList.isWindowOpen = false;
        _aisList.removeEventListener("UnderWayCounterChanged", aisList_UnderWayCounterChangedHandler);

    }


    private function aisList_UnderWayCounterChangedHandler(event:Event):void {
        _underWayBubble.setText(_aisList.underwayList.length + "")
    }
}
}
