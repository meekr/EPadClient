package classes
{
	import events.MediaConvertEvent;
	
	import flash.events.EventDispatcher;
	import flash.external.*;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;

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
		
		public function MediaController()
		{
			convertingPool = new ArrayCollection();
			
			mediaItems4Picture = new ArrayCollection();
			mediaItems4Audio = new ArrayCollection();
			mediaItems4Video = new ArrayCollection();
			
			CONFIG::ON_PC {
				ExternalInterface.addCallback("FL_setConvertPercentage", FL_setConvertPercentage);
				ExternalInterface.addCallback("FL_completeConvert", FL_completeConvert);
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
					ExternalInterface.call("F2C_importVideo", converter.sourceFile);
				}
			}
		}
		
		public function importVideo(converter:Converter):void
		{
			convertingPool[converter.sourceFile] = converter;
			CONFIG::ON_PC {
				ExternalInterface.call("F2C_importVideo", converter.sourceFile);
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
		
		private function FL_completeConvert(args:String):void
		{
			if (convertingPool.length > 0)
			{
				var converter:Converter = convertingPool.getItemAt(0) as Converter;
				convertingPool.removeItemAt(0);
				
				var evt:MediaConvertEvent = new MediaConvertEvent();
				evt.status = MediaItemTransitionStatus.COMPLETED;
				converter.dispatchEvent(evt);
			}
			
			startConverting();
		}
	}
}