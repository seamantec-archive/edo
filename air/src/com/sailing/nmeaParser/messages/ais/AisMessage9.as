/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.09.24.
 * Time: 13:30
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.nmeaParser.messages.ais {
import com.sailing.ais.AisContainer;
import com.sailing.ais.SarAircraft;
import com.sailing.ais.Vessel;

public class AisMessage9 {
    public var repeatIndicator:Number;
    // UTC seconds when the report was generated
    // 60: not available/default
    // 61: manual input
    // 62: dead reckoning
    // 63: inoperative
    public var timeStamp:Number;

    public var specialManoeuvre:Number;
    public var spare:Number;

    // receiver autonomous integrity monitoring flag
    // false: not in use
    // true: in use
    public var receiverAutonomousIntegrityFlag:Boolean;

    // communications State - SOTDMA Sycronization state
    // 0: UTC direct
    // 1: UTC indirect
    // 2: synchronized to a base station
    // 3: synchronized to another station
    public var syncState:Number;


    // communications State - SOTDMA Frames remaining until a new slot is selected
    // 0: Last frame in this slot
    // 1: 1 frames left
    // 2: 2 frames left
    // 3: 3 frames left
    // 4: 4 frames left
    // 5: 5 frames left
    // 6: 6 frames left
    // 7: 7 frames left
    public var slotTimeOut:Number;

    // Based on slot_timeout which ones are valid
    public var receivedStations:Number;
    public var receivedStationsValid:Boolean;

    public var slotNumber:Number;
    public var slotNumberValid:Boolean;

    public var utcHour:Number;
    public var utcMin:Number;
    public var utcSpare:Number;
    public var utcValid:Boolean;

    // communications State - SOTDMA In what slot will the next transmission occur
    public var slotOffset:Number;
    public var slotOffsetValid:Boolean;

    // ITDMA - msg type 3
    public var slotIncrement:Number;
    public var slotIncrementValid:Boolean;

    public var slotsToAllocate:Number;
    public var slotsToAllocateValid:Boolean;

    public var keepFlag:Boolean;
    public var keepFlagValid:Boolean;

    public var ship:SarAircraft;

    public function AisMessage123() {
    }

    public function parse(decode_helper:AisDecodeHelper, payload:String):void {

        // bit count is wrong
        if (payload.length != 168 / 6) return;

        var bits:Bitarray = new Bitarray(168);
        if (!decode_helper.get_bits(payload, bits)) return;

        var messageId:uint = decode_helper.get_unsigned(bits, 0, 6);
        if (messageId != 9) {
            return;
        }
        var mmsi = decode_helper.get_unsigned(bits, 8, 30).toString();
        ship = AisContainer.instance.getSarAircraft(mmsi);
        ship.shipMainType = Vessel.SHIP_SAR;
        repeatIndicator = decode_helper.get_unsigned(bits, 6, 2);
        ship.altitude = decode_helper.get_unsigned(bits,38,12);
        ship.speedOverGround = new Number(decode_helper.get_unsigned(bits, 50, 10));
        ship.positionAccuracy = decode_helper.get_unsigned(bits, 60, 1);
        ship.lon = Number(decode_helper.get_signed(bits, 61, 28)) / 600000.0;
        ship.lat = Number(decode_helper.get_signed(bits, 89, 27)) / 600000.0;
        ship.courseOverGround = new Number(decode_helper.get_unsigned(bits, 116, 12)) / 10.0;
        ship.trueHeading = ship.courseOverGround;

        timeStamp = decode_helper.get_unsigned(bits, 128, 6);
        spare = decode_helper.get_unsigned(bits, 143, 3);
        ship.radioStatus = decode_helper.get_unsigned(bits, 148,19);

        return;
    }
}
}
