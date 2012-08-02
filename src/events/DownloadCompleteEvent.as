package events
{
	import flash.events.Event;

	public class DownloadCompleteEvent extends Event
	{
		public static var name:String = "downloadCompleteEvent";
		
		public function DownloadCompleteEvent()
		{
			super(name);
		}
	}
}