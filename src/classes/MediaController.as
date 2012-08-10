package classes
{
	import classes.MediaItemType;
	
	import events.MediaConvertEvent;
	
	import flash.events.EventDispatcher;
	import flash.external.*;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;

	public class MediaController extends EventDispatcher
	{
		private static var mInstance:MediaController;
		
		[Bindable]
		public var mediaItems4Picture:ArrayCollection;
		[Bindable]
		public var mediaItems4Audio:ArrayCollection;
		[Bindable]
		public var mediaItems4Video:ArrayCollection;
		[Bindable]
		public var convertingPool:ArrayCollection;
		
		[Bindable]
		public var itemsOnDevice:ArrayCollection;
		
		public function MediaController()
		{
			convertingPool = new ArrayCollection();
			
			mediaItems4Picture = new ArrayCollection();
			mediaItems4Audio = new ArrayCollection();
			mediaItems4Video = new ArrayCollection();
			
			itemsOnDevice = new ArrayCollection();
			
			CONFIG::ON_PC {
				ExternalInterface.addCallback("FL_setConvertPercentage", FL_setConvertPercentage);
				ExternalInterface.addCallback("FL_setTransferPercentage", FL_setTransferPercentage);
				ExternalInterface.addCallback("FL_completeConvert", FL_completeConvert);
				ExternalInterface.addCallback("FL_completeTransfer", FL_completeTransfer);
				ExternalInterface.addCallback("FL_addLocalMedia", FL_addLocalMedia);
			}
		}
		
		public function getDeviceMediaItems():void
		{
			CONFIG::ON_PC {
				itemsOnDevice.removeAll();
				
				if (!UIController.instance.deviceDisk.connected)
					return;
				
				var methods:Array = ["F2C_getDeviceVideos", "F2C_getDeviceAudios", "F2C_getDevicePictures"];
				var types:Array = [MediaItemType.VIDEO, MediaItemType.AUDIO, MediaItemType.PICTURE];
				
				for (var i:int=0; i<methods.length; i++)
				{
					var files:String = ExternalInterface.call(methods[i], "");
					if (files.length > 0)
					{
						var items:Array = files.split(",");
						for each (var str:String in items)
						{
							var filepath:String = str.split("#")[0];
							var name:String = filepath.substr(filepath.lastIndexOf("\\")+1);
							
							var item:MediaItem = new MediaItem();
							item.fileUrl = filepath;
							item.type = types[i];
							item.name = name;
							item.fileSizeInBytes = parseInt(str.split("#")[1]);
							
							itemsOnDevice.addItem(item);
						}
					}
				}
			}
		}
		
		public static function get instance():MediaController
		{
			if (mInstance == null)
			{
				mInstance = new MediaController();
			}
			return mInstance;
		}
		
		public function addConvertTask(converter:Converter):void
		{
			convertingPool.addItem(converter);
		}
		
		public function startConverting():void
		{
			if (convertingPool.length > 0)
			{
				var converter:Converter = convertingPool.getItemAt(0) as Converter;
				CONFIG::ON_PC {
					var method:String;
					switch (converter.mediaType)
					{
						case MediaItemType.VIDEO:
							method = "F2C_convertVideo";
							break;
						case MediaItemType.AUDIO:
							method = "F2C_convertAudio";
							break;
						case MediaItemType.PICTURE:
							method = "F2C_convertPicture";
							break;
					}
					
					ExternalInterface.call(method, converter.sourceFile);
				}
			}
		}
		
		// methods invoke UI
		private function FL_setConvertPercentage(args:String):void
		{
			var converter:Converter = convertingPool.getItemAt(0) as Converter;
			converter.percentage = parseInt(args);
			if (isNaN(converter.percentage))
				converter.percentage = 0;
			
			var evt:MediaConvertEvent = new MediaConvertEvent();
			evt.status = MediaItemTransitionStatus.CONVERTING;
			evt.percentage = converter.percentage;
			converter.dispatchEvent(evt);
		}
		
		private function FL_setTransferPercentage(args:String):void
		{
			var converter:Converter = convertingPool.getItemAt(0) as Converter;
			converter.percentage = parseInt(args);
			if (isNaN(converter.percentage))
				converter.percentage = 0;
			converter.percentage = Math.min(converter.percentage, 100);
			
			var evt:MediaConvertEvent = new MediaConvertEvent();
			evt.status = MediaItemTransitionStatus.TRANSFERING;
			evt.percentage = converter.percentage;
			converter.dispatchEvent(evt);
		}
		
		private function FL_completeConvert(args:String):void
		{
			if (convertingPool.length > 0)
			{
				var converter:Converter = convertingPool.getItemAt(0) as Converter;
				
				var evt:MediaConvertEvent = new MediaConvertEvent();
				evt.percentage = 0;
				evt.status = MediaItemTransitionStatus.TRANSFERING;
				converter.dispatchEvent(evt);
				
				CONFIG::ON_PC {
					switch (converter.mediaType)
					{
						case MediaItemType.AUDIO:
							ExternalInterface.call("F2C_transferAudio2Device", converter.filenameWithoutExtension);
							break;
						case MediaItemType.VIDEO:
							ExternalInterface.call("F2C_transferVideo2Device", converter.filenameWithoutExtension);
							break;
						case MediaItemType.PICTURE:
							ExternalInterface.call("F2C_transferPicture2Device", converter.filenameWithoutExtension);
							break;
					}
				}
			}
		}
		
		private function FL_completeTransfer(args:String):void
		{
			if (convertingPool.length > 0)
			{
				var converter:Converter = convertingPool.getItemAt(0) as Converter;
				convertingPool.removeItemAt(0);
				
				var evt:MediaConvertEvent = new MediaConvertEvent();
				evt.status = MediaItemTransitionStatus.COMPLETED;
				converter.dispatchEvent(evt);
				
				var str:String = "";
				CONFIG::ON_PC {
					str = ExternalInterface.call("F2C_insertMediaNode", converter.mediaType + "," + converter.filenameWithoutExtension);
				}
				
				// add item on device
				if (str && str.length > 0)
				{
					var filepath:String = str.split("#")[0];
					var name:String = filepath.substr(filepath.lastIndexOf("\\")+1);
					
					var item:MediaItem = new MediaItem();
					item.fileUrl = filepath;
					item.type = converter.mediaType;
					item.name = name;
					item.fileSizeInBytes = parseInt(str.split("#")[1]);
					
					itemsOnDevice.addItemAt(item, 0);
				}
			}
			
			startConverting();
		}
		
		private function FL_addLocalMedia(args:String):void
		{
			var str:Array = args.split(",");
			var type:String = str[0];
			var size:Number = parseInt(str[1]);
			var file:String = str[2];
			
			var item:MediaItem = new MediaItem();
			item.fileUrl = file;
			item.type = type;
			item.name = file.substr(file.lastIndexOf("\\")+1);
			item.fileSizeInBytes = size;
			
			switch (type)
			{
				case MediaItemType.AUDIO:
					mediaItems4Audio.addItem(item);
					break;
				case MediaItemType.VIDEO:
					mediaItems4Video.addItem(item);
					break;
				case MediaItemType.PICTURE:
					mediaItems4Picture.addItem(item);
					break;
			}
		}
	}
}