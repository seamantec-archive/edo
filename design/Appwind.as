package 
{
	import mx.flash.UIMovieClip;
	import com.events.UpdateSailingDatasEvent;
	import fl.transitions.Tween;
	import fl.transitions.easing.None;
	import flash.events.Event
	import fl.motion.easing.Back;
	import flash.events.MouseEvent;
	
	[Event(name = "updateSailing",type = "com.events.UpdateSailingDatasEvent")]
	
	public class Appwind extends UIMovieClip
	{
		public var updateVars:Array = [
		"wind.speed.knots",
		"wind.direction"		
		];
		var forgoTween:Tween;
		
		public function Appwind()
		{
			super();
			this.addEventListener(UpdateSailingDatasEvent.UPDATE_SAILING, updateDatas);
			this.forgoTween = new Tween (mutato, "rotation", Back.easeOut, 0, 0, 1, true);
						
					
			
		}

		private function updateDatas(e:UpdateSailingDatasEvent):void
		{
			var datas = e.data;
			
			digi_a.text = split._a(datas.wind_speed_knots);
			digi_b.text = split._b(datas.wind_speed_knots);


			this.forgoTween.continueTo(0 - datas.wind_direction, 1);
			mutato_temp.rotation = 0 - datas.wind_direction;
			
		}
	}
}