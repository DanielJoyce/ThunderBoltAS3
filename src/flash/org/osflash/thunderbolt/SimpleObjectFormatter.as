package org.osflash.thunderbolt
{
	import flash.utils.*;

	public class SimpleObjectFormatter implements IObjectFormatter{

		private var _maxDepth = -1;
		private var _maxProps = -1;

		public function SimpleObjectFormatter(maxDepth = 6, maxProps = 255)
		{
			_maxDepth = maxDepth;
			_maxProps = maxProps
		}

		private function pad(padding:int):String
		{
			var pad:String = "";
			var i:int = 0;
			while( i < padding)
			{	
				pad += "    ";
				i++;
			}
			return pad;
		}
		
		private function formatObject(obj:Object, id:String = null, depth = 0, props = 0):String
		{
			var padding:String = pad(depth);
			var buffer: String = padding;
			if ( depth < _maxDepth &&  props < _maxProps)
			{	

				var propID: String = id == null ? "_root_" : id;

				var prefix = propID + ":" + "("+getQualifiedClassName(obj)+") = ";

				buffer += prefix

				if ( "object" != typeof obj  || obj == null)
				{
					buffer += obj + "\n";
				}

				else if (obj is Array)
				{
					buffer += "\n";
					var i: int = 0;
					var max: int = obj.length;
					if( depth + 1 < _maxDepth)
					{
						for (i; i < max; i++)
						{
							buffer += formatObject(obj[i], "["+i+"]", depth+1, ++props);
						}
					}
					else
					{
						buffer += padding + "    ...\n";
					}
				}
				else if (obj is Object)
				{
					buffer += "\n";
					
					if( depth + 1 < _maxDepth ){
						var description:XML = describeType(obj);
						//var type: String = description.@name;
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
									//var valueItem: Object = logObj[propItem];
									buffer += formatObject(obj[propItem], propItem, depth+1, ++props);
								}
							}
						}

						for (var element: String in obj)
						{
							buffer += formatObject(obj[element], element, depth+1, ++props);
						}
					}
					else
					{
						buffer += padding + "    ...\n";
					}
				}
				else
				{
					buffer += "UNKNOWN\n";
				}
// 				{
// 					// log private props as well - thx to Rob Herman [http://www.toolsbydesign.com]
// 					var list: XMLList = description..accessor;					
// 					
// 					if (list.length())
// 					{
// 						for each(var item: XML in list)
// 						{
// 							var propItem: String = item.@name;
// 							var typeItem: String = item.@type;							
// 							var access: String = item.@access;
// 							
// 							// log objects && properties accessing "readwrite" and "readonly" only 
// 							if (access && access != "writeonly") 
// 							{
// 								//TODO: filter classes
// 								// var classReference: Class = getDefinitionByName(typeItem) as Class;
// 								var valueItem: * = logObj[propItem];
// 								writeObjects(valueItem, depth+1, propItem);
// 							}
// 						}					
// 					}
// 					else
// 					{
// 						writeObjects(logObj, depth+1, type);					
// 					}
// 				}
			}
			else
			{
				buffer += "...\n";
			}									
			return buffer;
		}


		public function format(obj: Object):Object
		{
			return formatObject(obj);
		}
	}
}