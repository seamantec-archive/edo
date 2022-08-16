package com.sailing.datas
{
	public class Gsv extends BaseSailData
	{
		public var totalNumberOfSentences:Number = 0;
		public var sentenceNumber:Number = 0;
		public var totalNumberOfSatellites:Number = 0;
		public var satelliteId:Number = 0;
		public var elevation:Number = 0; //In degrees max 90
		public var azimuth:Number = 0; //degrees true, 000 to 359
		public var snr:Number = 0;
		public var sv23:Number = 0;
		public var sv4:Vector.<Number> = new Vector.<Number>(4);

        public function Gsv() {
            super();
            _paramsDisplayName["totalNumberOfSentences"] = { displayName: "Total number of sentences", order: 0 };
            _paramsDisplayName["sentenceNumber"] = { displayName: "Sentence number", order: 1 };
            _paramsDisplayName["totalNumberOfSatellites"] = { displayName: "Total number of satellites", order: 2 };
            _paramsDisplayName["satelliteId"] = { displayName: "Satellite ID", order: 3 };
            _paramsDisplayName["elevation"] = { displayName: "Elevation", order: 4 };
            _paramsDisplayName["azimuth"] = { displayName: "Azimuth", order: 5 };
            _paramsDisplayName["snr"] = { displayName: "SNR", order: 6 };
            _paramsDisplayName["sv23"] = { displayName: "2. & 3. SV", order: 7 };
            _paramsDisplayName["sv4"] = { displayName: "4. SV", order: 8 };
        }

        public override function get displayName():String {
            return "GNSS Satellites in View (GSV)";
        }
	}
}