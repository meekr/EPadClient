package classes
{
	[Bindable]
	public class StoreItem
	{
		public var id:String;
		public var name:String;
		public var category:String;
		
		public var npkUrl:String;
		public var iconUrl:String;
		
		public var purchased:Boolean;
		
		public function StoreItem()
		{
		}
	}
}