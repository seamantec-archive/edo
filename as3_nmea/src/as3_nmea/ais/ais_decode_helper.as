package as3_nmea.ais 
{
	import flash.sampler.NewObjectSample;
	public class ais_decode_helper 
	{
		private var payloadLookup: Array = new Array(128);
		private var charTable: String = "@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^- !\"#$%&`()*+,-./0123456789:;<=>?";
		
		public function get_bits(payload: String, bits: bitarray) : Boolean
		{
			if (payload.length > bits.length / 6)
			{
				// the message is too long
				return false;
			}

			for (var i: uint = 0; i < bits.length / 6; ++i)
			{
				var c: int = payload.charCodeAt(i);

				if (c < 48 || c > 119 || (c >= 88 && c <= 95) )
				{
					// bad character is in the payload
					return false;
				}
				
				var charBitArray : bitarray = payloadLookup[c];
				
				for (var offset: uint = 0; offset < 6; ++offset)
				{
					bits.set_at(i * 6 + offset, charBitArray.get_at(offset));
				}
			}
		
			return true;
		}

		public function get_unsigned(bits: bitarray, start: uint, len: uint) : uint
		{
			var tmp: bitarray = new bitarray(32);
			for (var i:uint = 0; i < len; i++)
			{
				tmp.set_at(i, bits.get_at(start + len - i - 1));
			}
			
			return tmp.get_uint();
		}
		
		public function get_signed(bits: bitarray, start: uint, len: uint) : int
		{
			var bs32: bitarray = new bitarray(32);
			if (len < 32 && 1 == bits.get_at(start))
			{
				// pad 1's to the left if negative
				bs32.flip();
			}

			for (var i:uint = 0; i < len; i++)
			{
				bs32.set_at(i, bits.get_at(start + len - i - 1));
			}
			
			return int(bs32.get_uint());
		}		
		
		public function get_string(bits: bitarray, start: uint, len: uint) : String
		{
			var numChars:uint = len / 6;
			var result:String = "";
			
			for (var charIndex:uint = 0; charIndex < numChars; ++charIndex)
			{
				var charCode:uint = get_unsigned(bits, start + charIndex * 6, 6);
				result += charTable.charAt(charCode);
			}
			
			return (result.split("@", 2))[0];
		}
	
		public function ais_decode_helper()
		{
			// create payload lookup table
			for (var i: int = 0; i < 128; ++i)
			{
				var value: int = i - 48;
		
				if (value >= 40)
				{
					value -= 8;
				}
		
				if (value < 0)
				{
					continue;
				}
				
				var bits: bitarray = new bitarray(6);
				bits.set_value(value);
				var x: uint = bits.get_uint();
				
				var tmp: Boolean;
				tmp = bits.get_at(5); bits.set_at(5, bits.get_at(0)); bits.set_at(0, tmp);
				tmp = bits.get_at(4); bits.set_at(4, bits.get_at(1)); bits.set_at(1, tmp);
				tmp = bits.get_at(3); bits.set_at(3, bits.get_at(2)); bits.set_at(2, tmp);

				payloadLookup[i] = bits;
			}
		}
	}
}
