/**
 * Created by seamantec on 20/01/14.
 */
package com.sailing.nmeaParser.messages {

import com.sailing.datas.Dpt;

import flash.events.Event;

/*
 *  DPT - Depth
 *
 *  $--DPT,x.x,x.x,x.x*hh<CR><LF>
 *          |   |   |
 *          |   |   --  Maximum range scale in use
 *          |   --  Offset from transducer1,2, meters
 *          --  Water depth relative to the transducer, meters
 */

public class NmeaDptMessage implements NmeaMessage {

    private var data:Dpt = new Dpt();
    private var isValid:Boolean = true;

    public function NmeaDptMessage() {
    }

    public function parse(packet:String):void {
        var parts:Array = packet.split(",");

        if (parts.length == 5) {
            if (parts[1].length > 0) {
                data.waterDepth.value = new Number(parts[1]);

                if (parts[2].length > 0) {
                    if (parts[2].charAt(0) == "-") {
                        data.offset.value = (new Number(parts[2].substring(1, parts[2].length)))*(-1);
                    } else {
                        data.offset.value = new Number(parts[2]);
                    }
                }
                if (parts[3].length > 0) {
                    var range:String = parts[3];
                    if (range.length) {
                        data.maximumRange.value = new Number(range);
                    }
                }
                isValid = true;
            } else {
                isValid = false;
            }
        } else if (parts.length == 4) {
            if (parts[1].length > 0) {
                data.waterDepth.value = new Number(parts[1]);
                isValid = true;
                if (parts[2].length > 0) {
                    var offset:String = parts[3];
                    if (offset.length && offset.charAt(0) == "-") {
                        data.offset.value = (new Number(offset.substring(1, offset.length)))*(-1);
                    } else {
                        data.offset.value = new Number(offset);
                    }
                }
            } else {
                isValid = false;
            }
        } else if (parts.length == 3) {
            var depth:String = parts[1];
            if (depth.length > 0) {
                data.waterDepth.value = new Number(depth);
                isValid = true;
            } else {
                isValid = false;
            }
        }

        if (isValid) {
            data.waterDepthWithOffset.value = data.offset.getPureData() + data.waterDepth.getPureData();
        }
    }


    public function process():Object {
        return isValid ? {key: "dpt", data: data} : null;
    }
}
}
