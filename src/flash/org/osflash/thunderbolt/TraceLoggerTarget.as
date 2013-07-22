package org.osflash.thunderbolt
{
	class TraceLoggerTarget extends BaseTextualLoggerTarget{

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

		protected override function write (msg: String = ""): void
		{
			trace( _logLevel.label + " " + msg);	
		}

		protected override function writeGroup (groupAction: String, msg: String = ""): void 
		{
			if (groupAction == BaseTextualLoggerTarget.GROUP_START) 
				trace( _logLevel.label + "." + GROUP_START + " " + msg);			
			else if (groupAction == BaseTextualLoggerTarget.GROUP_END)
				trace( _logLevel.label + "." + GROUP_END + " " + msg);			
			else
				trace( ERROR + "group type has not defined");		
		}

	}
}