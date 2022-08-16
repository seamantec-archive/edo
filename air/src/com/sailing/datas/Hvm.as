package com.sailing.datas
{
	public class Hvm extends BaseSailData
	{
		public var magneticVariation:Number = 0;
		public var magneticDirection:String = "";

        public function Hvm() {
            super();
            _paramsDisplayName["magneticVariation"] = { displayName: "Magnetic variation", order: 0 };
            _paramsDisplayName["magneticDirection"] = { displayName: "Magnetic direction", order: 1 };
        }

        public override function get displayName():String {
            return "Magnetic Variation, Manually Set (HVM)";
        }
	}
}