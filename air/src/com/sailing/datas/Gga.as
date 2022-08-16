package com.sailing.datas
{
	public class Gga  extends BaseSailData
	{
		public var timeMsUtc: Number =0;
		public var hour:Number = 0;
		public var min:Number = 0;
		public var sec:Number = 0;
		public var lat: Number=0;
		public var lon: Number=0;
		public var numTrackedSat: Number=0;
		public var alt: Number=0;

        public function Gga() {
            super();
            _paramsDisplayName["timeMsUtc"] = { displayName: "UTC in ms", order: 0 };
            _paramsDisplayName["hour"] = { displayName: "Hour", order: 1 };
            _paramsDisplayName["min"] = { displayName: "Minute", order: 2 };
            _paramsDisplayName["sec"] = { displayName: "Second", order: 3 };
            _paramsDisplayName["lat"] = { displayName: "Latitude", order: 4 };
            _paramsDisplayName["lon"] = { displayName: "Longitude", order: 5 };
            _paramsDisplayName["numTrackedSat"] = { displayName: "Number of satellites in use", order: 7 };
            _paramsDisplayName["alt"] = { displayName: "Altitude", order: 6 };
        }

        public override function get displayName():String {
            return "Global Positioning System Fix Data (GGA)";
        }
	}
}