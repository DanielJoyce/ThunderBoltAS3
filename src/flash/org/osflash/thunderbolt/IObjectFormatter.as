package org.osflash.thunderbolt
{
	/**
	* Interface for Object Formatters, used to convert
	* actionscript objects into something usable by
	* by ILoggerTarget implementations.
	*
	* @author Daniel Joyce [https://github.com/DanielJoyce]
	*/
	public interface IObjectFormatter{
		function format(object: Object):Object
	}
}