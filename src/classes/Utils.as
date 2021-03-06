package classes
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.external.*;
	import flash.net.*;
	import flash.utils.ByteArray;
	
	public class Utils
	{
		public static function log2c(message:String):void
		{
			CONFIG::ON_PC {
				ExternalInterface.call("F2C_TRACE", message);
			}
		}
		
		public static function getFileSize(size:Number):String
		{
			
			var m:Number = Math.floor(size/(1024*1024));
			if (m > 0) {
				size = size - m * 1024 * 1024;
				var mm:Number = Math.round(size*10/(1024*1024));
				mm = Math.min(9, mm);
				return (mm<=0 ? m : m+"."+mm) + " MB";
			}
			else
				return Math.round(size/1024) + " KB";
		}
		
		public static function getDuration(seconds:Number):String
		{
			var s:String;
			if (seconds < 60) {
				s = seconds + "秒";
			}
			else if (seconds < 60*60) {
				s = Math.floor(seconds / 60) + "分";
				if (seconds % 60 > 0)
					s += seconds % 60 + "秒";
			}
			else {
				s = Math.floor(seconds / 3600) + "小时";
				seconds = seconds % 3600;
				if (seconds > 0) {
					s += Math.floor(seconds / 60) + "分";
					if (seconds % 60 > 0)
						s += seconds % 60 + "秒";
				}
			}
			return s;
		}
		
		public static function gotoUrl(url:String):void
		{
			navigateToURL(new URLRequest(url));
		}
		
		public static function byteArray2Bitmap(bytes:ByteArray):Bitmap
		{
			var bmd:ByteArray = bytes; 
			bmd.position =bmd.length-2; 
			var imageWidth:int = bmd.readShort(); 
			bmd.position =bmd.length-4; 
			var imageHeight:int = bmd.readShort(); 
			var copyBmp:BitmapData = new BitmapData(imageWidth, imageHeight, true); 
			//利用setPixel方法给图片中的每一个像素赋值,做逆操作 
			//ByteArray数组从零开始存储一直到最后都是图片数据,因为读入时的高和宽都是一样的,所以当循环结束是正好读完 
			bmd.position = 0; 
			for (var i:uint=0; i<imageHeight; i++) 
			{ 
				for (var j:uint=0; j<imageWidth; j++) 
				{ 
					copyBmp.setPixel(j, i, bmd.readUnsignedInt()); 
				} 
			} 
			var bmp:Bitmap = new Bitmap(copyBmp);
			return bmp;
		}
	}
}