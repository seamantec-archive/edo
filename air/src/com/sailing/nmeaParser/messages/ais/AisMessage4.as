/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.09.23.
 * Time: 15:07
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.nmeaParser.messages.ais {
import com.sailing.ais.AisContainer;
import com.sailing.ais.Vessel;

public class AisMessage4 {
    public var repeatIndicator:Number;
    public var mmsi:String;
    public var utcYear:Number;
    public var utcMonth:Number;
    public var utcDay:Number;
    public var utcHour:Number;
    public var utcMin:Number;
    public var utcSecond:Number;
    public var lat:Number;
    public var lon:Number;
    public var epfdType:int;


    public var ship:Vessel;


    public function parse(decode_helper:AisDecodeHelper, payload:String):void {

        // bit count is wrong
        if (payload.length != 168 / 6) return;

        var bits:Bitarray = new Bitarray(168);
        if (!decode_helper.get_bits(payload, bits)) return;

        var messageId:uint = decode_helper.get_unsigned(bits, 0, 6);
        if (messageId != 4) {
            return;
        }
        mmsi = decode_helper.get_unsigned(bits, 8, 30).toString();

        ship = AisContainer.instance.getVessel(mmsi)
        ship.shipType = Vessel.BASESTATION_CODE;
        ship.shipMainType = Vessel.BASESTATION
        repeatIndicator = decode_helper.get_unsigned(bits, 6, 2);
        utcYear = decode_helper.get_unsigned(bits, 38, 14);
        utcMonth = decode_helper.get_unsigned(bits, 52, 4);
        utcDay = decode_helper.get_unsigned(bits, 56, 5);
        utcHour = decode_helper.get_unsigned(bits, 61, 5);
        utcMin = decode_helper.get_unsigned(bits, 66, 6);
        utcSecond = decode_helper.get_unsigned(bits, 72, 77);
        ship.lon = Number(decode_helper.get_signed(bits, 79, 28)) / 600000.0;
        ship.lat = Number(decode_helper.get_signed(bits, 107, 27)) / 600000.0;
        ship.speedOverGround = 0
        ship.positionAccuracy = decode_helper.get_unsigned(bits, 60, 1);
        ship.courseOverGround = 0

        ship.trueHeading = 0;

        return;
    }
}
}
