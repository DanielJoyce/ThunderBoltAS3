package org.osflash.thunderbolt
{
	/**
	* provides basic plumbing. 
	*
	* Out of the box, uses SimpleLogEntryFormatter and SimpleObjectFormatter
	* for formatting log entries and objects
	*
	* Properly handles trying to log when instance has had close() called
	* Subclasses should override doLog and doClose methods
	* 
	*Class should be considered "Abstract"
	*/
	public class BaseLoggerTarget implements ILoggerTarget
	{
		protected var _logEntryFormatter: ILogEntryFormatter = new SimpleLogEntryFormatter();

		private var _isClosed = false

		public final function log(logEntry: LogEntry): void 
		{
			if(_isClosed){
				throw new LoggerClosedError("Logger has been closed!");
			}
			doLog(logEntry);
		}

		/**
		* Log the given message and objects using the given log level
		* If this logger has had its close() method called, should throw LoggerClosedError
		* Should not be called directly outside of framework
		*
		* This method MUST be overridden by subclasses
		*
		* @param level The level to log at
		* @param msg The msg to log
		* @param logObjects Additional objects to log
		* @throws LoggerClosedError if this logger has been closed
		*/
		protected function doLog(logEntry: LogEntry): void 
		{
			throw new Error("doLog has not been implemented!");
		}
	
		public final function close():void{
			_isClosed = true;
			doClose();
		}

		/**
		* Set the log entry formatter
		*/
		public function setLogEntryFormatter(entryFormatter: ILogEntryFormatter):void
		{
			_logEntryFormatter = entryFormatter;
		}

		/**
		* This method is called by the Logger when the target is removed.
		*
		* This method should clean up any resources in use
		*
		* Should not be called directly outside of framework
		*/
		protected function doClose():void{
			throw new Error("doClose has not been implemented!");
		}

	}
}