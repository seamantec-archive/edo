package as3_nmea.ais 
{
	import flash.utils.Dictionary;
	public class ais_interpreter 
	{
		private static var instance: ais_interpreter;
		private var decodeHelper: ais_decode_helper;
		private var fragments: Dictionary;
		
		public static function getInstance(): ais_interpreter
		{
			if (instance == null)
			{
				instance = new ais_interpreter(new SingletonBlocker());
			}
			
			return instance;
		}
		
		public function ais_interpreter(p: SingletonBlocker) 
		{
			if (p == null)
			{
				throw new Error("Error: Instantiation failed: Use SingletonDemo.getInstance() instead of new.");
			}
			
			decodeHelper = new ais_decode_helper();
			fragments = new Dictionary();
		}
		
		public function interpret(numFragments: int, fragmentIndex: int, messageId: int, payLoad: String): Boolean
		{
			if (numFragments == 1)
			{
				return parsePayLoad(payLoad);
			}
			else
			{
				if (fragmentIndex == 1 && fragments[messageId] == null)
				{
					fragments[messageId] = new String(payLoad);
				}
				else if (fragments[messageId] != null)
				{
					fragments[messageId] += payLoad;
				}
				
				if (fragmentIndex == numFragments && fragments[messageId] != null)
				{
					return parsePayLoad(fragments[messageId]);
					delete fragments[messageId];
				}
			}
			
			return false;
		}
		
		private function parsePayLoad(payLoad: String): Boolean
		{
			var bits: bitarray = new bitarray(6);
			if (!decodeHelper.get_bits(new String(payLoad.charAt(0)), bits))
			{
				return false;
			}

			var messageId: uint = decodeHelper.get_unsigned(bits, 0, 6);
			
			switch (messageId)
			{
				case 1:
				case 2:
				case 3:
					var m123: ais_message123 = new ais_message123();
					return m123.parse(decodeHelper, payLoad);
				case 5:
					var m5: ais_message5 = new ais_message5();
					return m5.parse(decodeHelper, payLoad);
				default:
					break;
			}
			
			return false;
		}
	}	
}

internal class SingletonBlocker { }
