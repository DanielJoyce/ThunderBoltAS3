package org.osflash.thunderbolt
{
	import flash.system.Capabilities;


	public class LoggerUtil {

		public static const FIELD_SEPERATOR: String = " :: ";

		/**
		* Formats a valid time value
		* @param timeValue Number representing Hour, minute or second
		* @return String A valid hour, minute or second padded with leading 0
		*/ 
		public static function fmtTimeValue(timeValue: Number):String
		{
			return timeValue > 9 ? timeValue.toString() : "0" + timeValue.toString();
		}
		
		
		/** 
		* Get details of a caller of the log message
		* which based on Jonathan Branams MethodDescription.createFromStackTrace();
		* 
		* @see: http://github.com/jonathanbranam/360flex08_presocode/
		* 
		*/
		public static function stackDataFromStackTrace(stackTrace: String): StackData
		{
			// Check stackTrace
			// Note: It seems that there some issues to match it using Flash IDE, so we use an empty Array instead
			var matches:Array = stackTrace.match(/^\tat (?:(.+)::)?(.+)\/(.+)\(\)\[(?:(.+)\:(\d+))?\]$/)
								|| new Array();

			var stackData: StackData = new StackData();		
			stackData.packageName = matches[1] || "";
			stackData.className = matches[2] || "";
			stackData.methodName = matches[3] || "";
			stackData.fileName = matches[4] || "";
			stackData.lineNumber = int( matches[5] ) || 0;

			return stackData;
		}

		/** 
		* Message about details of a caller who logs anything
		* 
		* WARNING: Generating and walking stacktraces
		* can be slow...
		*
		* @return String	message of details
		*/
		public static function getCaller(): String
		{
			var debugError: Error;
			var message: String = '';
			
			if ( Capabilities.isDebugger) {
				var stackTrace:String = (new Error()).getStackTrace();
				// track all stacks only if we have a stackTrace
				if ( stackTrace != null )
				{
					var stacks:Array = stackTrace.split("\n");

					if ( stacks != null )
					{
						var stackData: StackData;
						
						// stacks data for using Logger 
						
	/* 		    			trace ("stacks.length " + stacks.length); */

						if ( stacks.length >= 5 )
								stackData = LoggerUtil.stackDataFromStackTrace( stacks[ 4 ] );
						
						// special stack data for using ThunderBoldTarget which is a subclass of mx.logging.AbstractTarget
						if ( stackData.className == "AbstractTarget" &&  stacks.length >= 9 )
							stackData = LoggerUtil.stackDataFromStackTrace( stacks[ 8 ] );

						// show details of stackData only if it available
						if ( stackData != null )
						{
	/* 							trace ("stackData " + stackData.toString() );  */
										
							message += ( stackData.packageName != "") 
										? stackData.packageName + "."
										: stackData.packageName;
																			
							message += stackData.className;
							
							if ( stackData.lineNumber > 0  )
								message += " [" + stackData.lineNumber + "]" + FIELD_SEPERATOR;
						}							    		
					}  		    			
				}               
			}       
			return message;	
		}

		/**
		* Checking for primitive types
		* 
		* @param 	type				String			type of object
		* @return 	isPrimitiveType 	Boolean			isPrimitiveType
		* 
		*/							
		public static function primitiveType(type: String): Boolean
		{
			var isPrimitiveType: Boolean;
			
			switch (type) 
			{
				case "Boolean":
				case "void":
				case "int":
				case "uint":
				case "Number":
				case "String":
				case "undefined":
				case "null":
					isPrimitiveType = true;
					break;			
				default:
					isPrimitiveType = false;
			}

			return isPrimitiveType;
		}

		/**
		* Creates a String of valid time value
		* @return String current time as a String using valid hours, minutes, seconds and milliseconds
		*/
		public static function getCurrentTime():String
		{
			var currentDate: Date = new Date();
			
			var currentTime: String = 	"time "
										+ LoggerUtil.fmtTimeValue(currentDate.getHours()) 
										+ ":" 
										+ LoggerUtil.fmtTimeValue(currentDate.getMinutes()) 
										+ ":" 
										+ LoggerUtil.fmtTimeValue(currentDate.getSeconds()) 
										+ "." 
										+ LoggerUtil.fmtTimeValue(currentDate.getMilliseconds()) + FIELD_SEPERATOR;
			return currentTime;
		}
	}
}