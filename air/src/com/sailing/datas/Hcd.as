package com.sailing.datas
{
	public class Hcd extends BaseSailData
	{
		public var magneticHeading:Number = 0;
		public var compassHeading:Number = 0;
		public var magneticDeviation:Number = 0;

        public function Hcd() {
            super();
            _paramsDisplayName["magneticHeading"] = { displayName: "Magnetic heading", order: 0 };
            _paramsDisplayName["compassHeading"] = { displayName: "Compass heading", order: 1 };
            _paramsDisplayName["magneticDeviation"] = { displayName: "Magnetic deviation", order: 2 };
        }

        public override function get displayName():String {
            return "Heading and Deviation (HCD)";
        }
	}
}