package com.sailing.nmeaParser.messages
{
	public interface NmeaMessage
	{
		function parse(packet:String):void;
		function process():Object;
	}
}