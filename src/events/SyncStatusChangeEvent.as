package events
{
	import flash.events.Event;

	public class SyncStatusChangeEvent extends Event
	{
		public static var name:String = "syncStatusChangeEvent";
		
		public function SyncStatusChangeEvent()
		{
			super(name);
		}
	}
}