/**
* Logging Flex and Flash projects using Firebug and ThunderBolt AS3
* 
* @version	2.2
* @date		03/06/09
*
* @author	Jens Krause [www.websector.de]
*
* @see		http://www.websector.de/blog/category/thunderbolt/
* @see		http://code.google.com/p/flash-thunderbolt/
* @source	http://flash-thunderbolt.googlecode.com/svn/trunk/as3/
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

		private static const GROUP_START: String = "group";
		private static const GROUP_END: String = "groupEnd";
		private static const MAX_DEPTH: int = 255;
		private static const VERSION: String = CONFIG::version;
		private static const AUTHOR: String = "Jens Krause [www.websector.de]"

		// private vars	
		private static var _stopLog: Boolean = false;
		private static var _depth: int;	

		private static var _targets: Object = new Object;
		
		// public vars
		public static var includeTime: Boolean = true;
		public static var showCaller: Boolean = true;
		private static var logLevel: LogLevel = LogLevel.WARN;

			
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
			removeLoggerTarget(name)
			_targets[name] = target
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
				var target:ILoggerTarget = _targets[name] as ILoggerTarget
				target.close()
				delete _targets[name]
			}
		}

		/**
		* Remove all logger targets
		*/
		public static function clearAllLoggerTargets():void
		{
			for(var name:String in _targets)
			{
				removeLoggerTarget(name)
			}
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
			Logger.log( LogLevel.DEBUG, msg, logObjects );			
		}		
			
		/**
		* Calls Firebugs command line API to write log information
		* 
		* @param 	level		String			log level 
		* @param 	msg			String			log message 
		* @param 	logObjects	Array			Array of log objects
		*/			 
		public static function log (logLevel: LogLevel, msg: String = "", logObjects: Array = null): void
		{
			if(logLevel.level >= Logger.logLevel.level){
				var caller: String = "";
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
				
				// send message	to the logging system
				//Logger.call( logMsg );
					
				// log objects	
				if (logObjects != null)
				{
					var i: int = 0, l: int = logObjects.length;	 	
					for (i = 0; i < l; i++) 
					{
						Logger.logObject(logObjects[i]);
					}
				}
				for each(var target:ILoggerTarget in _targets){
					target.log(logLevel, new Date(),LoggerUtil.getCaller(), msg, logObjects)
				}
			}
		}



		/**
		* Logs nested instances and properties
		* 
		* @param 	logObj		Object		log object
		* @param 	id			String		short description of log object
		*/	
		private static function logObject (logObj:*, id:String = null): void
		{				
			if ( _depth < Logger.MAX_DEPTH )
			{
				++ _depth;
				
				var propID: String = id || "";
				var description:XML = describeType(logObj);				
				var type: String = description.@name;
				
				if (LoggerUtil.primitiveType(type))
				{					
					var msg: String = (propID.length) 	? 	"[" + type + "] " + propID + " = " + logObj
														: 	"[" + type + "] " + logObj;
															
					Logger.call( msg );
				}
				else if (type == "Object")
				{
					Logger.callGroupAction( GROUP_START, "[Object] " + propID);
					
					for (var element: String in logObj)
					{
						logObject(logObj[element], element);	
					}
					Logger.callGroupAction( GROUP_END );
				}
				else if (type == "Array")
				{
					Logger.callGroupAction( GROUP_START, "[Array] " + propID );
					
					var i: int = 0, max: int = logObj.length;					  					  	
					for (i; i < max; i++)
					{
						logObject(logObj[i]);
					}
					
					Logger.callGroupAction( GROUP_END );
											
				}
				else
				{
					// log private props as well - thx to Rob Herman [http://www.toolsbydesign.com]
					var list: XMLList = description..accessor;					
					
					if (list.length())
					{
						for each(var item: XML in list)
						{
							var propItem: String = item.@name;
							var typeItem: String = item.@type;							
							var access: String = item.@access;
							
							// log objects && properties accessing "readwrite" and "readonly" only 
							if (access && access != "writeonly") 
							{
								//TODO: filter classes
								// var classReference: Class = getDefinitionByName(typeItem) as Class;
								var valueItem: * = logObj[propItem];
								Logger.logObject(valueItem, propItem);
							}
						}					
					}
					else
					{
						Logger.logObject(logObj, type);					
					}
				}
			}
			else
			{
				// call one stop message only
				if (!_stopLog)
				{
					Logger.call( "STOP LOGGING: More than " + _depth + " nested objects or properties." );
					_stopLog = true;
				}			
			}									
		}
		
		/**
		* Call wheter to Firebug console or 
		* use the standard trace method logging by flashlog.txt
		* 
		* @param 	msg			 String			log message
		* 
		*/							
		private static function call (msg: String = ""): void
		{
//			if ( _firebug )
//				ExternalInterface.call("console." + _logLevel, msg);			
//			else
//				trace ( _logLevel + " " + msg);	

		}
		
		
		
		/**
		* Calls an action to open or close a group of log properties
		* 
		* @param 	groupAction		String			Defines the action to open or close a group 
		* @param 	msg			 	String			log message
		* 
		*/
		private static function callGroupAction (groupAction: String, msg: String = ""): void
		{
// 			if ( _firebug )
// 			{
// 				if (groupAction == GROUP_START) 
// 					ExternalInterface.call("console.group", msg);		
// 				else if (groupAction == GROUP_END)
// 					ExternalInterface.call("console.groupEnd");			
// 				else
// 					ExternalInterface.call("console." + LogLevel.ERROR, "group type has not defined");	
// 			}
// 			else
// 			{
// 				if (groupAction == GROUP_START) 
// 					trace( _logLevel + "." + GROUP_START + " " + msg);			
// 				else if (groupAction == GROUP_END)
// 					trace( _logLevel + "." + GROUP_END + " " + msg);			
// 				else
// 					trace ( ERROR + "group type has not defined");					
// 			}
		}
	}

}

