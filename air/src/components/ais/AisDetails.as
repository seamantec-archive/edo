/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.09.30.
 * Time: 14:31
 * To change this template use File | Settings | File Templates.
 */
package components.ais {
import com.events.UnitChangedEvent;
import com.layout.LayoutHandler;
import com.sailing.ais.Vessel;
import com.sailing.units.UnitHandler;
import com.ui.controls.CloseButton;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.utils.Dictionary;

public class AisDetails extends Sprite {
    [Embed(source="../../../assets/images/ais/aisInfoBg.png")]
    public static var aisInfoCard:Class;

    public static const INFO_WIDTH:uint = 190;

    private var aisInfoCardBitmap:Bitmap;
    private var _ship:Vessel;
    private var textFieldsContainer:Dictionary = new Dictionary();
    private var textFieldsOrderedList:Vector.<String> = new <String>[];
    private var closeBtn:CloseButton = new CloseButton();

    public function AisDetails() {
        super();
        aisInfoCardBitmap = new aisInfoCard();
        this.addChild(aisInfoCardBitmap);
        _ship = new Vessel("0");
        createTextFields();
        closeBtn.y = 5;
        closeBtn.x = aisInfoCardBitmap.width - closeBtn.width - 5;
        closeBtn.addEventListener(MouseEvent.CLICK, closeBtn_clickHandler, false, 0, true);
        this.addChild(closeBtn);
        UnitHandler.instance.addEventListener(UnitChangedEvent.CHANGE, unit_changed_eventHandler, false, 0, true);

    }

    private function createTextFields():void {
        textFieldsContainer["name"] = new AisDetailItem("Name", ship.name, true)
        textFieldsContainer["bearing"] = new AisDetailItem("Bearing", ship.getBearingValue())
        textFieldsContainer["distance"] = new AisDetailItem("Distance", ship.getDistanceValue())
        textFieldsContainer["cog"] = new AisDetailItem("COG", ship.getCOGValue())
        textFieldsContainer["sog"] = new AisDetailItem("SOG", ship.getSOGValue())
        textFieldsContainer["class"] = new AisDetailItem("Class", ship.getShipClass())
        textFieldsContainer["callSign"] = new AisDetailItem("Call Sign", ship.callsign)
        textFieldsContainer["mmsi"] = new AisDetailItem("MMSI", splitedMMSI(ship.mmsi))
        textFieldsContainer["length"] = new AisDetailItem("Length", ship.length + "m")
        textFieldsContainer["type"] = new AisDetailItem("Type", ship.getTypeString())
        textFieldsContainer["status"] = new AisDetailItem("Status", ship.getStatusString())
        textFieldsContainer["destination"] = new AisDetailItem("Destination", ship.destination)
        textFieldsContainer["cpa"] = new AisDetailItem("CPA", ship.getCPAValue())
        textFieldsContainer["tcpa"] = new AisDetailItem("TCPA", ship.getTCPAValue())
        textFieldsOrderedList.push("name")
        textFieldsOrderedList.push("bearing")
        textFieldsOrderedList.push("distance")
        textFieldsOrderedList.push("cog")
        textFieldsOrderedList.push("sog")
        textFieldsOrderedList.push("class")
        textFieldsOrderedList.push("callSign")
        textFieldsOrderedList.push("mmsi")
        textFieldsOrderedList.push("length")
        textFieldsOrderedList.push("type")
        textFieldsOrderedList.push("status")
        textFieldsOrderedList.push("destination")
        textFieldsOrderedList.push("cpa")
        textFieldsOrderedList.push("tcpa")
        var prevIsDouble:Boolean = false;
        var countedY:uint =5;
        for (var i = 0; i < textFieldsOrderedList.length; i++) {
            if(prevIsDouble){
                countedY += 32;
            }else{
                countedY += 16;
            }
            textFieldsContainer[textFieldsOrderedList[i]].y =countedY;
            this.addChild(textFieldsContainer[textFieldsOrderedList[i]])
            switch (textFieldsOrderedList[i]) {
                case "name":
                    prevIsDouble = true;
                    break;
                case "type":
                    prevIsDouble = true;
                    break;
                case "status":
                    prevIsDouble = true;
                    break;
                case "destination":
                    prevIsDouble = true;
                    break;
                default :
                    prevIsDouble = false;
                    break;
            }
        }
    }

    public function updateShipDatas():void {
        (textFieldsContainer["name"] as AisDetailItem).setValue(ship.name);
        (textFieldsContainer["bearing"] as AisDetailItem).setValue(ship.getBearingValue());
        (textFieldsContainer["distance"] as AisDetailItem).setValue(ship.getDistanceValue());
        (textFieldsContainer["cog"] as AisDetailItem).setValue(ship.getCOGValue());
        (textFieldsContainer["sog"] as AisDetailItem).setValue(ship.getSOGValue());
        (textFieldsContainer["class"] as AisDetailItem).setValue(ship.getShipClass());
        (textFieldsContainer["callSign"] as AisDetailItem).setValue(ship.callsign);
        (textFieldsContainer["mmsi"] as AisDetailItem).setValue(splitedMMSI(ship.mmsi));
        (textFieldsContainer["length"] as AisDetailItem).setValue(ship.length + "m");
        (textFieldsContainer["type"] as AisDetailItem).setValue(ship.getTypeString());
        (textFieldsContainer["status"] as AisDetailItem).setValue(ship.getStatusString());
        (textFieldsContainer["destination"] as AisDetailItem).setValue(ship.destination);
        (textFieldsContainer["cpa"] as AisDetailItem).setValue(ship.getCPAValue());
        (textFieldsContainer["tcpa"] as AisDetailItem).setValue(ship.getTCPAValue());
    }

    public function show():void {
        updateShipDatas();
        this.visible = true;
    }

    public function hide():void {
        this.visible = false;
    }


    public function isInfoVisible():Boolean {
        return this.visible;
    }


    public function get ship():Vessel {
        return _ship;
    }

    public function set ship(value:Vessel):void {
        _ship = value;
    }

    private function closeBtn_clickHandler(event:MouseEvent):void {
        LayoutHandler.instance.activeLayout.deselectVessel();
    }

    private function unit_changed_eventHandler(event:UnitChangedEvent):void {
        updateShipDatas();
    }

    public static function splitedMMSI(mmsi:String):String {
        return mmsi.substr(0,3) + " " + mmsi.substr(3);
    }
}
}
