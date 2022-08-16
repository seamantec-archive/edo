package as3_nmea
{
	public interface nmea_message
	{
		function parse(packet:String):Boolean;
		function process():Boolean;
	}
}