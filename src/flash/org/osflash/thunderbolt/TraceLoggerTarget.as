package org.osflash.thunderbolt
{
	/**
	* Logger making use of Trace() facility that logs to flashlog.txt
	*
	* Tracing support must be enabled in your mm.cfg for this to work.
	*
	* @author Daniel Joyce [https://github.com/DanielJoyce]
	*/
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