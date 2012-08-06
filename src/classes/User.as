package classes
{
	import classes.Constants;
	
	import events.LoginEvent;
	
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	[Bindable]
	public class User extends EventDispatcher
	{
		public var username:String = "";
		public var password:String;
		public var token:String;
		public var hcode:String;
		
		public var loggedIn:Boolean;
		
		public function User()
		{
		}
		
		public function login(name:String, password:String):void
		{
			this.username = name;
			this.password = password;
			var loginService:HTTPService = new HTTPService();
			loginService.url = Constants.LOGIN_URL;
			loginService.method = "POST";
			loginService.resultFormat = "text";
			loginService.addEventListener(ResultEvent.RESULT, resultListener);
			loginService.showBusyCursor = true;
			loginService.send(this);
		}
		
		private function resultListener(event:ResultEvent):void {
			var json:String = String(event.result);
			var obj:Object = JSON.parse(json);
			
			var evt:LoginEvent = new LoginEvent();
			if (obj.state == "valid") {
				this.loggedIn = true;
				this.token = obj.data.token;
				this.hcode = obj.data.user.hcode;
				
				evt.success = true;
			}
			else {
				this.loggedIn = false;
				evt.error = "failed";
			}
			dispatchEvent(evt);
		}
	}
}