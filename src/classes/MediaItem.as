package classes
{
	[Bindable]
	public class MediaItem
	{
		public var type:String;
		public var name:String;
		public var fileUrl:String;
		public var fileSizeInBytes:Number;
		public var selected:Boolean;
		public var converter:Converter;
		public var enabled:Boolean;
		
		public function MediaItem()
		{
			enabled = true;
		}
		
		public function get fileSize():String
		{
			return Math.round(fileSizeInBytes/1024) + " KB";
		}
	}
}