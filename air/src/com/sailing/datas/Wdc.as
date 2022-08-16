package com.sailing.datas
{
	public class Wdc extends BaseSailData
	{
		public var distance:Number = 0; //nautrical miles
		public var waypointID:String;

        public function Wdc() {
            super();
            _paramsDisplayName["distance"] = { displayName: "Distance to waypoint", order: 0 };
            _paramsDisplayName["waypointID"] = { displayName: "Waypoint ID", order: 1 };
        }

        public override function get displayName():String {
            return "Distance to Waypoint (WDC)";
        }
	}
}