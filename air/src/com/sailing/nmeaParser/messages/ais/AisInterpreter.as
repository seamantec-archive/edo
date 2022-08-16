package com.sailing.nmeaParser.messages.ais {

import com.common.Coordinate;
import com.sailing.ais.AisContainer;

import flash.utils.Dictionary;

public class AisInterpreter {
    private static var instance:AisInterpreter;
    private var decodeHelper:AisDecodeHelper;
    private var fragments:Dictionary;

    public static function getInstance():AisInterpreter {
        if (instance == null) {
            instance = new AisInterpreter(new SingletonBlocker());
        }

        return instance;
    }

    public function AisInterpreter(p:SingletonBlocker) {
        if (p == null) {
            throw new Error("Error: Instantiation failed: Use SingletonDemo.getInstance() instead of new.");
        }

        decodeHelper = new AisDecodeHelper();
        fragments = new Dictionary();
    }

    public function interpret(numFragments:int, fragmentIndex:int, messageId:int, payLoad:String, isVdo:Boolean = false):Boolean {
        if (numFragments == 1) {
            return parsePayLoad(payLoad, isVdo);
        }
        else {
            if (fragmentIndex == 1 && fragments[messageId] == null) {
                fragments[messageId] = new String(payLoad);
            }
            else if (fragments[messageId] != null) {
                fragments[messageId] += payLoad;
            }

            if (fragmentIndex == numFragments && fragments[messageId] != null) {
                return parsePayLoad(fragments[messageId], isVdo);
                delete fragments[messageId];
            }
        }

        return false;
    }

    private function parsePayLoad(payLoad:String, isVdo:Boolean = false):Boolean {
        var bits:Bitarray = new Bitarray(6);
        if (!decodeHelper.get_bits(new String(payLoad.charAt(0)), bits)) {
            return false;
        }
        var messageId:uint = decodeHelper.get_unsigned(bits, 0, 6);
        switch (messageId) {
            case 1:
            case 2:
            case 3:
                parseAisMessage(payLoad, isVdo);
                return true;
            case 4:
                var m4:AisMessage4 = new AisMessage4();
                m4.parse(decodeHelper, payLoad);
                AisContainer.instance.addShip(m4.ship);
                return true;
            case 5:
                var m5:AisMessage5 = new AisMessage5();
                m5.parse(decodeHelper, payLoad);
                if (m5.ship != null) {
                    AisContainer.instance.updateShipDetails(m5.mmsi);
                }
                return true;
            case 9:
                var m9:AisMessage9 = new AisMessage9();
                m9.parse(decodeHelper, payLoad);
                AisContainer.instance.addShip(m9.ship);
                return true;
            case 18:
                var m18:AisMessage18 = new AisMessage18();
                m18.parse(decodeHelper, payLoad);
//                AisContainer.instance.ownShip.heading = m18.trueHeading;  //this is come from nmea other heading information
                AisContainer.instance.ownShip.coordinate = new Coordinate(m18.lat, m18.lon)
                AisContainer.instance.ownShip.speed = m18.speedOverGround;
                return true;
            case 20: break;
            default:
                    trace("AIS message id not handled", messageId)
                break;
        }


        return false;
    }

    private function parseAisMessage(payLoad:String, isVdo:Boolean):void {
        var m123:AisMessage123 = new AisMessage123();
        m123.parse(decodeHelper, payLoad);
        if (isVdo) {
            AisContainer.instance.ownShip.heading = m123.ship.trueHeading;
            AisContainer.instance.ownShip.coordinate = new Coordinate(m123.ship.lat, m123.ship.lon)
            AisContainer.instance.ownShip.speed = m123.ship.speedOverGround;
        } else {
            AisContainer.instance.addShip(m123.ship);
        }
    }
}
}

internal class SingletonBlocker {
}
