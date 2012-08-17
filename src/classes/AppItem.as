package classes
{
	import classes.LocationType;
	
	import events.AppItemDeleteEvent;
	import events.AppItemSyncEvent;
	
	import flash.events.EventDispatcher;
	import flash.utils.*;
	import flash.utils.ByteArray;
	
	import mx.controls.Image;
	import mx.utils.Base64Decoder;

	[Bindable]
	public class AppItem extends EventDispatcher
	{
		public var id:String;
		public var name:String;
		public var category:String;
		public var location:String;
		public var selected:Boolean;
		public var fileSizeInBytes:Number;
		
		public var purchased:Boolean;
		public var downloaded:Boolean;
		public var installed:Boolean;
		
		public var npkUrl:String;
		public var iconUrl:String;
		
		// Base64 encoded
		public var iconBase64Rep:String;
		
		public function AppItem()
		{
		}
		
		public function dispose():void
		{
			name = "";
			category = "";
			iconBase64Rep = "";
		}
		
		public function get iconByteArray():ByteArray
		{
			if (iconBase64Rep)
			{
				var base64Dec:Base64Decoder = new Base64Decoder();
				base64Dec.decode(iconBase64Rep);
				var ba:ByteArray = base64Dec.toByteArray();
				return ba;
			}
			return null;
		}
		
		public function isDeviceType():Boolean
		{
			return location == LocationType.DEVICE;
		}
		
		public function isPcType():Boolean
		{
			return location == LocationType.PC;
		}
		
		public function isStoreType():Boolean
		{
			return location == LocationType.STORE;
		}
		
		public function get fileSize():String
		{
			return classes.Utils.getFileSize(fileSizeInBytes);
		}
		
		public function clone4DeviceItem():AppItem
		{
			var app:AppItem = new AppItem();
			app.name = this.name;
			app.category = this.category;
			app.location = LocationType.DEVICE;
			return app;
		}
	}
}