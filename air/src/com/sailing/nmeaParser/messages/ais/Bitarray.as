package com.sailing.nmeaParser.messages.ais
{
	public class Bitarray
	{
		private var arrayFields: Array;
		private var bitLength: int;
		
		public function Bitarray(length: int = 0)
		{
			var fields: uint = uint(Math.ceil(Number(length) / 32.0)) || 1;
			arrayFields = new Array(fields);
			
			for (var f:uint = 0; f < fields; f++)
			{
				arrayFields[f] = uint(0);
			}
			
			bitLength = length;
		}
		
		public function set_value(value: uint): void
		{
			for (var i: uint = 0; i < 32; ++i)
			{
				set_at(i, Boolean((value >> i) & 1));
			}
		}
		
		public function get length(): int
		{
			return bitLength;
		}
		
		public function flip(): void
		{
			for (var i: uint = 0; i < bitLength; ++i)
			{
				set_at(i, get_at(i) ? false : true);
			}
		}
		
		public function get_at(index: uint): Boolean
		{
			var bitIndex: uint = index & 31; // index % 32
			var fieldIndex: uint = uint(index / 32);
			var mask: uint = (1 << bitIndex);
			var word: uint = arrayFields[fieldIndex];
			return Boolean(uint(word & mask));
		}
		
		
		public function set_at(index: uint, value: Boolean): void
		{
			var bitIndex: uint = index & 31; // index % 32
			var fieldIndex: uint = uint(index / 32);
			
			var mask: uint = (1 << bitIndex);
			var word: uint = arrayFields[fieldIndex];
			
			arrayFields[fieldIndex] ^= (-uint(value) ^ word) & mask;
		}
		
		public function get_uint() : uint
		{
			var returnValue: uint = 0;
			
			for (var i: uint = 0; i < length; ++i)
			{
				if (i > 32)
				{
					break;
				}
				var x: Boolean = get_at(i);
				var y: uint = uint(x) << i;
				returnValue |= y;
			}
			
			return returnValue;
		}
	}
}
