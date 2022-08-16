package com.sailing.nmeaParser.utils {
import com.loggers.SystemLogger;

public class NmeaPacketer {
    private static var gBuffer:String = ""
    private var errorCount:Number = 0;

    protected static const NMEA_START1:String = '$';
    protected static const NMEA_START2:String = '!';
    protected static const NMEA_CHKS:String = "*";
    protected static const NMEA_END:String = '\n';
    public static const MAX_NMEA_MESSAGE_LEN:uint = 140;

    public function NmeaPacketer() {
    }

    public static function reset():void {
        gBuffer = "";
    }

    public function newReadPacket(buffer:String, isLoadLog:Boolean = false):Array {
        gBuffer = gBuffer + buffer;
        var packets:Array = gBuffer.split(NMEA_END);
        var preProcessedPackates:Array = []
        for (var i:int = 0; i < packets.length; i++) {
            //szabvany szerint vehetjuk delimeternek a \r\n-t es akkor ezt a sort megtudjuk sporolni
            var current:String = packets[i].replace(/\r/gi, "");
            if (current != "") {
                var error:Boolean = false;
                if(current.indexOf(NMEA_START1) > 0 ){
                    current = current.slice(current.indexOf(NMEA_START1), current.length);
                }
                if(current.indexOf(NMEA_START2) > 0 ){
                    current = current.slice(current.indexOf(NMEA_START2), current.length);
                }
                if (current.charAt(0) != NMEA_START1 && current.charAt(0) != NMEA_START2) {
                    error = true;
                    SystemLogger.Info("broken message: " + current);
                }
                if (current.length > MAX_NMEA_MESSAGE_LEN) {
                    error = true;
                    SystemLogger.Info("too long message: " + current);
                }
                if (current.lastIndexOf(NMEA_START1) != 0 && current.lastIndexOf(NMEA_START2) != 0) {
                    error = true;
                    SystemLogger.Info("multiple message: " + current);
                }


                // Calculate checksum
                var checksum:int = 0;
                for (var j:uint = 1; j < current.length - 3; j++) {
                    checksum ^= current.charCodeAt(j);
                }

                var originalChecksumString:String = current.substr(current.length - 2, 2);
                if (originalChecksumString.charAt(0) == '0') {
                    originalChecksumString = originalChecksumString.slice(1, 2);
                }

                if (originalChecksumString.toLowerCase() == checksum.toString(16).toLowerCase()) {
                    if (!isLoadLog) {
                        gBuffer = gBuffer.replace(current, "");
                        gBuffer = gBuffer.slice(0,gBuffer.search(/\S/));
                    }
                }
                else {
                    // Checksum FAIL
                    error = true;
//                    SystemLogger.Info("checksum fail " + current + " " + originalChecksumString.toLowerCase() + " | " + checksum.toString(16).toLowerCase());
                    if (i != packets.length - 1 && !isLoadLog) {
                        gBuffer = gBuffer.replace(current, "");
                        gBuffer = gBuffer.slice(0,gBuffer.search(/\S/))
                    }
                }

                if (!error) {
                    var preprocessing:String = current.slice(1, current.length);
                    preProcessedPackates.push(preprocessing);
                }
            }


        }
        return preProcessedPackates;
    }

    /*public function readPacket(buffer:String):Array
     {
     var packetStart:uint = 0;
     var packetEnd:uint = 0;

     while (packetStart < buffer.length)
     {
     if (buffer.charAt(packetStart) == NMEA_START1 || buffer.charAt(packetStart) == NMEA_START2)
     {
     packetEnd = ++packetStart;
     while (packetEnd < buffer.length)
     {
     var nextChar:String = buffer.charAt(packetEnd);
     if (nextChar == NMEA_END) break;

     // todo: more exit conditions
     if (((packetEnd - packetStart) > MAX_NMEA_MESSAGE_LEN) || nextChar == NMEA_START1 || nextChar == NMEA_START2)
     {
     return ["", buffer.substr(packetEnd, buffer.length)];
     }

     ++packetEnd;
     }

     if (packetStart != packetEnd)
     {
     // Calculate checksum
     var checksum:int = 0;
     for (var i:uint = packetStart; i < packetEnd - 3; ++i)
     {
     checksum ^= buffer.charCodeAt(i);
     }

     var originalChecksumString: String = buffer.substr(packetEnd-2, 2);
     if (originalChecksumString.charAt(0) == '0')
     {
     originalChecksumString = originalChecksumString.slice(1, 2);
     }

     if (originalChecksumString.toLowerCase() == checksum.toString(16).toLowerCase())
     {
     // checksum OK
     return [buffer.substr(packetStart, packetEnd - 4), buffer.substr(packetEnd + 1, buffer.length)];
     }
     else
     {
     // Checksum FAIL
     ++errorCount;
     }

     return ["", buffer.substr(packetEnd, buffer.length)];
     }
     }

     ++packetStart;
     }

     return ["", buffer.substr(packetStart, buffer.length)];
     }*/
}
}
