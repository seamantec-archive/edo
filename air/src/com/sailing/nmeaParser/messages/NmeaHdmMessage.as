package com.sailing.nmeaParser.messages
{

import com.sailing.datas.Hdm;

/*
HDM - Heading, Magnetic
HDM,235.,M
HDM          Heading, Magnetic
235.,M       Heading 235 deg. Magnetic
(HDG, which includes deviation and variation, is recommended instead)
*/
	
	public class NmeaHdmMessage implements NmeaMessage
	{
				
		private var data:Hdm = new Hdm();
		
		public function parse(packet:String):void
		{
					
			var parts:Array = packet.split(",");
			
			if (parts[1].length)
			{
				data.heading.value = Number(parts[1]);
			}
			
		}
		
		public function process():Object
		{
			return {key: "hdm", data: data}
		}
		
		public function NmeaHdmMessage()
		{
		}
	}
}