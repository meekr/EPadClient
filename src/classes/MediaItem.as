package classes
{
	import flash.utils.ByteArray;
	
	import mx.utils.Base64Decoder;

	[Bindable]
	public class MediaItem
	{
		public var type:String;
		public var location:String;
		public var name:String;
		public var fileUrl:String;
		public var fileSizeInBytes:Number;
		public var selected:Boolean;
		public var converter:Converter;
		public var enabled:Boolean;
		public var base64Rep:String;
		
		public function MediaItem()
		{
			enabled = true;
		}
		
		public function get fileSize():String
		{
			return Math.round(fileSizeInBytes/1024) + " KB";
		}
		
		public function get base64ToByteArray():ByteArray
		{
			if (base64Rep)
			{
				var base64Dec:Base64Decoder = new Base64Decoder();
				base64Dec.decode(base64Rep);
				var ba:ByteArray = base64Dec.toByteArray();
				classes.Utils.log2c("MEDIA:"+fileUrl+", strlen="+base64Rep.length+", byte length="+ba.length);
				return base64Dec.toByteArray();
			}
			return null;
		}
	}
}