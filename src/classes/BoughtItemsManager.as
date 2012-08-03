package classes
{
	import mx.collections.ArrayCollection;

	public class BoughtItemsManager
	{
		private var _items:ArrayCollection;
		private var _itemsHash:Object;
		
		public function BoughtItemsManager()
		{
			_items = new ArrayCollection();
			_itemsHash = new Object();
		}
		
		public function get items():ArrayCollection
		{
			return _items;
		}
		
		public function addItem(item:BoughtItem):void
		{
			_items.addItem(item);
			_itemsHash[item.name] = item;
		}
		
		public function hasBought(name:String):Boolean
		{
			return (_itemsHash[name] != null);
		}
	}
}