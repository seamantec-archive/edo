package 
{
	import mx.flash.UIMovieClip;
	import com.events.*;
	import fl.transitions.Tween;
	import fl.transitions.easing.None;
	import com.sailing.ForgatHandler;
	import flash.events.Event
	import fl.motion.easing.Back;
	import flash.events.MouseEvent;
	import com.sailing.SailData;
	
	[Event(name = "updateSailing",type = "com.events.UpdateSailingDatasEvent")]
    [Event(name = "update-state", type = "com.events.UpdateStateEvent")]

	public class mwv_rel extends UIMovieClip
	{
		public var updateVars:Array = [
		"mwv"		
		];
	
		public var actualState:String = "";
	
		var forgatHandler:ForgatHandler;
		
		var apparent:Boolean = true
		
		
		public function mwv_rel()
		{
			super();
			this.addEventListener(UpdateSailingDatasEvent.UPDATE_SAILING, updateDatas);
			
			forgatHandler = new ForgatHandler(mutato, this);
			this.mutato.visible = false;
			
			this.addEventListener("custom-click", valtas);
			this.switch_btn.addEventListener("update-state", updateState);
	//TODO nem jegyzi meg az allapotat es nem is tudja kezelni a switch_btn-t kombkent.
			
		}
	//TODO itt meg kene csinalni, hogy valtasnal egybol updatelje a mutatot.		
		private function valtas(event:Event):void
		{	
			if (apparent)
			{
				this.label.text = "Apparent"
				actualState = "apparentw";
				apparent = false
				//updateDatas()
			}
			else
			{
				this.label.text = "True"
				actualState = "truew";
				apparent = true
				//updateDatas()
			}
			trace(actualState)
		
		}
		
		private function updateState(e:UpdateStateEvent)
		{
		//	setState(e.stateType);
		}
		
		private function updateDatas(e:UpdateSailingDatasEvent):void
		{
			var datas:SailData = e.data;
			
			if ((datas.mwv.windDirectionRef) == "R" && apparent)
			{
				forgatHandler.forgat(datas.mwv.windDirection)
				digi_a.text = split._a(datas.mwv.windSpeedKnots);
				digi_b.text = split._b(datas.mwv.windSpeedKnots);
			}
			
			else if ((datas.mwv.windDirectionRef) == "T" && !apparent)
			{
				forgatHandler.forgat(datas.mwv.windDirection)
				digi_a.text = split._a(datas.mwv.windSpeedKnots);
				digi_b.text = split._b(datas.mwv.windSpeedKnots);
			}
				
			else
			{
				
			}
			
		}
	}
}