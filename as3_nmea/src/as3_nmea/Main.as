package as3_nmea
{
	import as3_nmea.ais.ais_decode_helper;
	import as3_nmea.ais.ais_message123;
	import as3_nmea.ais.ais_message5;
	import flash.display.Sprite;
	import flash.events.Event;
	import as3_nmea.nmea_socket;

	public class Main extends Sprite 
	{
		
		private var s:nmea_socket =  new nmea_socket();
			
		protected function test_nmea():void
		{
			s.Connect();
		}	
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			var m: nmea_aivdm_message = new nmea_aivdm_message();
			
			m.parse("AIVDM,1,1,,B,15MqvC0Oh9G?qinK?VlPhA480@2n,0*1F");
			m.parse("AIVDM,1,1,,B,15Mf@6P001G?v68K??4SejL<00Sl,0*71");
			m.parse("AIVDM,1,1,,B,15Mn4kPP01G?qNvK>:grkOv<0<11,0*55");
			m.parse("AIVDM,1,1,,B,15O1Pv0022o?GeNKB3f7QV2>00SP,0*26");
			m.parse("AIVDM,1,1,,B,15MqvC0Oh:G?qj0K?Vp@di4B0@5>,0*44");
			m.parse("AIVDM,1,1,,B,15NcRf0P3wG?Wq`K>o=RP?vB0<1J,0*7B");
			
			m.parse("AIVDM,2,1,3,A,539QcE029W?0A5`t00118Tq>0l5E8UA<0000000N00`080@VN<QACDj0,0*4D");
			m.parse("AIVDM,2,2,3,A,EQCP00000000008,2*28");
			m.parse("AIVDM,2,1,4,A,544j0:023DTAD5Pp001<E8LEV0eE`pEA<uH000169P;671a80>A1C1VR,0*5B");
			m.parse("AIVDM,2,2,4,A,BS0000000000000,2*31");
			
			// test_nmea();
		}
		
	}
}