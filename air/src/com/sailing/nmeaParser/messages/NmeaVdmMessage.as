package com.sailing.nmeaParser.messages {
import com.sailing.nmeaParser.messages.ais.AisInterpreter;

public class NmeaVdmMessage implements NmeaMessage {

    public function NmeaVdmMessage() {
    }

    public function parse(packet:String):void {

        var parts:Array = packet.split(",");

        var numFragments:Number = 0;
        var fragmentIndex:Number = 0;
        var messageId:Number = 0;
        if (parts[1].length != 0 && parts[2].length != 0) {
            numFragments = Number(parts[1]);
            fragmentIndex = Number(parts[2]);
        }

        if (parts[3].length != 0) {
            messageId = Number(parts[3]);
        }

        var channel:String = parts[4];
        var payload:String = parts[5];

        //TODO create data object and store here the info
        AisInterpreter.getInstance().interpret(numFragments, fragmentIndex, messageId, payload, parts[0] === "AIVDO");
    }

    public function process():Object {
        //TODO process AIS change or maybe this thing put into somewhere common place, to handle it together with other data handling like data logger
        return {key: "vdm", data:""};
    }

}
}
