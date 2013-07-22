package org.osflash.thunderbolt
{
	/**
	* provides basic plumbing. 
	* Properly handles trying to log when instance has had close() called
	* Subclasses should override doLog and doClose methods
	*/
	public class BaseLogger implements ILoggerTarget
	{
		private var _isClosed = false

		public final function log(level: LogLevel, date:Date, caller:String, msg: String = "", logObjects: Array = null): void {
			if(_isClosed){
				throw new LoggerClosedError("Logger has been closed!");
			}
			doLog(level, date, caller, msg, logObjects);
		}

		/**
		* Log the given message and objects using the given log level
		* If this logger has had its close() method called, should throw LoggerClosedError
		* Should not be called directly outside of framework
		* @param level The level to log at
		* @param msg The msg to log
		* @param logObjects Additional objects to log
		* @throws LoggerClosedError if this logger has been closed
		*/
		protected function doLog(level: LogLevel, date:Date, caller:String, msg: String = "", logObjects: Array = null): void 
		{
			throw new Error("doLog has not been implemented!");
		}
	
		public final function close():void{
			_isClosed = true;
			doClose();
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