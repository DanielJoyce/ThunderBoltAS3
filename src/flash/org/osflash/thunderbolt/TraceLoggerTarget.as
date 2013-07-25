package org.osflash.thunderbolt
{
	class TraceLoggerTarget extends BaseLoggerTarget{

		private var _level:LogLevel = LogLevel.OFF;

		protected override function doLog(logEntry: LogEntry): void 
		{
			trace(_logEntryFormatter.format(logEntry));
		}

		protected override function doClose():void
		{
			// nop
		}
	}
}