package org.osflash.thunderbolt
{
	/**
	* Immutable class storing the data for a single log entry
	*/
	public class LogEntry{
		private var _level:LogLevel = null;
		private var _caller:String = null;
		private var _date:Date = null;
		private var _message:String = null;
		private var _objects:Array = null
	
		public function LogEntry(level:LogLevel, date:Date, caller:String, message:String, objects:Array = null)
		{
			this._level = level;
			this._date = date;
			this._caller = caller;
			this._message = message;
			this._objects = objects;
		}

		public function get level():LogLevel
		{
			return _level;
		}

		public function get date():Date
		{
			return _date;
		}

		public function get caller():String
		{
			return _caller;
		}

		public function get message():String
		{
			return _message;
		}

		public function get objects():Array
		{
			return _objects;
		}
	}
}