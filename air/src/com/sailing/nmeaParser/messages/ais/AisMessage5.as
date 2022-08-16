package com.sailing.nmeaParser.messages.ais 
{
import com.sailing.ais.AisContainer;
import com.sailing.ais.Vessel;

// info: http://gpsd.berlios.de/AIVDM.html
	public class AisMessage5 
	{
		public var repeatIndicator: Number;
		public var mmsi: String;
		public var aisVersion: Number;
	

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



		/// data terminal ready
		// 0: available
		// 1: not available
		public var dte: Number;

		// reserved for definition by a regional authority
		public var spare: Number;
	    public var ship:Vessel;
		public function AisMessage5() 
		{ }
		
		public function  parse(decode_helper: AisDecodeHelper, payload: String): void
		{
			if (payload.length != 71) return;

			// 424 + 2 spare bits => 71 characters
			var bits:Bitarray = new Bitarray(426);
			if (!decode_helper.get_bits(payload, bits)) return;

			var messageId: uint = decode_helper.get_unsigned(bits, 0, 6);
			if (messageId != 5)
			{
				return;
			}

			repeatIndicator = decode_helper.get_unsigned(bits, 6, 2);
			mmsi = decode_helper.get_unsigned(bits, 8, 30).toString();
            ship = AisContainer.instance.getVessel(mmsi, true);
            if(ship == null){
                return;
            }
			aisVersion = decode_helper.get_unsigned(bits, 38, 2);
            ship.imoNumber = decode_helper.get_unsigned(bits, 40, 30);
            ship.callsign = decode_helper.get_string(bits, 70, 42);

            ship.name = decode_helper.get_string(bits, 112, 120);

            ship.shipType = decode_helper.get_unsigned(bits, 232, 8);
            ship.dimensionToBow = decode_helper.get_unsigned(bits, 240, 9);
            ship.dimensionToStern = decode_helper.get_unsigned(bits, 249, 9);
            ship.dimensionToPort = decode_helper.get_unsigned(bits, 258, 6);
            ship.dimensionToStarboard = decode_helper.get_unsigned(bits, 264, 6);
			positionFixType = decode_helper.get_unsigned(bits, 270, 4);
			etaMonth = decode_helper.get_unsigned(bits, 274, 4);
			etaDay = decode_helper.get_unsigned(bits, 278, 5);
			etaHour = decode_helper.get_unsigned(bits, 283, 5);
			etaMin = decode_helper.get_unsigned(bits, 288, 6);
            ship.draught = Number(decode_helper.get_unsigned(bits, 294, 8)) / 10.0;
            ship.destination = decode_helper.get_string(bits, 302, 120);
			dte = decode_helper.get_unsigned(bits, 422, 1);
			spare = decode_helper.get_unsigned(bits, 423, 1);

		}
	}
}
