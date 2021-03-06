package classes
{
	import classes.MediaItemTransitionStatus;
	
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
		public var base64Rep:String;
		
		public var deviceConfigXmlFile:String;
		
		public var status:String;
		
		public function MediaItem()
		{
			status = MediaItemTransitionStatus.DEFAULT;
		}
		
		public function get fileSize():String
		{
			return classes.Utils.getFileSize(fileSizeInBytes);
		}
		
		public function get base64ToByteArray():ByteArray
		{
			if (base64Rep)
			{
				var base64Dec:Base64Decoder = new Base64Decoder();
				base64Dec.decode(base64Rep);
				var ba:ByteArray = base64Dec.toByteArray();
				return base64Dec.toByteArray();
			}
			return null;
		}
	}
}