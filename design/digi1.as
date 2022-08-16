package 
{
	import mx.flash.UIMovieClip;
	import com.events.UpdateSailingDatasEvent;
	import fl.transitions.Tween;
	import fl.transitions.easing.None;
	import flash.events.MouseEvent;
	
	[Event(name = "updateSailing",type = "com.events.UpdateSailingDatasEvent")]

	public class digi1 extends UIMovieClip
	{
		public var updateVars:Array = [
		"depth.meters",
		"temperature.water",
		"wind.relative.direction",
		"wind.direction",
		"heading.magnetic",
		"wind.speed.knots"
		];
		//var forgoTween1:Tween;
		var valasztas = Number
		
		public function digi1()
		{
			super();
			this.addEventListener(UpdateSailingDatasEvent.UPDATE_SAILING, updateDatas);
			
			up.visible = false
			down.visible = false
			
			//this.forgoTween1 = new Tween (mutato,"rotation",None.easeNone,0,0,1,true);
			btnon.btns.visible = false
			btnon.addEventListener(MouseEvent.ROLL_OVER, gombokon);
			btnon.addEventListener(MouseEvent.ROLL_OUT, gombokoff);
			
			function gombokon(event:MouseEvent):void
			{	
				btnon.btns.visible = true
				felirat.visible = false
			}
			function gombokoff(event:MouseEvent):void
			{	
				btnon.btns.visible = false
				felirat.visible = true
			}
			
			btnon.btns.btn1.addEventListener(MouseEvent.CLICK, gomb1);	
			btnon.btns.btn2.addEventListener(MouseEvent.CLICK, gomb2);	
			btnon.btns.btn3.addEventListener(MouseEvent.CLICK, gomb3);	
			btnon.btns.btn4.addEventListener(MouseEvent.CLICK, gomb4);	
			btnon.btns.btn5.addEventListener(MouseEvent.CLICK, gomb5);	
			btnon.btns.btn6.addEventListener(MouseEvent.CLICK, gomb6);	
			
			
			
			function gomb1(event:MouseEvent):void
			{	
				valasztas = 1
			}
			
			function gomb2(event:MouseEvent):void
			{	
				valasztas = 2
			}
			
			function gomb3(event:MouseEvent):void
			{	
				valasztas = 3
			}
			
			function gomb4(event:MouseEvent):void
			{	
				valasztas = 4
			}
			
			function gomb5(event:MouseEvent):void
			{	
				valasztas = 5
			}
			
			function gomb6(event:MouseEvent):void
			{	
				valasztas = 6
			}
		}

		private function updateDatas(e:UpdateSailingDatasEvent):void
		{
			var datas = e.data;
	//		this.forgoTween1.continueTo(datas.wind_direction + datas.heading_magnetic, 1);
			//mutato.szam.text = datas.wind_speed_knots
			//szam.digi_a.text = datas.wind_speed_knots;
			
			
			var aktualis = Number
		//	aktualis = datas.wind_direction
			
			
			switch(valasztas){
				case 1: 
					aktualis = datas.depth_below_transducer_meters
					felirat.text="Depth"
					break;
				
				case 2: 
					aktualis = datas.water_temperature
					felirat.text="Water Temperature"					
					break;
				
				case 3: 
					aktualis = datas.relative_wind_direction
					felirat.text = "Wind Direction VWR"
					break;
				
				case 4: 
					aktualis = datas.wind_direction
					felirat.text = "Wind Direction MWV"
					break;
				
				case 5: 
					aktualis = datas.heading_magnetic
					felirat.text = "Heading Magnetic"
					break;	
					
				case 6: 
					aktualis = datas.wind_speed_knots
					felirat.text = "Wind Speed"
					break;
			}
			
			
			var kijelez = Math.round(aktualis*10)/10;
			var _a = Math.floor(kijelez);
			var _b = Math.round((kijelez-_a)*10);
	
			szam.digi_a.text = String(_a);
			szam.digi_b.text = String(_b);
			
		}
	}
	
}


