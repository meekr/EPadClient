package classes
{
	import classes.Constants;
	import classes.LocationType;
	import classes.Utils;
	
	import events.LoginEvent;
	import events.StoreItemsLoadedEvent;
	
	import flash.events.EventDispatcher;
	import flash.external.*;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public class DataController extends EventDispatcher
	{
		private static var mInstance:DataController;
		
		private var _currentCategoryFilter:String;
		
		[Bindable]
		public var statUsageTiming:ArrayCollection;
		[Bindable]
		public var statUsageCounting:ArrayCollection;
		
		public function DataController()
		{
			statUsageTiming = new ArrayCollection();
			statUsageCounting = new ArrayCollection();
		}
		
		public static function get instance():DataController
		{
			if (mInstance == null)
			{
				mInstance = new DataController();
			}
			return mInstance;
		}
		
		public function getStoreProductList(categoryId:int, page:int, sort:String, slug:String):void
		{
			var params:Array = new Array();
			if (slug) {
				params.push("slug="+encodeURIComponent(slug));
			}
			else {
				if (categoryId)
					params.push("cid="+categoryId);
				if (sort)
					params.push("tab="+sort);
			}
			
			if (page)
				params.push("page="+page);
			
			if (page && page > 1)
				params.push("size=12");
			else
				params.push("size=6");
			params.push("clientos="+UIController.instance.CLIENTOS);
			
			var url:String = Constants.PRODUCT_URL + "?" + params.join("&");
			trace(url);
			var service:HTTPService = new HTTPService();
			service.url = url;
			service.method = "POST";
			service.resultFormat = "text";
			service.addEventListener(ResultEvent.RESULT, storeResultListener);
			service.showBusyCursor = true;
			service.send(this);
		}
		
		private function storeResultListener(event:ResultEvent):void {
			var json:String = String(event.result);
			trace(json);
			var obj:Object = JSON.parse(json);
			var items:ArrayCollection = new ArrayCollection();
			for (var i:int=0; i<obj.products.length; i++) {
				var item:StoreItem = new StoreItem();
				item.id = obj.products[i].id;
				item.name = obj.products[i].name;
				item.category = obj.products[i].category_name;
				item.createDate = obj.products[i].create_date;
				item.npkUrl = Constants.getNpkUrl(obj.products[i].download_link);
				item.iconUrl = Constants.getThumbUrl(obj.products[i].thumbs.s);
				items.addItem(item);
			}
			
			var evt:StoreItemsLoadedEvent = new StoreItemsLoadedEvent();
			evt.items = items;
			evt.numPages = parseInt(obj.pagination.total);
			dispatchEvent(evt);
		}
		
		private function filterMyArrayCollection(item:Object):Boolean
		{
			if (_currentCategoryFilter)
				return item.category == _currentCategoryFilter;
			return true;
		}
	}
}