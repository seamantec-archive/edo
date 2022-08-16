package com.sailing.nmeaParser.messages
{
import com.sailing.datas.Gsv;

//TODO Janival egyeztetni
	/**
	 * GSV - GNSS Satellites in View
	 * 
	 *        1.2. 3. 4. 5. 6.  7.    8.    9. 10.11. 12. 
	 *        | |  |  |  |  |   | |       | |  |  |   |
	 * $--GSV,x,x,xx,xx,xx,xxx,xx,.…….……..,xx,xx,xxx,xx*hh<CR><LF>
	 * 
	 * 1. Total number of sentences1, 1 to 9
	 * 2.  Sentence number1, 1 to 9
	 * 3. Total number of satellites in view
	 * 4. Satellite ID number
	 * 5. Elevation, degrees, 90o maximum
	 * 6. Azimuth, degrees True, 000 to 359
	 * 7. SNR (C/No) 00-99 dB-Hz, null when not tracking
	 * 8. 2nd-3rd SV
	 * 9-12. 4th SV
	 * 
	 * 
	 * 
	 * 
	 * */
	
	public class NmeaGsvMessage implements NmeaMessage
	{
		private var data:Gsv = new Gsv();
		
		public function parse(packet:String):void
		{
			var parts:Array = packet.split(",");
			
			data.totalNumberOfSentences = new Number(parts[1]);
			data.sentenceNumber = new Number(parts[2]);
			data.totalNumberOfSatellites = new Number(parts[3]);
			data.satelliteId = new Number(parts[4]);
			data.elevation = new Number(parts[5]);
			data.azimuth = new Number(parts[6]);
			data.snr = new Number(parts[7]);
			data.sv23 = new Number(parts[8]);
			var j:int=0;
			
			for(var i:int=parts.length-5; i<parts.length-1;i++){
				data.sv4[j] = new Number(parts[i]);
				j++;
			}
		}
		
		public function process():Object
		{
			return {key:"gsv", data:data};
		}
	}
}