package events
{
	import flash.events.Event;

	public class LoginEvent extends Event
	{
		public static var name:String = "loginEvent";
		public var success:Boolean;
		public var error:String;
		
		public function LoginEvent()
		{
			super(name);
		}
	}
}