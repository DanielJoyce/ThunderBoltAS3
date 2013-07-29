/**
* Logging Flex and Flash projects using Firebug and ThunderBolt AS3
*
* Please note that logging of call sites via stack trace walking only works
* if overall project is built in debug mode and run in a debug player.
* 
* @version	2.4-NG
* @date		03/06/09
*
* @author	Jens Krause [www.websector.de]
* @author 	Daniel Joyce [https://github.com/DanielJoyce]
*
* @see		http://www.websector.de/blog/category/thunderbolt/
* @source	https://github.com/DanielJoyce/ThunderBoltAS3
* 
* ***********************
* HAPPY LOGGING ;-)
* ***********************
* 
*/

package org.osflash.thunderbolt
{
	import flash.external.ExternalInterface;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.utils.describeType;

	/**
	* Thunderbolts AS3 Logger class
	* 
	*/
	public class Logger
	{
		// constants
		// Firebug supports 4 log levels only

		private static const VERSION: String = CONFIG::version;
		private static const AUTHOR: String = "Jens Krause [www.websector.de]"

		// Active Logger Targets
		private static var _targets: Object = new Object;
		
		// Open Timing Points
		private static var _timings: Object = new Object;

		// public vars
		public static var includeTime: Boolean = true;
		public static var showCaller: Boolean = true;
		public static var logLevel: LogLevel = LogLevel.WARN;

			
		/**
		* Information about the current version of ThunderBoltAS3
		*
		*/		 
		public static function about():void
		{
			var message: String = 	"+++ Welcome to ThunderBolt AS3 | VERSION: " 
									+ VERSION 
									+ " | AUTHOR: " 
									+ Logger.AUTHOR 
									+ " | Happy logging +++";
			Logger.info (message);
		}
	
		/**
		* Calculates the amount of memory in MB and Kb currently in use by Flash Player
		* @return 	String		Message about the current value of memory in use
		*
		* Tip: For detecting memory leaks in Flash or Flex check out WSMonitor, too.
		* @see: http://www.websector.de/blog/2007/10/01/detecting-memory-leaks-in-flash-or-flex-applications-using-wsmonitor/ 
		*
		*/		 
		public static function memorySnapshot():String
		{
			var currentMemValue: uint = System.totalMemory;
			var message: String = 	"Memory Snapshot: " 
									+ Math.round(currentMemValue / 1024 / 1024 * 100) / 100 
									+ " MB (" 
									+ Math.round(currentMemValue / 1024) 
									+ " kb)";
			return message;
		}
				

		/**
		* Add a logger target
		*/
		public static function addLoggerTarget(name: String, target: ILoggerTarget):void
		{
			// Remove existing target if exists
			removeLoggerTarget(name);
			_targets[name] = target;
		}

		/**
		* Remove a logger target
		* Silently fails if no logger target instance was previously
		* registered with the given name
		*/
		public static function removeLoggerTarget(name: String):void
		{
			if(_targets.hasOwnProperty(name))
			{
				var target:ILoggerTarget = _targets[name] as ILoggerTarget;
				target.close();
				delete _targets[name];
			}
		}

		/**
		* Remove all logger targets
		*/
		public static function clearAllLoggerTargets():void
		{
			for(var name:String in _targets)
			{
				removeLoggerTarget(name);
			}
		}

		/**
		* Add a timing target
		*
		*/
		private static function addTimingTarget(name: String, timing: Date):void
		{
			// Remove existing target if exists
			removeTimingTarget(name);
			_timings[name] = timing;
		}

		/**
		* Remove a timing target and return the stored date 
		* of when the timing started
		* If no timing with the given date exists, returns null
		*/
		private static function removeTimingTarget(name: String):Date
		{
			var timing:Date = null
			if(_timings.hasOwnProperty(name))
			{
				timing = _timings[name] as Date;
				delete _targets[name];
			}
			return timing;
		}

		/**
		* Registers the logger instances defined in LoggerTargets
		*
		* The firebug logger is only registered if FirebugLoggerTargetisFireBugAvailable() returns true
		*/
		public static function registerDefaultLoggers():void
		{
			var dlts:DefaultLoggerTargets = new DefaultLoggerTargets();
			if(FirebugLoggerTarget.isFireBugAvailable()){
				addLoggerTarget("default_firebug_target",dlts.FIREBUG_LOGGER_TARGET);
			}
			addLoggerTarget("default_trace_target",dlts.TRACE_LOGGER_TARGET);
		}

		/**
		* Logs info messages including objects for calling Firebug
		* 
		* @param 	msg				String		log message 
		* @param 	logObjects		Array		Array of log objects using rest parameter
		* 
		*/		
		public static function info (msg: String = null, ...logObjects): void
		{
			if(logObjects.length == 0)
				logObjects = null
			Logger.log( LogLevel.INFO, msg, logObjects );			
		}
		
		/**
		* Logs warn messages including objects for calling Firebug
		* 
		* @param 	msg				String		log message 
		* @param 	logObjects		Array		Array of log objects using rest parameter
		* 
		*/		
		public static function warn (msg: String = null, ...logObjects): void
		{
			if(logObjects.length == 0)
				logObjects = null
			Logger.log( LogLevel.WARN, msg, logObjects );			
		}

		/**
		* Logs error messages including objects for calling Firebug
		* 
		* @param 	msg				String		log message 
		* @param 	logObjects		Array		Array of log objects using rest parameter
		* 
		*/		
		public static function error (msg: String = null, ...logObjects): void
		{
			if(logObjects.length == 0)
				logObjects = null
			Logger.log( LogLevel.ERROR, msg, logObjects );			
		}
		
		/**
		* Logs debug messages messages including objects for calling Firebug
		* 
		* @param 	msg				String		log message 
		* @param 	logObjects		Array		Array of log objects using rest parameter
		* 
		*/		
		public static function debug (msg: String = null, ...logObjects): void
		{
			if(logObjects.length == 0)
				logObjects = null
			Logger.log( LogLevel.DEBUG, msg, logObjects );			
		}		
			
		/**
		* If logLevel is greater than current logger logLevel, then calls
		* every registered ILoggerTarget 
		* 
		* @param 	level		String			log level 
		* @param 	msg			String			log message 
		* @param 	logObjects	Array			Array of log objects
		*/			 
		public static function log (logLevel: LogLevel, msg: String = "", logObjects: Array = null): void
		{
			if(logLevel.level >= Logger.logLevel.level){
				var caller: String = null;
				var date: Date = null;
				// add time	to log message
				if (includeTime) 
					date = new Date();
		
				// get package and class name + line number
				// using getStackTrace(); 
				// @see: http://livedocs.adobe.com/flex/3/langref/Error.html#getStackTrace()
				// Note: For using it the Flash Debug Player has to be installed on your machine!
				if ( showCaller ) 
					caller = LoggerUtil.getCaller();
	
				var logEntry = new LogEntry(logLevel, date, caller, msg, logObjects)

				// Call each registered logging target
				for each(var target:ILoggerTarget in _targets){
					target.log(logEntry)
				}
			}
		}

		/**
		* Start a timing with the given name
		* Marks the timing start point in the logs at the given log level
		* The default log level is DEBUG
		*/
		public static function startTiming(name:String, level:LogLevel = null):void
		{
			if(level == null)
				level = LogLevel.DEBUG
			var date:Date = new Date();
			addTimingTarget(name,date);
			log(level, "Starting timing '"+name+"'");
		}

		/**
		* Stop the timing with the given name and
		* log the result at the given log level
		* The default log level is DEBUG
		*/ 
		public static function stopTiming(name:String, level:LogLevel = null):void
		{
			if(level == null)
				level = LogLevel.DEBUG

			var startDate = removeTimingTarget(name);
			if(startDate != null)
			{
				var stopDate:Date = new Date();
				var elapsedTime: int = stopDate.time -startDate.time
				var hours = elapsedTime % ( 60 * 60 * 1000 );
				elapsedTime = elapsedTime - ( hours * 60 * 60 * 1000 );
				var minutes = elapsedTime % ( 60 * 1000 );
				elapsedTime = elapsedTime - ( minutes * 60 * 1000 );
				var seconds = elapsedTime % 1000;
				var milliseconds = elapsedTime - ( seconds * 1000 );

				var time:String = LoggerUtil.fmtTimeValue(hours) + ":" +
								  LoggerUtil.fmtTimeValue(minutes) + ":" +
								  LoggerUtil.fmtTimeValue(seconds) + "." +
								  LoggerUtil.fmtTimeValue(milliseconds);
				var msg = "Finished timing '"+name+"', took "+time;
				log(level, msg);
			}
			else
			{
				log(LogLevel.WARN, "No matching timing start point found for '"+name+"'")
			}
		}
		
		//-----------------------------------------------------------------------------------------------
		// Methods to quickly set logging levels, intended for use via ExternalInterface
		//-----------------------------------------------------------------------------------------------

		/**
		* Register external intefaces for the purposes of controlling
		* the current log level via JavaScript
		*
		* Silently fails if ExternalInterface is not available
		* 
		* This call registers the following external interfaces:
		* 	setLogLevelAll
		* 	setLogLevelDebug
		* 	setLogLevelInfo
		* 	setLogLevelWarn
		* 	setLogLevelError
		* 	setLogLevelFatal
		* 	setLogLevelOff
		*/
		public static function registerExternalInterfaces():void
		{
			if(ExternalInterface.available)
			{
				ExternalInterface.addCallback("setLogLevelAll",setLogLevelAll)
				ExternalInterface.addCallback("setLogLevelDebug",setLogLevelDebug)
				ExternalInterface.addCallback("setLogLevelInfo",setLogLevelInfo)
				ExternalInterface.addCallback("setLogLevelWarn",setLogLevelWarn)
				ExternalInterface.addCallback("setLogLevelError",setLogLevelError)
				ExternalInterface.addCallback("setLogLevelFatal",setLogLevelFatal)
				ExternalInterface.addCallback("setLogLevelOff",setLogLevelOff)
			}
		}

		/**
		* Set the current logging level to ALL
		*/
		public static function setLogLevelAll():void
		{
			logLevel = LogLevel.ALL
		}

		/**
		* Set the current logging level to DEBUG
		*/
		public static function setLogLevelDebug():void
		{
			logLevel = LogLevel.DEBUG
		}

		/**
		* Set the current logging level to INFO
		*/
		public static function setLogLevelInfo():void
		{
			logLevel = LogLevel.INFO
		}
	
		/**
		* Set the current logging level to WARN
		*/
		public static function setLogLevelWarn():void
		{
			logLevel = LogLevel.WARN
		}

		/**
		* Set the current logging level to ERROR
		*/
		public static function setLogLevelError():void
		{
			logLevel = LogLevel.ERROR
		}

		/**
		* Set the current logging level to FATAL
		*/
		public static function setLogLevelFatal():void
		{
			logLevel = LogLevel.FATAL
		}

		/**
		* Set the current logging level to OFF
		*/
		public static function setLogLevelOff():void
		{
			logLevel = LogLevel.OFF
		}
	}

}

