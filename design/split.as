package 
{
	import flash.display.Sprite;
	
	public class split extends Sprite
	{
		public function split()
		{
	
		}

		static public function _a(num):String
		{
			var h = Math.round(num*10)/10;
			var _a = Math.floor(h);
			return String(_a);
		}
		
		static public function _b(num):String
		{
			var h = Math.round(num*10)/10;
			var _a = Math.floor(h);
			var _b = Math.round((h-_a)*10);
			return String(_b);
		}
	}
}