package org.osflash.thunderbolt
{
	/**
	* Logging levels, value constants borrowed from mx.logging.LogEventLevel
	*
	* @author Daniel Joyce [https://github.com/DanielJoyce]
	*/
	public class LogLevel
	{
		// Log everything
		public static const ALL:LogLevel =		new LogLevel(0,"ALL");
		public static const DEBUG:LogLevel = 	new LogLevel(2,"DEBUG");
		public static const INFO:LogLevel = 	new LogLevel(4,"INFO");
		public static const WARN:LogLevel = 	new LogLevel(6,"WARN");
		public static const ERROR:LogLevel = 	new LogLevel(8,"ERROR");
		public static const FATAL:LogLevel = 	new LogLevel(1000,"FATAL");
		// Log nothing
		public static const OFF:LogLevel = 		new LogLevel(int.MAX_VALUE,"OFF");

		private var _level = -1;
		private var _label = ""; 

		public function LogLevel(level: int, label:String)
		{
			super();
			_level = level;
			_label = label;
		}

		public function get level():int
		{
			return _level;
		}

		public function get label():String
		{
			return _label;
		}

		public function toString():String
		{
			return _label;
		}
	}
}