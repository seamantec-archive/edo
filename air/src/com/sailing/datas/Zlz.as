package com.sailing.datas
{
	public class Zlz  extends BaseSailData
	{
		public var utc:String;
		public var hour:Number = 0;
		public var min:Number = 0;
		public var sec:Number = 0;
		public var localTime:String;
		public var localZoneDesc:Number = 0;

        public function Zlz() {
            super();
            _paramsDisplayName["utc"] = { displayName: "UTC", order: 0 };
            _paramsDisplayName["hour"] = { displayName: "Hour", order: 1 };
            _paramsDisplayName["min"] = { displayName: "Minute", order: 2 };
            _paramsDisplayName["sec"] = { displayName: "Second", order: 3 };
            _paramsDisplayName["localTime"] = { displayName: "Local time", order: 4 };
            _paramsDisplayName["localZoneDesc"] = { displayName: "Local zone description", order: 5 };
        }

        public override function get displayName():String {
            return "Time of Day (ZLZ)";
        }
	}
}