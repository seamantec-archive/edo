package com.sailing.nmeaParser.messages {
import com.sailing.datas.Hdt;
import com.sailing.units.Direction;
import com.sailing.units.Unit;

/*
	HDT - Heading - True

	1   2 3
	|   | |
	$--HDT,x.x,T*hh<CR><LF>

	Field Number: 
	1) Heading Degrees, true
	2) T = True
	3) Checksum
	*/
public class NmeaHdtMessage implements NmeaMessage {

    private var data:Hdt = new Hdt();
    private var isValid:Boolean = true;

    public function parse(packet:String):void {
        isValid = true;

        var parts:Array = packet.split(",");
        if (parts[1].length) {
            data.heading.value = Unit.toInterval(new Number(parts[1]) - Direction.variation);
        } else {
            isValid = false;
        }
    }

    public function process():Object {
        return isValid ? {key: "hdt", data: data} : null;
    }

    public function NmeaHdtMessage() {

    }

}

}