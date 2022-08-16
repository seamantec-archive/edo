package as3_nmea
{
	public class nmea_packeter
	{
		private var errorCount:Number = 0;
		
		protected static const NMEA_START1:String = '$';
		protected static const NMEA_START2:String = '!';
		protected static const NMEA_END:String = '\n';
		protected static const MAX_NMEA_MESSAGE_LEN: uint = 140;
		
		public function nmea_packeter()
		{
		}
		
		public function readPacket(buffer:String):Array
		{
			var packetStart:uint = 0;
			var packetEnd:uint = 0;
			
			while (packetStart < buffer.length)
			{
				if (buffer.charAt(packetStart) == NMEA_START1 || buffer.charAt(packetStart) == NMEA_START2)
				{
					packetEnd = ++packetStart;
					while (packetEnd < buffer.length)
					{
						var nextChar:String = buffer.charAt(packetEnd);
						if (nextChar == NMEA_END) break;
						
						// todo: more exit conditions
						if (((packetEnd - packetStart) > MAX_NMEA_MESSAGE_LEN) || nextChar == NMEA_START1 || nextChar == NMEA_START2)
						{
							return ["", buffer.substr(packetEnd, buffer.length)];
						}
						
						++packetEnd;
					}
					
					if (packetStart != packetEnd)
					{
						// Calculate checksum
						var checksum:int = 0;
						for (var i:uint = packetStart; i < packetEnd - 3; ++i)
						{
							checksum ^= buffer.charCodeAt(i);
						}
						
						var originalChecksumString: String = buffer.substr(packetEnd-2, 2);
						if (originalChecksumString.charAt(0) == '0')
						{
							originalChecksumString = originalChecksumString.slice(1, 2);
						}
						
						if (originalChecksumString.toLowerCase() == checksum.toString(16).toLowerCase())
						{
							// checksum OK
							return [buffer.substr(packetStart, packetEnd - 4), buffer.substr(packetEnd + 1, buffer.length)];
						}
						else
						{
							// Checksum FAIL
							++errorCount;
						}
						
						return ["", buffer.substr(packetEnd, buffer.length)];
					}
				}
				
				++packetStart;
			}
			
			return ["", buffer.substr(packetStart, buffer.length)];
		}
	}
}
