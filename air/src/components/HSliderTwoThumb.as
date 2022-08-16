package components
{
import flash.geom.Point;

public class HSliderTwoThumbs extends HSlider
	{
		private var _value2:Number;
		
		[Bindable]
		public function get value2():Number
		{
			return _value2;
		}
		
		public function set value2(value:Number):void
		{
			_value2=value;
			invalidateDisplayList();
		}
		
		
		[SkinPart(required="true")]
		public var thumb2:Button;
		
		public function HSliderTwoThumbs()
		{
			super();
			//this.setStyle("skinClass", "HRangeSliderSkin");
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
		}
		
		
		override protected function updateSkinDisplayList():void
		{
			super.updateSkinDisplayList();
			
			if (!thumb2 || !track || !rangeDisplay)
				return;
			
			var thumbRange:Number=track.getLayoutBoundsWidth() - thumb2.getLayoutBoundsWidth();
			var range:Number=maximum - minimum;
			
			// calculate new thumb position.
			var thumbPosTrackX:Number=(range > 0) ? ((value2 - minimum) / range) * thumbRange : 0;
			// convert to parent's coordinates.
			var thumbPos:Point=track.localToGlobal(new Point(thumbPosTrackX, 0));
			var thumbPosParentX:Number=thumb2.parent.globalToLocal(thumbPos).x; //- distanceToSecondThumb
			
			thumb2.setLayoutBoundsPosition(Math.round(thumbPosParentX), thumb2.getLayoutBoundsY());
			
		}
		
	}}
}