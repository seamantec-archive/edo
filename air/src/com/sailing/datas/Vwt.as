﻿package com.sailing.datas {import com.sailing.units.Angle;import com.sailing.units.WindSpeed;public class Vwt  extends BaseSailData{    public var relativeWindAngleToVessel:Angle = new Angle();    public var vesselHeading:String;    public var windSpeed:WindSpeed = new WindSpeed();    public function Vwt() {        super();        _paramsDisplayName["relativeWindAngleToVessel"] = { displayName: "Calculated wind angle relative to the vessel", order: 0 };        _paramsDisplayName["vesselHeading"] = { displayName: "Vessel heading", order: 1 };        _paramsDisplayName["windSpeed"] = { displayName: "Calculated wind speed", order: 2 };    }    public override function get displayName():String {        return "True Wind Speed and Angle (VWT)";    }}}