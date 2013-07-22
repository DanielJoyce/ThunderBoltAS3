package org.osflash.thunderbolt
{
	/**
	* Logging levels, value constants borrowed from mx.logging.LogEventLevel
	*/
	public class LogLevel
	{
		public static const ALL:LogLevel = 		LogLevel(0);
		public static const DEBUG:LogLevel = 	LogLevel(2);
		public static const INFO:LogLevel = 	LogLevel(4);
		public static const WARN:LogLevel = 	LogLevel(6);
		public static const ERROR:LogLevel = 	LogLevel(8);
		public static const FATAL:LogLevel = 	LogLevel(1000);
		public static const OFF:LogLevel = 		LogLevel(int.MAX_VALUE);

		private var _level = -1;

		public function LogLevel(level: int)
		{
			super();
			_level = level;
		}

		public function get level():int
		{
			return _level;
		}
	}
}