package com.sailing.nmeaParser.messages
{
import com.sailing.datas.Gsa;

/**
	 *GSA - GNSS DOP and Active Satellites
	 * 		 				satelite ids
	 * 		 1. 2. ---------------------------------   3.  4.  5.
	 * 		 |	|  | |  |  |  |  |   |  |  |  | |  |   |   |   |  
	 * $--GSA,a,x,xx,xx,xx,xx,xx,xx,xx,xx,xx,xx,xx,xx,x.x,x.x,x.x*hh<CR><LF> 
	 * 
	 * 1. Mode (M=Manual, A=Automatic)
	 * 2. Mode (1 = Fix not available, 2 = 2D, 3 = 3D)
	 * 
	 * 3. PDOP
	 * 4. HDOP
	 * 5. VDOP
	 * 
	 * http://en.wikipedia.org/wiki/Dilution_of_precision_(GPS) 
	 * 
	 * */
	
	
	
	public class NmeaGsaMessage implements NmeaMessage
	{
		private var data:Gsa = new Gsa();
		
				
		public function parse(packet:String):void
		{
			var parts:Array = packet.split(",");
			
			if(parts[2] === "1"){
				data.mode = "X";
			}else if(parts[2] === "2"){
				data.mode = "2D";
			}else if(parts[2] === "3"){
				data.mode = "3D";
			}
			
			for(var i:int=3;i<14;i++){
				data.sateliteIds.push(parts[i]);
			}
			
			data.pdop = new Number(parts[14]);
			data.hdop = new Number(parts[15]);
			data.vdop = new Number(parts[16]);
			
		}
		
		public function process():Object
		{
			return {key: "gsa", data: data}		
		}
	}
}