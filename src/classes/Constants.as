package classes
{
	import classes.UIController;
	
	public class Constants
	{
		private static var DOMAIN:String = "http://www.kizup.com/";
		
		public static var LOGIN_URL:String = DOMAIN + "client/user/login";
		public static var PRODUCT_URL:String = DOMAIN + "client/product/list";
		public static var LEFT_BANNER_URL:String = DOMAIN + "client/site/clientleft";
		public static var RIGHT_BANNER_URL:String = DOMAIN + "client/site/clientright";
		public static var SIGNUP_URL:String = DOMAIN + "signup";
		public static var CHECK_UI_URL:String = DOMAIN + "client/ui.xml";
		public static var UI_SYSTEM_URL_PREFIX:String = DOMAIN + "client/UI_";
		public static var CHANGE_PROFILE_URL:String = DOMAIN + "client/user/edit_profile";
		
		public static function getProductDetailUrl(id:int):String
		{
			return DOMAIN + "product/view/" + id;
		}
		
		public static function getNpkUrl(npkPath:String):String
		{
			return DOMAIN + npkPath + "?token=" + UIController.instance.user.token;
		}
		
		public static function getRealNpkLink(link:String):String
		{
			return DOMAIN + link;
		}
		
		public static function getThumbUrl(thumbPath:String):String
		{
			return DOMAIN + thumbPath;
		}
		
		public static function get DOWNLOAD_HISTORY_URL():String
		{
			return DOMAIN + "client/user/download?token=" + UIController.instance.user.token + "&size=200";
		}
	}
}