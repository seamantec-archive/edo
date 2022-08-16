package com.sailing.datas
{
	public class Rotnmea extends BaseSailData
	{
		public var rateOfTurn:Number = 0;
		public var rotStatus:Number = 0;

        public function Rotnmea() {
            super();
            _paramsDisplayName["rateOfTurn"] = { displayName: "Rate of turn", order: 0 };
            _paramsDisplayName["rotStatus"] = { displayName: "Status", order: 1 };
        }

        public override function get displayName():String {
            return "Rate Of Turn (ROT)";
        }
	}
}