package org.osflash.thunderbolt
{
	/**
	* Interface for LogEntry formatters
	*/
	public interface ILogEntryFormatter{
		function format(entry:LogEntry):Object
	}
}