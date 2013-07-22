package org.osflash.thunderbolt
{
	import flash.external.ExternalInterface;
	import flash.system.Capabilities;
	import flash.system.System;


	class FirebugLoggerTarget extends BaseTextualLoggerTarget{
		private static const DEBUG: String = "debug";
		private static const INFO: String = "info";
		private static const WARN: String = "warn";
		private static const ERROR: String = "error";
		private static const LOG: String = "log";
		private static const FIREBUG_METHODS: Array = [DEBUG, INFO, WARN, ERROR, LOG];

		private var _level:LogLevel = LogLevel.OFF;

		protected override function doLog(level: LogLevel, date:Date, caller:String, msg: String = "", logObjects: Array = null): void
		{
			_level = level;
			super.doLog(level, date, caller, msg, logObjects);
		}

		protected override function doClose():void
		{
			// nop
		}

		/**
		* Is firebug or similar functionality availble?
		*
		* Are we running in a browser, and does it have appropriate logging methods?
		*/
		public static function isFireBugAvailable():Boolean
		{
			var isBrowser: Boolean = ( Capabilities.playerType == "ActiveX" || Capabilities.playerType == "PlugIn" );

			if ( isBrowser && ExternalInterface.available )
			{
				// check if firebug installed and enabled
				var requiredMethodsCheck:String = "";
				for each (var method:String in FIREBUG_METHODS) {
					// Most browsers report typeof function as 'function'
					// Internet Explorer reports typeof function as 'object'
					requiredMethodsCheck += " && (typeof console." + method + " == 'function' || typeof console." + method + " == 'object') "
				}
				try
				{
					if ( ExternalInterface.call( "function(){ return typeof window.console == 'object' " + requiredMethodsCheck + "}" ) )
						return true;
				}
				catch (error:SecurityError)
				{
						return false;
				}
			}

			return false;
		}

		private function logLevelToFirebugLevel(level:LogLevel):String
		{
			var fbLevel = FirebugLoggerTarget.INFO
			if(level.level < LogLevel.DEBUG.level){
				fbLevel = FirebugLoggerTarget.DEBUG
			}else if(level.level < LogLevel.INFO.level){
				fbLevel = FirebugLoggerTarget.DEBUG
			}else if(level.level < LogLevel.WARN.level){
				fbLevel = FirebugLoggerTarget.INFO
			}else if(level.level < LogLevel.OFF.level){
				fbLevel = FirebugLoggerTarget.ERROR
			}
			return fbLevel;
		}

		protected override function write (msg: String = ""): void
		{
				ExternalInterface.call("console." + logLevelToFirebugLevel(_level), msg);			
		}

		protected override function writeGroup (groupAction: String, msg: String = ""): void 
		{
				if (groupAction == BaseTextualLoggerTarget.GROUP_START) 
					ExternalInterface.call("console.group", msg);		
				else if (groupAction == BaseTextualLoggerTarget.GROUP_END)
					ExternalInterface.call("console.groupEnd");			
				else
					ExternalInterface.call("console." + LogLevel.ERROR, "group type has not defined");
		}
	}
}