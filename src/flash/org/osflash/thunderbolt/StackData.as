
package org.osflash.thunderbolt 
{

	/**
	* Stackdata for storing all data throwing by an error
	* 
	* Split from Logger.as
	*
	* @author	Jens Krause [www.websector.de]
	*/
	internal class StackData
	{
		public var packageName: String;
		public var className: String;
		public var methodName: String;
		public var fileName: String;
		public var lineNumber: int;
		
		public function toString(): String
		{
			var s: String = "packageName " + packageName
							+ " // className " + className
							+ " // methodName " + methodName
							+ " // fileName " + fileName
							+ "// lineNumber " + lineNumber;
			return s;

		}
	}
}