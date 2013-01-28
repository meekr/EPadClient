package classes
{
	import events.DeviceConnectionChangeEvent;
	
	import flash.events.EventDispatcher;
	import flash.external.*;
	import flash.utils.*;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.http.HTTPService;
	
	import spark.components.List;
	
	[Event(name="deviceConnectionChange", type="events.DeviceConnectionChangeEvent")]
	public class UIController extends EventDispatcher
	{
		private static var mInstance:UIController;
		
		public var downloadDirectory:String;
		
		private var mDriveNANDName:String;
		
		[Bindable]
		public var user:User;
		[Bindable]
		public var deviceDisk:DeviceDisk;
		[Bindable]
		public var firmwareVersion:String = "1.0";
		[Bindable]
		public var downloadingItems:ArrayCollection;
		[Bindable]
		public var version:String = "1.1.01.28";
		
		[Embed(source="assets/logo.png")]
		public var BRAND_LOGO:Class;
		[Embed(source="assets/logo-bym.png")]
		public var BRAND_LOGO_BYM:Class;
		[Embed(source="assets/logo-xbw.png")]
		public var BRAND_LOGO_XBW:Class;
		[Embed(source="assets/brand-pic-talentech.png")]
		public var BRAND_PIC:Class;
		[Embed(source="assets/brand-pic-bym.png")]
		public var BRAND_PIC_BYM:Class;
		[Embed(source="assets/home-bg.png")]
		public var HOME_BG:Class;
		[Embed(source="assets/home-bg-bym.png")]
		public var HOME_BG_BYM:Class;
		[Embed(source="assets/home-bg-xbw.png")]
		public var HOME_BG_XBW:Class;
		
		// "epad","bym","5inc","7inc","xbw" 分别对应 "e巧派客户端","贝因美客户端","新5寸客户端","新7寸客户端","小霸王客户端"
		[Bindable]
		public var CLIENTOS:String = "epad";
		
		public function UIController()
		{
			// setup communicate pipe
			CONFIG::ON_PC {
				ExternalInterface.addCallback("FL_setDownloadDirectory", FL_setDownloadDirectory);
				ExternalInterface.addCallback("FL_findNRDGameStoryAndAppRoot", FL_findNRDGameStoryAndAppRoot);
				ExternalInterface.addCallback("FL_setDeviceConnection", FL_setDeviceConnection);
				ExternalInterface.addCallback("FL_setDiskVolumnStatus", FL_setDiskVolumnStatus);
				
				firmwareVersion = ExternalInterface.call("F2C_getFirmwareVersion", "");
			}
			
			CONFIG::BYM {
				CLIENTOS = "bym";
			}
			CONFIG::XBW {
				CLIENTOS = "xbw";
			}
			
			user = new User();
			deviceDisk = new DeviceDisk();
			downloadingItems = new ArrayCollection();
		}
		
		public static function get instance():UIController
		{
			if (mInstance == null)
				mInstance = new UIController();
			return mInstance;
		}
		
		public function get driveNANDName():String
		{
			return mDriveNANDName;
		}
		
		public function externalAddCallback(functionName:String, callback:Function):void
		{
			CONFIG::ON_PC {
				ExternalInterface.addCallback(functionName, callback);
			}
		}
		
		// methods invoke UI
		private function FL_setDownloadDirectory(args:String):void
		{
			downloadDirectory = args;
		}
		
		private function FL_findNRDGameStoryAndAppRoot(args:String):void
		{
			mDriveNANDName = args;
		}
		
		private function FL_setDiskVolumnStatus(args:String):void
		{
			var free:int = int(args.split(",")[0]);
			var total:int = int(args.split(",")[1]);
			UIController.instance.deviceDisk.used = total - free;
			UIController.instance.deviceDisk.total = total;
		}
		
		private function FL_setDeviceConnection(args:String):void
		{
			deviceDisk.connected = (args == "1");
			if (deviceDisk.connected)
				firmwareVersion = ExternalInterface.call("F2C_getFirmwareVersion", "");
		}
		
		public function addPcItem(appName:String, fileSize:Number):void
		{
			for each (var item:AppItem in ApplicationController.instance.localItems) {
				if (item.name == appName)
					return;
			}
			
			var app:AppItem = new AppItem();
			app.name = appName;
			app.fileSizeInBytes = fileSize;
			app.location = LocationType.PC;
			app.iconUrl = this.downloadDirectory + appName + ".png";
			ApplicationController.instance.localItems.addItem(app);
			
			// check install status
			for each (var ai:AppItem in ApplicationController.instance.deviceItems)
			{
				if (ai.name == appName)
				{
					app.installed = true;
					break;
				}
			}
		}
		
		public function removeAppOnPc(app:AppItem):void
		{
			var idx:int = ApplicationController.instance.localItems.getItemIndex(app);
			if (idx > -1) {
				ApplicationController.instance.localItems.removeItemAt(idx);
				CONFIG::ON_PC {
					ExternalInterface.call("F2C_deleteAppOnPc", app.name);
				}
			}
		}
		
		public function addStoreItemToDownload(item:StoreItem):Download
		{
			var download:Download = new Download();
			download.appName = item.name;
			download.npkUrl = item.npkUrl;
			download.iconUrl = item.iconUrl;
			download.startDownload();
			downloadingItems.addItem(download);
			return download;
		}
	}
}