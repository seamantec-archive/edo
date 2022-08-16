package com.sailing
{
	import com.sailing.datas.Apb;
	import com.sailing.datas.Bwc;
	import com.sailing.datas.Dbt;
	import com.sailing.datas.Gga;
	import com.sailing.datas.Gll;
	import com.sailing.datas.Hdg;
	import com.sailing.datas.Hdm;
	import com.sailing.datas.Hsc;
	import com.sailing.datas.Mtw;
	import com.sailing.datas.Mwv;
	import com.sailing.datas.Rmc;
	import com.sailing.datas.Rsa;
	import com.sailing.datas.Vdm;
	import com.sailing.datas.Vhw;
	import com.sailing.datas.Vlw;
	import com.sailing.datas.Vwr;
	

public class SailData
{
	
	public var sailDataTimestamp:Number;

	
	
	//APB - Heading/Track Controller (Autopilot) Sentence "B"
	public var apb:Apb = new Apb();
	//BWC - Bearing & Distance to Waypoint
	public var bwc:Bwc = new Bwc();
	//DBT - Depth Below Transducer
	public var dbt:Dbt = new Dbt();
	//GGA - Global Positioning System Fix Data
	public var gga:Gga = new Gga();
	//GLL - Geographic Position - Latitude/Longitude
	public var gll:Gll = new Gll();
	//GSA - GNSS DOP and Active Satellites
	public var gsa:Object = {};
	//GSV - GNSS Satellites in View
	public var gsv:Object = {};
	//HDG - Heading, Deviation & Variation
	public var hdg:Hdg = new Hdg();
	//HDT - Heading, True
	public var hdt:Object = {};
	//HSC - Heading Steering Command
	public var hsc:Hsc = new Hsc();
	//MTW - Water Temperature
	public var mtw:Mtw = new Mtw();
	//MWD - Wind Direction & Speed
	public var mwd:Object = {};
	//MWV - Wind Speed and Angle
	public var mwv:Mwv = new Mwv();
	//RMB - Recommended Minimum Navigation Information
	public var rmb:Object = {};
	//RMC - Recommended Minimum Specific GNSS Data
	public var rmc:Rmc =new Rmc();
	//ROT - Rate Of Turn
	public var rot:Object = {};
	//RSA - Rudder Sensor Angle
	public var rsa:Rsa = new Rsa();
	//RTE - Routes RTE - Routes
	public var rte:Object = {};
	//STN - Multiple Data ID
	public var stn:Object = {};
	//VDR - Set and Drift
	public var vdr:Object = {};
	//VDM - UAIS VHF Data-link Message
	public var vdm:Vdm = new Vdm();
	//VHW - Water Speed and Heading
	public var vhw:Vhw = new Vhw();
	//VLW - Dual Ground/Water Distance
	public var vlw:Vlw = new Vlw();
	//VPW - Speed - Measured Parallel to Wind
	public var vpw:Object = {};
	//VTG - Course Over Ground and Ground Speed
	public var vtg:Object = {};
	//WCV - Waypoint Closure Velocity
	public var wcv:Object = {};
	//WNC - Distance - Waypoint to Waypoint
	public var wnc:Object = {};
	//WPL - Waypoint Location
	public var wpl:Object = {};
	//XDR - Transducer Measurements
	public var xdr:Object = {};
	//XTE - Cross-Track Error, Measured
	public var xte:Object = {};
	//XTR - Cross-Track Error - Dead Reckoning
	public var xtr:Object = {};
	//ZDA - Time & Date
	public var zda:Object = {};
	//ZFO - UTC & Time from Origin Waypoint
	public var zfo:Object = {};
	//ZTG - UTC & Time to Destination Waypoint
	public var ztg:Object = {};
	//HCC - Compass Heading
	public var hcc:Object = {};
	//HCD - Heading and Deviation
	public var hcd:Object = {};
	//HDM - Heading, Magnetic
	public var hdm:Hdm = new Hdm();
	///HTC - Heading, True
	public var htc:Object = {};
	//HVM - Magnetic Variation, Manually Set
	public var hvm:Object = {};
	//MDA - Meteorological Composite
	public var mda:Object = {};
	//MHU - Humidity
	public var mhu:Object = {};
	//MMB - Barometer
	public var mmb:Object = {};
	//MTA - Air Temperature
	public var mta:Object = {};
	//VWR - Relative (Apparent) Wind Speed and Angle
	public var vwr:Vwr = new Vwr();
	//VWT - True Wind Speed and Angle
	public var vwt:Object = {
		relativeWindAngleToVessel:Number,
		windSpeedKnots:Number	
	};
	//WDC - Distance to Waypoint
	public var wdc:Object = {
		distance:Number, //nautrical miles
		waypointID:Number
	};
	//ZLZ - Time of Day
	public var zlz:Object = {
		utc:Date,
		localTime:Date,
		localZoneDesc:Number
	};
	//ZZU - Time, UTC
	public var zzu:Object = {
		utc:Date
	};
}

	
	


}
