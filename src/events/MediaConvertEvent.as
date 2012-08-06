package events
{
	import flash.events.Event;
	import classes.MediaItemTransitionStatus;

	public class MediaConvertEvent extends Event
	{
		public static var name:String = "mediaConvertEvent";
		
		public var percentage:Number = 0;
		public var status:String = MediaItemTransitionStatus.WAITING;
		
		public function MediaConvertEvent()
		{
			super(name);
		}
	}
}