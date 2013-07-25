package org.osflash.thunderbolt
{
	public class SimpleLogEntryFormatter implements ILogEntryFormatter
	{

		private var _objFormatter:IObjectFormatter = new SimpleObjectFormatter();

		/**
		* Formats a log entry, returning a string
		* The format is:
		*
		* LogLevel.label [:: date formatted as hh:mm:ss.sss] [::caller] [:: msg]
		* Where items in [] do not appear if their value in the logentry is null
		*
		* Objects are formatted with SimpleObjectFormatter and put on a 
		* new line after the entry
		*/
		public function format(entry:LogEntry):Object
		{
			var result:String = "" + entry.level.label;
			if(entry.date != null)
				result += LoggerUtil.FIELD_SEPERATOR + LoggerUtil.getTime(entry.date)
			if(entry.caller != null)
				result += LoggerUtil.FIELD_SEPERATOR + entry.caller
			if(entry.message != null)
				result += LoggerUtil.FIELD_SEPERATOR + entry.message
			if(entry.objects != null )
			{
				result += "\n"
				result += _objFormatter.format(entry.objects)
			}
			return result
		}
	}
}