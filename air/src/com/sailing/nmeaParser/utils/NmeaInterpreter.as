package com.sailing.nmeaParser.utils {


import com.loggers.SystemLogger;
import com.sailing.nmeaParser.messages.NmeaApbMessage;
import com.sailing.nmeaParser.messages.NmeaBwcMessage;
import com.sailing.nmeaParser.messages.NmeaDbtMessage;
import com.sailing.nmeaParser.messages.NmeaDptMessage;
import com.sailing.nmeaParser.messages.NmeaGgaMessage;
import com.sailing.nmeaParser.messages.NmeaGllMessage;
import com.sailing.nmeaParser.messages.NmeaHccMessage;
import com.sailing.nmeaParser.messages.NmeaHcdMessage;
import com.sailing.nmeaParser.messages.NmeaHdgMessage;
import com.sailing.nmeaParser.messages.NmeaHdmMessage;
import com.sailing.nmeaParser.messages.NmeaHdtMessage;
import com.sailing.nmeaParser.messages.NmeaHscMessage;
import com.sailing.nmeaParser.messages.NmeaHtcMessage;
import com.sailing.nmeaParser.messages.NmeaHvmMessage;
import com.sailing.nmeaParser.messages.NmeaMdaMessage;
import com.sailing.nmeaParser.messages.NmeaMhuMessage;
import com.sailing.nmeaParser.messages.NmeaMmbMessage;
import com.sailing.nmeaParser.messages.NmeaMtaMessage;
import com.sailing.nmeaParser.messages.NmeaMtwMessage;
import com.sailing.nmeaParser.messages.NmeaMwdMessage;
import com.sailing.nmeaParser.messages.NmeaMwvMessage;
import com.sailing.nmeaParser.messages.NmeaRmbMessage;
import com.sailing.nmeaParser.messages.NmeaRmcMessage;
import com.sailing.nmeaParser.messages.NmeaRotMessage;
import com.sailing.nmeaParser.messages.NmeaRsaMessage;
import com.sailing.nmeaParser.messages.NmeaVdmMessage;
import com.sailing.nmeaParser.messages.NmeaVdrMessage;
import com.sailing.nmeaParser.messages.NmeaVhwMessage;
import com.sailing.nmeaParser.messages.NmeaVlwMessage;
import com.sailing.nmeaParser.messages.NmeaVpwMessage;
import com.sailing.nmeaParser.messages.NmeaVtgMessage;
import com.sailing.nmeaParser.messages.NmeaVwrMessage;
import com.sailing.nmeaParser.messages.NmeaVwtMessage;
import com.sailing.nmeaParser.messages.NmeaWdcMessage;
import com.sailing.nmeaParser.messages.NmeaXteMessage;
import com.sailing.nmeaParser.messages.NmeaZdaMessage;
import com.sailing.nmeaParser.messages.NmeaZlzMessage;
import com.sailing.nmeaParser.messages.NmeaZzuMessage;

public class NmeaInterpreter {

    private static var messages:Object = {
        "VLW": new NmeaVlwMessage(),
        "BWC": new NmeaBwcMessage(),
        "GGA": new NmeaGgaMessage(),
        "GLL": new NmeaGllMessage(),
        "HDG": new NmeaHdgMessage(),
        "HDM": new NmeaHdmMessage(),
        "HDT": new NmeaHdtMessage(),
        "HSC": new NmeaHscMessage(),
        "DBT": new NmeaDbtMessage(),
        "DPT": new NmeaDptMessage(),
        "MTW": new NmeaMtwMessage(),
        "MWV": new NmeaMwvMessage(),
        "RMC": new NmeaRmcMessage(),
        "RSA": new NmeaRsaMessage(),
        "VHW": new NmeaVhwMessage(),
        "VWR": new NmeaVwrMessage(),
        //"GSA": new NmeaGsaMessage(),
        //"GSV": new NmeaGsvMessage(),
        "MWD": new NmeaMwdMessage(),
        "RMB": new NmeaRmbMessage(),
        "ROT": new NmeaRotMessage(),
        "VDR": new NmeaVdrMessage(),
        "VPW": new NmeaVpwMessage(),
        "VDM": new NmeaVdmMessage(),
        "VDO": new NmeaVdmMessage(), //VDO is AIS from own ship
        "ZDA": new NmeaZdaMessage(),
        "HCC": new NmeaHccMessage(),
        "HCD": new NmeaHcdMessage(),
        "HTC": new NmeaHtcMessage(),
        "MDA": new NmeaMdaMessage(),
        "MHU": new NmeaMhuMessage(),
        "MMB": new NmeaMmbMessage(),
        "HVM": new NmeaHvmMessage(),
        "MTA": new NmeaMtaMessage(),
        "VWT": new NmeaVwtMessage(),
        "VTG": new NmeaVtgMessage(),
        "XTE": new NmeaXteMessage(),
        "ZLZ": new NmeaZlzMessage(),
        "ZZU": new NmeaZzuMessage(),
        "WDC": new NmeaWdcMessage(),
        "APB": new NmeaApbMessage()
    };

    public static function processWithMessageCode(message:String):Object {
        var header:String = message.substring(2, message.indexOf(","));
        if (messages.hasOwnProperty(header)) {
            var messageHandler:Object = messages[header];
            message =  message.slice(0, message.indexOf("*"));
            messageHandler.parse(message)
            return messageHandler.process();
        }


//        try {
//            //egyenlore eldobjuk a gyartoi informaciokat
//            var header:String = message.split(",")[0].substring(2, 5);
//            //SystemLogger.Debug(header);
//            var messager:Object = messages[header];
//            messager.parse(message)
//            return messager.process();
//        } catch (e:Error) {
////            SystemLogger.Info("Interpreter error: " + message + "  ||| " + e) ;
//        }

        return null;
    }

    public function interpret(packet:String):Boolean {
        packet = packet.slice(0, packet.indexOf("*"));
        for (var i:int = 0; i < messages.length; i++) {
            if (messages[i].parse(packet)) {
                messages[i].process();
                return true;
            }
        }
        SystemLogger.Info("NINCS MESSAGE: " + packet);
        return false;
    }
}
}