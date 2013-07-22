package org.osflash.thunderbolt
{

	public interface ILoggerTarget
	{
		/**
		* Log the given message and objects using the given log level
		* If this logger has had its close() method called, should throw LoggerClosedError
		* @param level The level to log at
		* @param prefix A textual prefix provided by the Logger
		* @param msg The msg to log
		* @param logObjects Additional objects to log
		* @throws LoggerClosedError if this logger has been closed
		*/
		function log(level: LogLevel, date: Date, caller: String, msg: String = "", logObjects: Array = null): void 

		/**
		* This method is called by the Logger when the target is removed.
		*
		* This method should clean up any resources in use
		*/
		function close():void
	}

}