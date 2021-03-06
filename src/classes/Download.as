package classes
{
	import classes.DownloadStatus;
	
	import events.DownloadCompleteEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.external.*;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.utils.Base64Encoder;
	
	[Bindable]
	public class Download extends EventDispatcher
	{
		public var appName:String;
		public var percentage:Number;
		public var status:String;
		public var npkUrl:String;
		public var iconUrl:String;
		
		private var npkLoader:URLLoader;
		private var pngLoader:URLLoader;
		
		public function Download()
		{
			percentage = 0;
			status = DownloadStatus.NOT_STARTED;
			
			npkLoader = new URLLoader();
			npkLoader.dataFormat = URLLoaderDataFormat.BINARY;
			npkLoader.addEventListener(Event.OPEN, npkOpenHandler);
			npkLoader.addEventListener(ProgressEvent.PROGRESS, npkProgressHandler);
			npkLoader.addEventListener(Event.COMPLETE, npkCompleteHandler);
			
			pngLoader = new URLLoader();
			pngLoader.dataFormat = URLLoaderDataFormat.BINARY;
			pngLoader.addEventListener(Event.COMPLETE, pngCompleteHandler);
		}
		
		public function startDownload():void
		{
			var service:HTTPService = new HTTPService();
			service.url = npkUrl;
			classes.Utils.log2c("url="+npkUrl);
			service.method = "POST";
			service.resultFormat = "text";
			service.addEventListener(ResultEvent.RESULT, resultListener);
			service.send(this);
		}
		
		private function resultListener(event:ResultEvent):void {
			var json:String = String(event.result);
			var obj:Object = JSON.parse(json);
			if (obj.state == "ok") {
				var request:URLRequest = new URLRequest();
				request.url = Constants.getRealNpkLink(obj.link+"?rnd="+Math.floor(Math.random()*100000));
				npkLoader.load(request);
				
				request.url = iconUrl;
				pngLoader.load(request);
			}
			else if (obj.error) {
				Alert.show(obj.message);
			}
		}
		
		public function pauseDownload():void
		{
			
		}
		
		public function resumeDownload():void
		{
			
		}
		
		public function cancelDownload():void
		{
			npkLoader.close();
			pngLoader.close();
			status = DownloadStatus.CANCELLED;
			
			CONFIG::ON_PC {
				ExternalInterface.call("F2C_cancelDownload", UIController.instance.downloadDirectory+appName);
			}
		}
		
		private function npkOpenHandler(event:Event):void
		{
			status = DownloadStatus.DOWNLOADING;
		}
		
		private function npkProgressHandler(event:ProgressEvent):void
		{
			status = DownloadStatus.DOWNLOADING;
			percentage = event.bytesLoaded*100 / event.bytesTotal;
			//trace(event.bytesLoaded, event.bytesTotal, percentage);
			//Utils.log2c(event.bytesLoaded+' of '+event.bytesTotal);
		}
		
		private function npkCompleteHandler(event:Event):void
		{
			status = DownloadStatus.COMPLETED;
			percentage = 100;
			
			var buf:ByteArray = npkLoader.data;
			var base64Enc:Base64Encoder = new Base64Encoder();
			base64Enc.encodeBytes(buf, 0, buf.length);
			var str:String = base64Enc.toString();
			str = str.split("\n").join("");
			Utils.log2c(str.length+": "+str.substr(0, 1000));
			CONFIG::ON_PC {
				ExternalInterface.call("F2C_saveFileFromBase64", UIController.instance.downloadDirectory+appName+".npk,"+str);
			}
			
			UIController.instance.addPcItem(appName, buf.length);
			
			var evt:DownloadCompleteEvent = new DownloadCompleteEvent();
			dispatchEvent(evt);
		}
		
		private function pngCompleteHandler(event:Event):void
		{
			var buf:ByteArray = pngLoader.data;
			var base64Enc:Base64Encoder = new Base64Encoder();
			base64Enc.encodeBytes(buf, 0, buf.length);
			var str:String = base64Enc.toString();
			
			str = str.split("\n").join("");
			CONFIG::ON_PC {
				ExternalInterface.call("F2C_saveFileFromBase64", UIController.instance.downloadDirectory+appName+".png,"+str);
			}
		}
	}
}