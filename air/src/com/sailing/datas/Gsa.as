package com.sailing.datas
{
	public class Gsa extends BaseSailData
	{
		public var mode:String; //2D, 3D, X = not available
		public var sateliteIds:Array = [];
		public var pdop:Number = 0;
		public var hdop:Number = 0;
		public var vdop:Number = 0;

        public function Gsa() {
            super();
            _paramsDisplayName["mode"] = { displayName: "Mode", order: 0 };
            _paramsDisplayName["sateliteIds"] = { displayName: "ID numbers of satellites used in solution", order: 1 };
            _paramsDisplayName["pdop"] = { displayName: "PDOP", order: 2 };
            _paramsDisplayName["hdop"] = { displayName: "HDOP", order: 3 };
            _paramsDisplayName["vdop"] = { displayName: "VDOP", order: 4 };
        }

        public override function get displayName():String {
            return "GNSS DOP and Active Satellites (GSA)";
        }
	}
}