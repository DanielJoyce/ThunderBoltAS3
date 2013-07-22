package org.osflash.thunderbolt
{
	class TraceLoggerTarget extends BaseLogger{

		protected override function doLog(level: LogLevel, date:Date, caller:String, msg: String = "", logObjects: Array = null): void 
		{
		}

		protected override function doClose():void
		{
			// nop
		}

	}
}