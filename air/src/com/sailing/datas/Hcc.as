package com.sailing.datas
{
	public class Hcc extends BaseSailData
	{
		public var compassHeading:Number = 0;

        public function Hcc() {
            super();
            _paramsDisplayName["compassHeading"] = { displayName: "Compass heading", order: 0 };
        }

        public override function get displayName():String {
            return "Compass Heading (HCC)";
        }
	}
}