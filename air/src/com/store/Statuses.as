package com.store
{
import flash.system.Capabilities;

[Bindable]
	public class Statuses
	{
		private static var _instance:Statuses = new Statuses()
		private var _socketStatus:Boolean = false;
		private var _inverseSocketStatus:Boolean = true;
		public function Statuses()
		{
			if (_instance != null)
			{
				//throw new Error("Singleton can only be accessed through Singleton.instance");
			}else{
				_instance = this;
			}
		}

		public function get socketStatus():Boolean
		{
			return _socketStatus;
		}

		public function get inverseSocketStatus():Boolean
		{
			return _inverseSocketStatus;
		}

		public function set inverseSocketStatus(value:Boolean):void
		{
			_inverseSocketStatus = value;
		}

		public function set socketStatus(value:Boolean):void
		{
			_socketStatus = value;
			_instance.inverseSocketStatus = !value;
		}

		public static function get instance():Statuses
		{
			if (_instance == null)  _instance = new Statuses(); 
			return _instance;
		}
		
		public static function isWindows():Boolean{
			if((Capabilities.os.indexOf("Windows") >= 0))
			{
				return true;
			}
			return false;
		}
        public function isWindows():Boolean{
            return Statuses.isWindows();
        }
		
		public function isMac():Boolean{
			if((Capabilities.os.indexOf("Mac") >= 0))
			{
				return true;
			}
			return false;
		}

	
	}
}