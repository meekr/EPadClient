package events
{
	import classes.AppItemTransitionStatus;
	
	import flash.events.Event;
	
	public class AppInstallEvent extends Event
	{
		public static var name:String = "appInstallEvent";
		public var status:String = AppItemTransitionStatus.WAITING;
		public var description:String;
		public var percentage:Number;
		
		public function AppInstallEvent()
		{
			super(name);
		}
	}
}