package events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;

	public class StoreItemsLoadedEvent extends Event
	{
		public static var name:String = "storeItemsLoadedEvent";
		
		[Bindable]
		public var items:ArrayCollection;
		public var numPages:Number;
		
		public function StoreItemsLoadedEvent()
		{
			super(name);
		}
	}
}