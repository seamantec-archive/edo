package as3_nmea.ais 
{
	// info: http://gpsd.berlios.de/AIVDM.html
	public class ais_message5 
	{
		public var repeatIndicator: Number;
		public var mmsi: Number;
		public var aisVersion: Number;
	
		// vessel identification number (different than mmsi)
		public var imoNumber: Number;

		public var callsign: String;
		public var name: String;

		/// Type of ship and cargo type:
		// 20: Wing in ground (WIG), all ships of this type
		// 21: Wing in ground (WIG), Hazardous catagory A
		// 22: Wing in ground (WIG), Hazardous catagory B
		// 23: Wing in ground (WIG), Hazardous catagory C
		// 24: Wing in ground (WIG), Hazardous catagory D
		// 25: Wing in ground (WIG), Reserved for future use
		// 26: Wing in ground (WIG), Reserved for future use
		// 27: Wing in ground (WIG), Reserved for future use
		// 28: Wing in ground (WIG), Reserved for future use
		// 29: Wing in ground (WIG), No additional information
		// 30: fishing
		// 31: towing
		// 32: towing length exceeds 200m or breadth exceeds 25m
		// 33: dredging or underwater ops
		// 34: diving ops
		// 35: military ops
		// 36: sailing
		// 37: pleasure craft
		// 38: reserved
		// 39: reserved
		// 40: High speed craft (HSC), all ships of this type
		// 41: High speed craft (HSC), Hazardous catagory A
		// 42: High speed craft (HSC), Hazardous catagory B
		// 43: High speed craft (HSC), Hazardous catagory C
		// 44: High speed craft (HSC), Hazardous catagory D
		// 45: High speed craft (HSC), Reserved for future use
		// 46: High speed craft (HSC), Reserved for future use
		// 47: High speed craft (HSC), Reserved for future use
		// 48: High speed craft (HSC), Reserved for future use
		// 49: High speed craft (HSC), No additional information
		// 50: pilot vessel
		// 51: search and rescue vessel
		// 52: tug
		// 53: port tender
		// 54: anti-polution equipment
		// 55: law enforcement
		// 56: spare - local vessel
		// 57: spare - local vessel
		// 58: medical transport
		// 59: ship according to RR Resolution No. 18
		// 60: passenger, all ships of this type
		// 61: passenger, Hazardous catagory A
		// 62: passenger, Hazardous catagory B
		// 63: passenger, Hazardous catagory C
		// 64: passenger, Hazardous catagory D
		// 65: passenger, Reserved for future use
		// 66: passenger, Reserved for future use
		// 67: passenger, Reserved for future use
		// 68: passenger, Reserved for future use
		// 69: passenger, No additional information
		// 70: cargo, all ships of this type
		// 71: cargo, Hazardous catagory A
		// 72: cargo, Hazardous catagory B
		// 73: cargo, Hazardous catagory C
		// 74: cargo, Hazardous catagory D
		// 75: cargo, Reserved for future use
		// 76: cargo, Reserved for future use
		// 77: cargo, Reserved for future use
		// 78: cargo, Reserved for future use
		// 79: cargo, No additional information
		// 80: tanker, all ships of this type
		// 81: tanker, Hazardous catagory A
		// 82: tanker, Hazardous catagory B
		// 83: tanker, Hazardous catagory C
		// 84: tanker, Hazardous catagory D
		// 85: tanker, Reserved for future use
		// 86: tanker, Reserved for future use
		// 87: tanker, Reserved for future use
		// 88: tanker, Reserved for future use
		// 89: tanker, No additional information
		// 90: other type, all ships of this type
		// 91: other type, Hazardous catagory A
		// 92: other type, Hazardous catagory B
		// 93: other type, Hazardous catagory C
		// 94: other type, Hazardous catagory D
		// 95: other type, Reserved for future use
		// 96: other type, Reserved for future use
		// 97: other type, Reserved for future use
		// 98: other type, Reserved for future use
		// 99: other type, No additional information
		public var shipType: Number;

		// distance from bow to reference position (meters)
		public var dimensionToBow: Number;
		
		// distance from reference position to stern (meters)
		public var dimensionToStern: Number;
		
		// distance from port side to reference position (meters) (63: 63 m or greater)
		public var dimensionToPort: Number;
		
		// Distance from reference position to starboard side (meters) (63: 63 m or greater)
		public var dimensionToStarboard: Number;

		/// method used for positioning:
		// 0: undefined
		// 1: GPS
		// 2: GLONASS
		// 3: combined GPS/GLONASS
		// 4: Loran-C
		// 5: Chayka
		// 6: integrated navigation system
		// 7: surveyed
		public var positionFixType: Number;

		public var etaMonth: Number;
		public var etaDay: Number;
		public var etaHour: Number;
		public var etaMin: Number;

		// Maximum present static draught (25.5: 25.5 m or greater)
		public var draught: Number;
	
		public var destination: String;

		/// data terminal ready
		// 0: available
		// 1: not available
		public var dte: Number;

		// reserved for definition by a regional authority
		public var spare: Number;
	
		public function ais_message5() 
		{ }
		
		public function parse(decode_helper: ais_decode_helper, payload: String): Boolean
		{
			if (payload.length != 71) return false;

			// 424 + 2 spare bits => 71 characters
			var bits: bitarray = new bitarray(426);
			if (!decode_helper.get_bits(payload, bits)) return false;

			var messageId: uint = decode_helper.get_unsigned(bits, 0, 6);
			if (messageId != 5)
			{
				return false;
			}

			repeatIndicator = decode_helper.get_unsigned(bits, 6, 2);
			mmsi = decode_helper.get_unsigned(bits, 8, 30);

			aisVersion = decode_helper.get_unsigned(bits, 38, 2);
			imoNumber = decode_helper.get_unsigned(bits, 40, 30);
			callsign = decode_helper.get_string(bits, 70, 42);

			name = decode_helper.get_string(bits, 112, 120);

			shipType = decode_helper.get_unsigned(bits, 120, 8);
			dimensionToBow = decode_helper.get_unsigned(bits, 240, 9);
			dimensionToStern = decode_helper.get_unsigned(bits, 249, 9);
			dimensionToPort = decode_helper.get_unsigned(bits, 258, 6);
			dimensionToStarboard = decode_helper.get_unsigned(bits, 264, 6);
			positionFixType = decode_helper.get_unsigned(bits, 270, 4);
			etaMonth = decode_helper.get_unsigned(bits, 274, 4);
			etaDay = decode_helper.get_unsigned(bits, 278, 5);
			etaHour = decode_helper.get_unsigned(bits, 283, 5);
			etaMin = decode_helper.get_unsigned(bits, 288, 6);
			draught = Number(decode_helper.get_unsigned(bits, 294, 8)) / 10.0;
			destination = decode_helper.get_string(bits, 302, 120);
			dte = decode_helper.get_unsigned(bits, 422, 1);
			spare = decode_helper.get_unsigned(bits, 423, 1);

			return true;
		}
	}
}
