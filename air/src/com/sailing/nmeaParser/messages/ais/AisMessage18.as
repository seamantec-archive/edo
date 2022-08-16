package com.sailing.nmeaParser.messages.ais {
// info: http://gpsd.berlios.de/AIVDM.html
public class AisMessage18 {
    public var repeatIndicator:Number;
    public var mmsi:String;  //use as a string because it will a key


    // accuracy of positioning fixes
    // 0: low (greater than 10 m)
    // 1: high (less than 10 m)
    public var positionAccuracy:Number;

    // longitude and latitude
    public var lon:Number;
    public var lat:Number;

    public var courseOverGround:Number;

    // true heading (relative to true North)
    public var trueHeading:Number;

    // speed over ground in knots (102.2: 102.2 knots or higher)
    public var speedOverGround:Number;

    // UTC seconds when the report was generated
    // 60: not available/default
    // 61: manual input
    // 62: dead reckoning
    // 63: inoperative
    public var timeStamp:Number;


    public function AisMessage18() {
    }

    public function parse(decode_helper:AisDecodeHelper, payload:String):void {
        // bit count is wrong
        if (payload.length != 168 / 6) return;

        var bits:Bitarray = new Bitarray(168);
        if (!decode_helper.get_bits(payload, bits)) return;

        var messageId:uint = decode_helper.get_unsigned(bits, 0, 6);
        if (messageId != 18) {
            return;
        }

        repeatIndicator = decode_helper.get_unsigned(bits, 6, 2);
        mmsi = decode_helper.get_unsigned(bits, 8, 30).toString();


        speedOverGround = new Number(decode_helper.get_unsigned(bits, 46, 10)) / 10.0;
        positionAccuracy = decode_helper.get_unsigned(bits, 56, 1);
        lon = Number(decode_helper.get_signed(bits, 57, 28)) / 600000.0;
        lat = Number(decode_helper.get_signed(bits, 85, 27)) / 600000.0;
        courseOverGround = new Number(decode_helper.get_unsigned(bits, 112, 12)) / 10.0;

        trueHeading = decode_helper.get_unsigned(bits, 124, 9);
        timeStamp = decode_helper.get_unsigned(bits, 133, 6);


        return;
    }
}
}
