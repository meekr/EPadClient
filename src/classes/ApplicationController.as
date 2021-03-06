package classes
{
	import events.AppInstallEvent;
	import events.DeviceConnectionChangeEvent;
	import events.SyncStatusChangeEvent;
	
	import flash.events.EventDispatcher;
	import flash.external.*;
	
	import mx.collections.ArrayCollection;
	import mx.utils.Base64Encoder;

	public class ApplicationController extends EventDispatcher
	{
		private static var mInstance:ApplicationController;
		public static function get instance():ApplicationController
		{
			if (mInstance == null)
				mInstance = new ApplicationController();
			return mInstance;
		}
		
		[Bindable]
		public var localItems:ArrayCollection;
		[Bindable]
		public var deviceItems:ArrayCollection;
		[Bindable]
		public var installingPool:ArrayCollection;
		
		public var boughtItems:ArrayCollection;
		
		public function ApplicationController()
		{
			localItems = new ArrayCollection();
			deviceItems = new ArrayCollection();
			installingPool = new ArrayCollection();
			boughtItems = new ArrayCollection();
			
			getDeviceAppItems();
			UIController.instance.addEventListener(DeviceConnectionChangeEvent.name, deviceConnectionChangeHandler);
			
			CONFIG::ON_PC {
				ExternalInterface.addCallback("FL_addDownloadedApp", FL_addDownloadedApp);
				
				ExternalInterface.addCallback("FL_installSetExtractInformation", FL_installSetExtractInformation);
				ExternalInterface.addCallback("FL_installCompleteExtract", FL_installCompleteExtract);
				ExternalInterface.addCallback("FL_installSetTransferInformation", FL_installSetTransferInformation);
				ExternalInterface.addCallback("FL_installCompleteTransfer", FL_installCompleteTransfer);
				ExternalInterface.addCallback("FL_failInstall", FL_failInstall);
				ExternalInterface.addCallback("FL_duplicateInstall", FL_duplicateInstall);
			}
		}
		
		private function deviceConnectionChangeHandler(event:DeviceConnectionChangeEvent):void
		{
			getDeviceAppItems();
			var lai:AppItem;
			if (event.connected)
			{
				for each (lai in localItems)
				{
					for each (var ai:AppItem in deviceItems)
					{
						if (ai.name == lai.name)
						{
							lai.installed = true;
							lai.selected = false;
							break;
						}
					}
				}
			}
			else
			{
				for each (lai in localItems)
				{
					lai.installed = false;
				}
			}
		}
		
		private function getDeviceAppItems():void
		{
			CONFIG::ON_PC {
				deviceItems.removeAll();
				if (!UIController.instance.deviceDisk.connected)
					return;
				
				var files:String = ExternalInterface.call("F2C_getDeviceApps", "");
				if (files.length > 0)
				{
					var items:Array = files.split(",");
					for each (var str:String in items)
					{
						// str:name#iconUrl
						var icon:String = str.split("#")[1];
						icon = icon.split("/").join("\\");
						
						var item:AppItem = new AppItem();
						item.name = str.split("#")[0];
						item.iconUrl = UIController.instance.driveNANDName + "\\book\\" + icon;
						item.location = LocationType.DEVICE;
						item.iconBase64Rep = ExternalInterface.call("F2C_getDeviceIconBase64", item.iconUrl);
						
						deviceItems.addItem(item);
					}
				}
			}
		}
		
		public function startInstalling():void
		{
			if (installingPool.length > 0)
			{
				var app:AppItem = installingPool.getItemAt(0) as AppItem;
				CONFIG::ON_PC {
					ExternalInterface.call("F2C_installApp", app.name);
				}
			}
			else
			{
				this.syncingToDevice = false;
			}
		}
		
		
		// invoke UI
		private function FL_addDownloadedApp(args:String):void
		{
			var npkPath:String = args.substr(0, args.lastIndexOf(","));
			var iconPath:String = npkPath.substr(0, npkPath.length-3) + "png";
			var appName:String = iconPath.substr(iconPath.lastIndexOf("\\") + 1);
			appName = appName.substr(0, appName.length-4);
			var filesize:Number = parseInt(args.substr(args.lastIndexOf(",")+1));
			
			var app:AppItem = new AppItem();
			app.name = appName;
			app.location = LocationType.PC;
			app.iconUrl = iconPath;
			app.fileSizeInBytes = filesize;
			app.location = LocationType.PC;
			localItems.addItem(app);
			
			for each (var ai:AppItem in deviceItems)
			{
				if (ai.name == appName)
				{
					app.installed = true;
					break;
				}
			}
		}
		
		private function FL_installSetExtractInformation(args:String):void
		{
			if (installingPool.length > 0)
			{
				var app:AppItem = installingPool.getItemAt(0) as AppItem;
				var evt:AppInstallEvent = new AppInstallEvent();
				evt.status = AppItemTransitionStatus.EXTRACTING;
				evt.description = args;
				app.dispatchEvent(evt);
			}
		}
		
		private function FL_installCompleteExtract(args:String):void
		{
			if (installingPool.length > 0)
			{
				var app:AppItem = installingPool.getItemAt(0) as AppItem;
				var evt:AppInstallEvent = new AppInstallEvent();
				evt.status = AppItemTransitionStatus.TRANSFERING;
				evt.percentage = 0;
				app.dispatchEvent(evt);
				
				CONFIG::ON_PC {
					ExternalInterface.call("F2C_installTransferApp", app.name);
				}
			}
		}
		
		private function FL_installSetTransferInformation(args:String):void
		{
			if (installingPool.length > 0)
			{
				var app:AppItem = installingPool.getItemAt(0) as AppItem;
				var evt:AppInstallEvent = new AppInstallEvent();
				evt.status = AppItemTransitionStatus.TRANSFERING;
				evt.description = args;
				app.dispatchEvent(evt);
			}
		}
		
		private function FL_installCompleteTransfer(args:String):void
		{
			if (installingPool.length > 0)
			{
				var app:AppItem = installingPool.getItemAt(0) as AppItem;
				app.selected = false;
				app.installed = true;
				
				var evt:AppInstallEvent = new AppInstallEvent();
				evt.status = AppItemTransitionStatus.COMPLETED;
				evt.percentage = 0;
				app.dispatchEvent(evt);
				
				var str:String = "";
				CONFIG::ON_PC {
					str = ExternalInterface.call("F2C_insertAppNode", app.name);
				}
				
				// add item on device
				if (str && str.length > 0)
				{
					// str:name#iconUrl
					var icon:String = str.split("#")[1];
					icon = icon.split("/").join("\\");
					
					var item:AppItem = new AppItem();
					item.name = str.split("#")[0];
					item.iconUrl = UIController.instance.driveNANDName + "\\book\\" + icon;
					item.location = LocationType.DEVICE;
					CONFIG::ON_PC {
						item.iconBase64Rep = ExternalInterface.call("F2C_getDeviceIconBase64", item.iconUrl);
						ExternalInterface.call("F2C_updateVolumnStatus", "");
					}
					
					deviceItems.addItem(item);
				}
				
				installingPool.removeItemAt(0);
				startInstalling();
			}
		}
		
		private function FL_failInstall(args:String):void
		{
			if (installingPool.length > 0)
			{
				var app:AppItem = installingPool.getItemAt(0) as AppItem;
				var evt:AppInstallEvent = new AppInstallEvent();
				evt.status = AppItemTransitionStatus.DEFAULT;
				evt.description = args;
				app.dispatchEvent(evt);
				
				installingPool.removeAll();
				this.syncingToDevice = false;
			}
		}
		
		private function FL_duplicateInstall(args:String):void
		{
			for (var i:int=0; i<installingPool.length; i++)
			{
				var app:AppItem = AppItem(installingPool[i]);
				if (app.name == args)
				{
					installingPool.removeItemAt(i);
					break;
				}
			}
			startInstalling();
		}
		
		private var _syncingToDevice:Boolean;
		
		[Bindable]
		public function get syncingToDevice():Boolean
		{
			return _syncingToDevice;
		}
		
		public function set syncingToDevice(value:Boolean):void
		{
			if (_syncingToDevice != value)
			{
				_syncingToDevice = value;
				dispatchEvent(new SyncStatusChangeEvent());
			}
		}
		
		[Bindable(event="syncStatusChangeEvent")]
		public function get syncStatusText():String
		{
			return this.syncingToDevice ? "正在同步中..." : "同步到设备";
		}
	}
}