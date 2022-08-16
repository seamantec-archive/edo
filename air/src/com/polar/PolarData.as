/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.09.18.
 * Time: 20:31
 * To change this template use File | Settings | File Templates.
 */
package com.polar {
public class PolarData {
    public var timestamp:Number = -1;
    public var windSpeed:Number = -1;
    public var boatSpeed:Number = -1;
    public var windDir:Number = -1;


    public function PolarData(timestamp:Number = -1, windSpeed:Number = -1, boatSpeed:Number = -1, windDir:Number = -1) {
        this.timestamp = timestamp;
        this.windSpeed = windSpeed;
        this.boatSpeed = boatSpeed;
        this.windDir = windDir;
    }

    public function isValid():Boolean {
        return timestamp != -1 && windSpeed != -1 && boatSpeed != -1 && windDir != -1 && !isNaN(boatSpeed) && !isNaN(windSpeed) && !isNaN(windDir);
    }

    public function traceOut():void {
        trace("datas.push(new PolarData(", timestamp, ",", windSpeed, ",", boatSpeed, ",", windDir, "));");
    }

    public function toString():void {
        trace("windDir", windDir, "windSpeed:", windSpeed, "; boatSpeed:", boatSpeed)
    }
}
}
