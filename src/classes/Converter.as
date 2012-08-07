package classes
{
	[Bindable]
	public class Converter
	{
		public var sourceFile:String;
		public var percentage:Number;
		public var completed:Boolean;
		public var mediaType:String;
		
		public function Converter()
		{
		}
		
		public function get filenameWithoutExtension():String
		{
			var s:String = sourceFile.substr(sourceFile.lastIndexOf("\\")+1);
			return s.substr(0, s.lastIndexOf("."));
		}
	}
}