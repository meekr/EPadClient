package events
{
	import flash.events.Event;

	public class LogoutEvent extends Event
	{
		public static var name:String = "logoutEvent";
		
		public function LogoutEvent()
		{
			super(name);
		}
	}
}