package org.osflash.thunderbolt
{
	/**
	* Error thrown by a ILoggerTarget impl which has had format() called on it
	* after its close() method has been called.
	* 
	* ALL ILoggerTarget impls should throw this error if format() is called
	* called on them after they have been closed.
	*
	* @author Daniel Joyce [https://github.com/DanielJoyce]
	*/
	public class LoggerClosedError extends Error{
		public function LoggerClosedError(msg:String)
		{
			super(msg);
		}
	}
}