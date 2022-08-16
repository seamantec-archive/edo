package as3_nmea.ais 
{
	// info: http://gpsd.berlios.de/AIVDM.html
	public class ais_message123 
	{
		public var repeatIndicator: Number;
		public var mmsi: Number;
		
		/// what is the vessel doing
		// 0: under way using engine
		// 1: at anchor
		// 2: not under command
		// 3: restricted maneuverability
		// 4: constrained by her draught
		// 5: moored
		// 6: aground
		// 7: engaged in fishing
		// 8: under way sailing
		// 9-14: reserved for future use (hazmat)
		// 15: not defined = default
		public var navStatus: Number;
		
		public var rateOfTurnOverRange: Boolean;

		/// rate of turning
		// positive: right 
		// negative: left
		public var rateOfTurn: Number;
		
		// accuracy of positioning fixes
		// 0: low (greater than 10 m)
		// 1: high (less than 10 m)
		public var positionAccuracy: Number;
    
		// longitude and latitude
		public var x: Number;
		public var y: Number;
    
		public var courseOverGround: Number;

		// true heading (relative to true North)
		public var trueHeading: Number;

		// speed over ground in knots (102.2: 102.2 knots or higher)
		public var speedOverGround: Number;
		
		// UTC seconds when the report was generated
		// 60: not available/default
		// 61: manual input
		// 62: dead reckoning
		// 63: inoperative
		public var timeStamp: Number;
    
		public var specialManoeuvre: Number;
		public var spare: Number;
	
		// receiver autonomous integrity monitoring flag
		// false: not in use
		// true: in use
		public var receiverAutonomousIntegrityFlag: Boolean;

		// communications State - SOTDMA Sycronization state
		// 0: UTC direct
		// 1: UTC indirect
		// 2: synchronized to a base station
		// 3: synchronized to another station
		public var syncState: Number;
		
		
		// communications State - SOTDMA Frames remaining until a new slot is selected
		// 0: Last frame in this slot
		// 1: 1 frames left
		// 2: 2 frames left
		// 3: 3 frames left
		// 4: 4 frames left
		// 5: 5 frames left
		// 6: 6 frames left
		// 7: 7 frames left
		public var slotTimeOut: Number;

		// Based on slot_timeout which ones are valid
		public var receivedStations: Number;
		public var receivedStationsValid: Boolean;
    
		public var slotNumber: Number;
		public var slotNumberValid: Boolean;

		public var utcHour: Number;
		public var utcMin: Number;
		public var utcSpare: Number;
		public var utcValid: Boolean;

		// communications State - SOTDMA In what slot will the next transmission occur
		public var slotOffset: Number;
		public var slotOffsetValid: Boolean;

		// ITDMA - msg type 3
		public var slotIncrement: Number;
		public var slotIncrementValid: Boolean;

		public var slotsToAllocate: Number;
		public var slotsToAllocateValid: Boolean;

		public var keepFlag: Boolean;
		public var keepFlagValid: Boolean;
		
		public function ais_message123() 
		{ }
		
		public function parse(decode_helper: ais_decode_helper, payload: String) : Boolean
		{
			// bit count is wrong
			if (payload.length != 168 / 6) return false;

			var bits: bitarray = new bitarray(168);
			if (!decode_helper.get_bits(payload, bits)) return false;

			var messageId: uint = decode_helper.get_unsigned(bits, 0, 6);
			if (messageId < 1 || messageId > 3)
			{
				return false;
			}

			repeatIndicator = decode_helper.get_unsigned(bits, 6, 2);
			mmsi = decode_helper.get_unsigned(bits, 8, 30);
			
			navStatus = decode_helper.get_unsigned(bits, 38, 4);

			var rot_raw: Number = decode_helper.get_signed(bits, 42, 8);
			rateOfTurnOverRange = Math.abs(rot_raw) > 126 ? true : false ;
			rateOfTurn = 4.733 * Math.sqrt(Math.abs(rot_raw));
			if (rot_raw < 0) rateOfTurn = -rateOfTurn;

			speedOverGround = Number(decode_helper.get_unsigned(bits, 50, 10)) / 10.0;
			positionAccuracy = decode_helper.get_unsigned(bits, 60, 1);
			x = Number(decode_helper.get_signed(bits, 61, 28)) / 600000.0;
			y = Number(decode_helper.get_signed(bits, 89, 27)) / 600000.0;
			courseOverGround = Number(decode_helper.get_unsigned(bits, 116, 12)) / 10.0;

			trueHeading = decode_helper.get_unsigned(bits, 128, 9);
			timeStamp = decode_helper.get_unsigned(bits, 137, 6);
			specialManoeuvre = decode_helper.get_unsigned(bits, 143, 2);
			spare = decode_helper.get_unsigned(bits, 145, 3);
			receiverAutonomousIntegrityFlag = Boolean(bits[148]);

			syncState = decode_helper.get_unsigned(bits, 149, 2);

			// Set all to invalid - this way we don't have to track it in multiple places
			receivedStations = -1;
			receivedStationsValid = false;
			
			slotNumber = -1;
			slotNumberValid = false;
			
			utcHour = utcMin = -1;
			utcValid = false;
			
			slotOffset = -1;
			slotOffsetValid = false;

			slotIncrement = -1;
			slotIncrementValid = false;
			
			slotsToAllocate = -1;
			slotsToAllocateValid = false;
			
			keepFlag = false;
			keepFlagValid = false;

			if (1 == messageId || 2 == messageId)
			{
				slotTimeOut = decode_helper.get_unsigned(bits, 151, 3);

				switch (slotTimeOut)
				{
				case 0:
					slotOffset = decode_helper.get_unsigned(bits, 154, 14);
					slotOffsetValid = true;
					break;
				case 1:
					utcHour = decode_helper.get_unsigned(bits, 154, 5); 
					utcMin = decode_helper.get_unsigned(bits, 159, 7);
					utcSpare = decode_helper.get_unsigned(bits, 166, 2);
					utcValid = true;
					break;
				case 2:
				case 4:
				case 6:
					slotNumber = decode_helper.get_unsigned(bits, 154, 14);
					slotNumberValid = true;
					break;
				case 3:
				case 5:
				case 7:
					receivedStations = decode_helper.get_unsigned(bits, 154, 14);
					receivedStationsValid = true;
					break;
				default:
					break;
				}
			}
			else
			{
				slotIncrement = decode_helper.get_unsigned(bits, 151, 13);
				slotIncrementValid = true;

				slotsToAllocate = decode_helper.get_unsigned(bits, 164, 3);
				slotsToAllocateValid = true;

				keepFlag = bits.get_at(167);
				keepFlagValid = true;
			}

			return true;
		}
	}
}
