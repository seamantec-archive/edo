/**
 * Created by pepusz on 2014.02.06..
 */
package com.logbook {
import com.loggers.DataLogger;
import com.sailing.split;
import com.sailing.units.Depth;
import com.sailing.units.Distance;
import com.sailing.units.Speed;
import com.sailing.units.Temperature;
import com.sailing.units.Unit;
import com.sailing.units.WindSpeed;

public class LogBookEntry {
    public var lat:Number;
    public var lon:Number;
    public var timestamp:Date;
    public var sog:Speed;
    public var cog:Number;
    public var depth:Depth;
    public var waterTemp:Temperature;
    public var airTemp:Temperature;
    public var windSpeed:WindSpeed;
    public var windDir:Number;
    public var tripDistance:Distance;
    public var isDemo:Boolean;


    public function LogBookEntry(lat:Number, lon:Number, timestamp:Date, sog:Speed, cog:Number, depth:Depth, waterTemp:Temperature, airTemp:Temperature, windSpeed:WindSpeed, windDir:Number, tripDistance:Distance, isDemo:Boolean) {
        this.lat = lat;
        this.lon = lon;
        this.timestamp = timestamp;
        this.sog = sog;
        this.cog = cog;
        this.depth = depth;
        this.waterTemp = waterTemp;
        this.airTemp = airTemp;
        this.windSpeed = windSpeed;
        this.windDir = windDir;
        this.tripDistance = tripDistance;
        this.isDemo = isDemo;
    }

    public static function parseSql(object:Object):LogBookEntry {
        var sog:Speed = new Speed();
        sog.value = object.sog;
        var depth:Depth = new Depth();
        depth.value = object.depth;
        var wtemp:Temperature = new Temperature();
        wtemp.value = object.water_temp
        var airtemp:Temperature = new Temperature();
        airtemp.value = object.air_temp
        var wSpeed:WindSpeed = new WindSpeed();
        wSpeed.value = object.wind_speed;
        var tDistance:Distance = new Distance();
        tDistance.value = object.trip_distance;
        return new LogBookEntry(object.lat, object.lon, new Date(object.timestamp * 1000), sog, object.cog, depth, wtemp, airtemp, wSpeed, object.wind_dir, tDistance, (object.is_demo == 0 ? false : true))
    }

    public function exportForCsv():String {
        return DataLogger.toFormatedUTCDateWithoutSec(timestamp) + ";" +
                convertValue(lat) + ";" +
                convertValue(lon) + ";" +
                convertValue(sog) + ";" +
                convertValue(cog, 0) + ";" +
                convertValue(depth) + ";" +
                convertValue(waterTemp) + ";" +
                convertValue(airTemp) + ";" +
                convertValue(windSpeed) + ";" +
                convertValue(windDir, 0) + ";" +
                convertValue(tripDistance, 0) + ";"
    }

    public static function csvHeader():String {
        return "UTC;lat;lon;sog;cog;dbt;mtw;mta;tws;twd"
    }

    public static function convertValue(value:*, roundToDigits:uint = 4):String {
        if (value === 9999) {
            return "---";
        }
        if (value is Unit) {
            var unitV:Unit = value as Unit;
            if (unitV.getPureData() === 9999) {
                return "---";
            }
            return split.withValue(unitV.value).a5 + "." + split.instance.b2 + " " + unitV.getUnitShortString();
        } else {
            var roundTo:uint = Math.pow(10, roundToDigits);
            return Math.round(value * roundTo) / roundTo + "";
        }
    }
}
}
