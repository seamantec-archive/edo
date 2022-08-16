/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.10.07.
 * Time: 15:57
 * To change this template use File | Settings | File Templates.
 */
package components.ais {
import com.sailing.ais.AisContainer;
import com.sailing.ais.Vessel;

import components.windows.FloatWindow;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.utils.Dictionary;

public class AisListItem extends Sprite {
    [Embed(source="../../../assets/images/ais/openAisItemBg.png")]
    public static var openAisItemBg:Class;
    public static var itemBgBitmap:Bitmap = new openAisItemBg();
    public static const HEADER_HEIGHT:uint = 30;
    public static const INIT_WIDTH:uint = FloatWindow.L_WIDTH;
    private var _vessel:Vessel;
    private var header:Sprite = new Sprite();
    private var openCloseBtn:AisOpenCloseButton = new AisOpenCloseButton();
    private var content:Sprite = new Sprite();
    private var _aisList:AisList;
    private var textFieldsContainer:Dictionary = new Dictionary();
    private var headerTextFieldsContainer:Dictionary = new Dictionary();

    private var _downPoint:Point;

    public function AisListItem(vessel:Vessel, aisList:AisList) {
        super();
        this._vessel = vessel;
        this._aisList = aisList;
        openCloseBtn.addEventListener(MouseEvent.CLICK, openCloseBtn_clickHandler, false, 0, true);
        drawHeader();
        drawContent();
        initTextFields();
        update();
        header.addEventListener(MouseEvent.CLICK, header_clickHandler, false, 0, true);
        _downPoint = new Point();
        this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
    }

    public function update():void {
        (headerTextFieldsContainer["name"] as AisHeaderItem).setValue(_vessel.name);
        (headerTextFieldsContainer["bearing"] as AisHeaderItem).setValue(_vessel.getBearingValue());
        (headerTextFieldsContainer["distance"] as AisHeaderItem).setValue(_vessel.getDistanceValue());
        (headerTextFieldsContainer["cog"] as AisHeaderItem).setValue(_vessel.getCOGValue());
        (headerTextFieldsContainer["sog"] as AisHeaderItem).setValue(_vessel.getSOGValue());
        (textFieldsContainer["class"] as AisListItemText).setValue(_vessel.getShipClass());
        (textFieldsContainer["callSign"] as AisListItemText).setValue(_vessel.callsign);
        (textFieldsContainer["mmsi"] as AisListItemText).setValue(AisDetails.splitedMMSI(_vessel.mmsi));
        (textFieldsContainer["length"] as AisListItemText).setValue(_vessel.length + "m");
        (textFieldsContainer["type"] as AisListItemText).setValue(_vessel.getTypeString());
        (textFieldsContainer["status"] as AisListItemText).setValue(_vessel.getStatusString());
        (textFieldsContainer["destination"] as AisListItemText).setValue(_vessel.destination);
        (textFieldsContainer["cpa"] as AisListItemText).setValue(_vessel.getCPAValue());
        (textFieldsContainer["tcpa"] as AisListItemText).setValue(_vessel.getTCPAValue());
    }

    private function initTextFields():void {
        var initX:int = openCloseBtn.x + openCloseBtn.width + 5;
        headerTextFieldsContainer["name"] = new AisHeaderItem(_vessel.name, initX, true);
        headerTextFieldsContainer["bearing"] = new AisHeaderItem(_vessel.getBearingValue(), initX + 100);
        headerTextFieldsContainer["distance"] = new AisHeaderItem(_vessel.getDistanceValue(), initX + 135);
        headerTextFieldsContainer["cog"] = new AisHeaderItem(_vessel.getCOGValue(), initX + 200);
        headerTextFieldsContainer["sog"] = new AisHeaderItem(_vessel.getSOGValue(), initX + 230);
        header.addChild(headerTextFieldsContainer["name"]);
        header.addChild(headerTextFieldsContainer["bearing"]);
        header.addChild(headerTextFieldsContainer["distance"]);
        header.addChild(headerTextFieldsContainer["cog"]);
        header.addChild(headerTextFieldsContainer["sog"]);

        textFieldsContainer["class"] = new AisListItemText("Class", _vessel.getShipClass(), 43, 25, 0, 0, ["right", "bottom"]);
        textFieldsContainer["callSign"] = new AisListItemText("Call Sign", _vessel.callsign, 59, 25, 43, 0, ["right", "bottom"]);
        textFieldsContainer["mmsi"] = new AisListItemText("MMSI", AisDetails.splitedMMSI(_vessel.mmsi), 70, 25, 102, 0, ["right", "bottom"]);
        textFieldsContainer["length"] = new AisListItemText("Length", _vessel.length + "m", 44, 25, 172, 0, ["right", "bottom"]);
        textFieldsContainer["type"] = new AisListItemText("Type", _vessel.getTypeString(), 100, 25, 216, 0, ["right", "bottom"]);

        textFieldsContainer["status"] = new AisListItemText("Status", _vessel.getStatusString(), 102, 35, 0, 25, ["right"]);
        textFieldsContainer["destination"] = new AisListItemText("Destination", _vessel.destination, 114, 35, 102, 25, ["right"]);
        textFieldsContainer["cpa"] = new AisListItemText("CPA", _vessel.getCPAValue(), 50, 35, 216, 25, ["right"]);
        textFieldsContainer["tcpa"] = new AisListItemText("TCPA", _vessel.getTCPAValue(), 50, 35, 266, 25, ["right"]);

        for each (var aisListItemText:AisListItemText in textFieldsContainer) {
            content.addChild(aisListItemText);
        }
    }


    private function drawHeader():void {
        header.graphics.beginFill(0xe6e6e6);
        header.graphics.drawRect(0, 0, INIT_WIDTH, HEADER_HEIGHT);
        header.graphics.lineStyle(1, 0xffffff);
        header.graphics.moveTo(0, 0)
        header.graphics.lineTo(INIT_WIDTH, 0);
        header.graphics.lineStyle(1, 0xb0b0b0);
        header.graphics.moveTo(0, HEADER_HEIGHT - 1)
        header.graphics.lineTo(INIT_WIDTH, HEADER_HEIGHT - 1);
        openCloseBtn.x = 5;
        openCloseBtn.y = 5;
        this.addChild(header);
        this.addChild(openCloseBtn);
    }

    private function drawContent():void {
        content.graphics.beginBitmapFill(itemBgBitmap.bitmapData);
        content.graphics.drawRect(0, 0, INIT_WIDTH, itemBgBitmap.height);
        content.graphics.endFill();
        content.x = 0;
        content.y = HEADER_HEIGHT;
        setShowHide();
        this.addChild(content);
    }


    private function fillDatas():void {

    }

    public function openElement():void {
        openCloseBtn.isOpen = true;
        setShowHide();
    }

    public function closeElement():void {
        openCloseBtn.isOpen = false;
        setShowHide();
    }
    public function isOpen():Boolean{
        return openCloseBtn.isOpen;
    }


    private function openCloseBtn_clickHandler(event:MouseEvent):void {
        var p:Point = new Point(event.stageX, event.stageY);
        if (Math.abs(_downPoint.x - p.x) <= 3 && Math.abs(_downPoint.y - p.y) <= 3) {
            openContent();
        }
    }

    private function header_clickHandler(event:MouseEvent):void {
        var p:Point = new Point(event.stageX, event.stageY);
        var target:Sprite = event.target as Sprite;
        if ((Math.abs(_downPoint.x - p.x) <= 3 && Math.abs(_downPoint.y - p.y) <= 3) && (isLabel(event.target) || (target != null && target.parent != this.content && target != openCloseBtn))) {
            openContent();
        }
    }

    private function openContent():void {
        openCloseBtn.isOpen = !openCloseBtn.isOpen;
        setShowHide();
        if(openCloseBtn.isOpen) {
            AisContainer.instance.selectedShipMMSI = _vessel.mmsi;
        } else {
            AisContainer.instance.selectedShipMMSI = null;
        }
    }

    private function isLabel(target:Object):Boolean {
        return target==headerTextFieldsContainer["name"].textField
                || target==headerTextFieldsContainer["bearing"].textField
                || target==headerTextFieldsContainer["distance"].textField
                || target==headerTextFieldsContainer["cog"].textField
                || target==headerTextFieldsContainer["sog"].textField;
    }

    private function mouseDownHandler(event:MouseEvent):void {
        _downPoint = new Point(event.stageX, event.stageY);
    }

    private function setShowHide():void {
        if (openCloseBtn.isOpen) {
            content.visible = true;
            _aisList.openCloseElement(_vessel.mmsi);
        } else {
            content.visible = false;
            _aisList.openCloseElement(_vessel.mmsi, false);
        }
    }

    public function getCalcHeight():uint{
        if(openCloseBtn.isOpen){
            return HEADER_HEIGHT+itemBgBitmap.height;
        }else{
            return HEADER_HEIGHT;
        }
    }


    public function get vessel():Vessel {
        return _vessel;
    }
}
}
