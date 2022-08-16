package com.timeline
{
	public class Segment
	{
		private var _name:String;
		private var _minTime:Number;
		private var _maxTime:Number;
		private var _index:Number;
		private var _inited:Boolean;
		
		
		public function Segment(index:Number, filename:String)
		{
			this.index = index;
			this.name = filename;
		}
		
		public static function getSegmentNameFromLogNameAndIndex(logName:String, index:Number):String{
			return logName +"." + index + ".edodb"
		}
		

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public function get minTime():Number
		{
			return _minTime;
		}

		public function set minTime(value:Number):void
		{
			_minTime = value;
		}

		public function get maxTime():Number
		{
			return _maxTime;
		}

		public function set maxTime(value:Number):void
		{
			_maxTime = value;
		}

		public function get index():Number
		{
			return _index;
		}

		public function set index(value:Number):void
		{
			_index = value;
		}

		public function get inited():Boolean
		{
			return _inited;
		}

		public function set inited(value:Boolean):void
		{
			_inited = value;
		}


	}
}