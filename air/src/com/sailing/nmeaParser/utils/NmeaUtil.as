package com.sailing.nmeaParser.utils {
import com.sailing.datas.Apb;
import com.sailing.datas.ApparentWind;
import com.sailing.datas.Bwc;
import com.sailing.datas.CrossTrack;
import com.sailing.datas.Dbt;
import com.sailing.datas.Dpt;
import com.sailing.datas.Gga;
import com.sailing.datas.Gll;
import com.sailing.datas.Gsa;
import com.sailing.datas.Gsv;
import com.sailing.datas.Hcc;
import com.sailing.datas.Hcd;
import com.sailing.datas.Hdg;
import com.sailing.datas.Hdm;
import com.sailing.datas.Hdt;
import com.sailing.datas.Heading;
import com.sailing.datas.Hsc;
import com.sailing.datas.Htc;
import com.sailing.datas.Hvm;
import com.sailing.datas.Mda;
import com.sailing.datas.Mhu;
import com.sailing.datas.Mmb;
import com.sailing.datas.Mta;
import com.sailing.datas.Mtw;
import com.sailing.datas.Mwd;
import com.sailing.datas.Mwv;
import com.sailing.datas.MwvR;
import com.sailing.datas.MwvT;
import com.sailing.datas.OffCourse;
import com.sailing.datas.Performance;
import com.sailing.datas.PositionAndSpeed;
import com.sailing.datas.Rmb;
import com.sailing.datas.Rmc;
import com.sailing.datas.Rotnmea;
import com.sailing.datas.Rsa;
import com.sailing.datas.Setanddrift;
import com.sailing.datas.TrueWindC;
import com.sailing.datas.Vdm;
import com.sailing.datas.Vdr;
import com.sailing.datas.Vhw;
import com.sailing.datas.Vlw;
import com.sailing.datas.Vmg;
import com.sailing.datas.VmgWaypoint;
import com.sailing.datas.VmgWind;
import com.sailing.datas.Vpw;
import com.sailing.datas.Vtg;
import com.sailing.datas.Vwr;
import com.sailing.datas.Vwt;
import com.sailing.datas.WaterDepth;
import com.sailing.datas.Wdc;
import com.sailing.datas.Windsmoothapp;
import com.sailing.datas.Windsmoothtrue;
import com.sailing.datas.Xte;
import com.sailing.datas.Zda;
import com.sailing.datas.Zlz;
import com.sailing.datas.Zzu;

import flash.net.registerClassAlias;

public class NmeaUtil {
    public function NmeaUtil() {
    }

    public static function parsable(headers:Array, packet:String):Boolean {
        for (var i:int = 0; i < headers.length; i++) {
            if (packet.substr(0, headers[i].length) == headers[i]) {
                return true;
            }
        }

        return false;
    }

    public static function meterSecToKnots(meterSec:Number):Number {
        return new Number(meterSec) * 1.94384449;
    }

    public static function kmhToKnots(kmh:Number):Number {
        return new Number(kmh) * 0.539956803;
    }

    public static function registerNmeaDatas():void {
        registerClassAlias("com.datas.Vwr", Vwr);
        registerClassAlias("com.datas.Gll", Gll);
        registerClassAlias("com.datas.Apb", Apb);
        registerClassAlias("com.datas.Bwc", Bwc);
        registerClassAlias("com.datas.Dbt", Dbt);
        registerClassAlias("com.datas.Dpt", Dpt);
        registerClassAlias("com.datas.Gga", Gga);
        registerClassAlias("com.datas.Hdg", Hdg);
        registerClassAlias("com.datas.Hdm", Hdm);
        registerClassAlias("com.datas.Hdt", Hdt);
        registerClassAlias("com.datas.Hsc", Hsc);
        registerClassAlias("com.datas.Mtw", Mtw);
        registerClassAlias("com.datas.Mwv", Mwv);
        registerClassAlias("com.datas.Rmc", Rmc);
        registerClassAlias("com.datas.Rsa", Rsa);
        registerClassAlias("com.datas.Vdm", Vdm);
        registerClassAlias("com.datas.Vhw", Vhw);
        registerClassAlias("com.datas.Vlw", Vlw);
        registerClassAlias("com.datas.Vwr", Vwr);
        registerClassAlias("com.datas.Gsa", Gsa);
        registerClassAlias("com.datas.Gsv", Gsv);
        registerClassAlias("com.datas.Mwd", Mwd);
        registerClassAlias("com.datas.Rmb", Rmb);
        registerClassAlias("com.datas.Rot", Rotnmea);
        registerClassAlias("com.datas.Vdr", Vdr);
        registerClassAlias("com.datas.Vpw", Vpw);
        registerClassAlias("com.datas.Vtg", Vtg);
        registerClassAlias("com.datas.Zda", Zda);
        registerClassAlias("com.datas.Hcc", Hcc);
        registerClassAlias("com.datas.Hcd", Hcd);
        registerClassAlias("com.datas.Htc", Htc);
        registerClassAlias("com.datas.Mda", Mda);
        registerClassAlias("com.datas.Mhu", Mhu);
        registerClassAlias("com.datas.Mmb", Mmb);
        registerClassAlias("com.datas.Hvm", Hvm);
        registerClassAlias("com.datas.Mta", Mta);
        registerClassAlias("com.datas.Vwr", Vwr);
        registerClassAlias("com.datas.Vwt", Vwt);
        registerClassAlias("com.datas.Wdc", Wdc);
        registerClassAlias("com.datas.Xte", Xte);
        registerClassAlias("com.datas.Zlz", Zlz);
        registerClassAlias("com.datas.Zzu", Zzu);
        registerClassAlias("com.datas.Vmg", Vmg);
        registerClassAlias("com.datas.VmgWind", VmgWind);
        registerClassAlias("com.datas.VmgWaypoint", VmgWaypoint);
        registerClassAlias("com.datas.MwvT", MwvT);
        registerClassAlias("com.datas.MwvR", MwvR);
        registerClassAlias("com.datas.WindSmoothtrue", Windsmoothtrue);
        registerClassAlias("com.datas.WindSmoothapp", Windsmoothapp);
        registerClassAlias("com.datas.Setanddrift", Setanddrift);
        registerClassAlias("com.datas.PositionAndSpeed", PositionAndSpeed);
        registerClassAlias("com.datas.CrossTrack", CrossTrack);
        registerClassAlias("com.datas.Heading", Heading);
        registerClassAlias("com.datas.TrueWindC", TrueWindC);
        registerClassAlias("com.datas.ApparentWind", ApparentWind);
        registerClassAlias("com.datas.WaterDepth", WaterDepth);
        registerClassAlias("com.datas.OffCourse", OffCourse);
        registerClassAlias("com.datas.Performance", Performance);

    }

    public static function upperCase(str:String):String {
        var firstChar:String = str.substr(0, 1);
        var restOfString:String = str.substr(1, str.length);
        return firstChar.toUpperCase() + restOfString.toLowerCase();
    }
}
}
