package org.osflash.thunderbolt
{
	/**
	* Interface for LogEntry formatters
	*
	* Some formatters may only be compatible with some Logger Targets
	* as the return of the format() method will vary depending on impl.
	*
	* As Actionscript lacks generics, a description of the actual output should
	* be noteed.
	*
	* @author Daniel Joyce [https://github.com/DanielJoyce]
	*/
	public interface ILogEntryFormatter{

		/**
		* Format the given log entry and produce some sort of output
		* 
		*/
		function format(entry:LogEntry):Object
	}
}