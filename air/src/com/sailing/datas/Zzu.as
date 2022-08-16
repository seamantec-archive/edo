package com.sailing.datas
{
	public class Zzu extends BaseSailData
	{
		public var utc:String;

        public function Zzu() {
            super();
            _paramsDisplayName["utc"] = { displayName: "UTC", order: 0 };
        }

        public override function get displayName():String {
            return "Time (ZZU)";
        }
	}
}