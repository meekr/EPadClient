package events
{
	import flash.events.Event;

	public class MenuBarSelectedIndexChangedEvent extends Event
	{
		public static var name:String = "menuBarSelectedIndexChangedEvent";
		public var oldIndex:int;
		public var newIndex:int;
		
		public function MenuBarSelectedIndexChangedEvent()
		{
			super(name);
		}
	}
}