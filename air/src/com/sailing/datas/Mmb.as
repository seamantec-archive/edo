package com.sailing.datas
{
	public class Mmb  extends BaseSailData
	{
		public var pressureIncOfMercury:Number = 0;
		public var pressureBar:Number = 0;

        public function Mmb() {
            super();
            _paramsDisplayName["pressureIncOfMercury"] = { displayName: "Barometric pressure (inches of mercury)", order: 0 };
            _paramsDisplayName["pressureBar"] = { displayName: "Barometric pressure (bars)", order: 1 };
        }

        public override function get displayName():String {
            return "Barometer (MMB)";
        }
	}
}