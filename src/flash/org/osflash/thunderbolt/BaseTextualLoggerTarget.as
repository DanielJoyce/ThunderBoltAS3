package org.osflash.thunderbolt
{

	import flash.utils.describeType;

	/**
	* Provides hooks making the printing of objects to textual formats a bit easier
	*/
	class BaseTextualLoggerTarget extends BaseLoggerTarget{

		private static const MAX_DEPTH:int = 255;

		protected static const GROUP_START:String = "GROUP_START";
		protected static const GROUP_END:String = "GROUP_END";


		protected override function doLog(level: LogLevel, date:Date, caller:String, msg: String = "", logObjs: Array = null): void 
		{
			var entry:String = "" + level.label;
			if(date != null)
				entry += LoggerUtil.FIELD_SEPERATOR + LoggerUtil.getTime(date)
			if(caller != null)
				entry += LoggerUtil.FIELD_SEPERATOR + caller
			if(msg != null)
				entry += LoggerUtil.FIELD_SEPERATOR + msg

			write(entry)

			if (logObjs != null && logObjs.length > 0)
				writeObjects(logObjs)
		}

		protected override function doClose():void
		{
			// nop
		}

		/**
		* Logs nested instances and properties
		* 
		* @param 	logObj		Object		log object
		* @param 	id			String		short description of log object
		*/	
		protected function writeObjects(logObj:*,  depth:int = 0, id:String = null): void
		{				
			if ( depth < BaseTextualLoggerTarget.MAX_DEPTH )
			{
				++ depth;
				
				var propID: String = id || "";
				var description:XML = describeType(logObj);				
				var type: String = description.@name;
				
				if (LoggerUtil.primitiveType(type))
				{					
					var msg: String = (propID.length) 	? 	"[" + type + "] " + propID + " = " + logObj
														: 	"[" + type + "] " + logObj;
															
					write( msg );
				}
				else if (type == "Object")
				{
					writeGroup( GROUP_START, "[Object] " + propID);
					
					for (var element: String in logObj)
					{
						writeObjects(logObj[element], depth+1, element);	
					}
					writeGroup( GROUP_END );
				}
				else if (type == "Array")
				{
					writeGroup( GROUP_START, "[Array] " + propID );
					
					var i: int = 0, max: int = logObj.length;					  					  	
					for (i; i < max; i++)
					{
						writeObjects(logObj[i], depth+1);
					}
					
					writeGroup( GROUP_END );
											
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
								writeObjects(valueItem, depth+1, propItem);
							}
						}					
					}
					else
					{
						writeObjects(logObj, depth+1, type);					
					}
				}
			}
			else
			{
				// call one stop message only
				{
					write( "STOP LOGGING: More than " + depth + " nested objects or properties." );
				}			
			}									
		}

		protected function write (msg: String = ""): void
		{
			throw new Error("write not overriden!")
		}

		protected function writeGroup (groupAction: String, msg: String = ""): void 
		{
			throw new Error("writeGroup not overriden!")
		}

	}
}