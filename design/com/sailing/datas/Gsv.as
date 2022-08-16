package com.sailing.datas
{
	public class Gsv
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
		
		public function Gsv()
		{
		}
	}
}