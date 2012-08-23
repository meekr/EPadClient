package classes
{
	import classes.Constants;
	
	import events.LoginEvent;
	import events.LogoutEvent;
	
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
		public var email:String;
		public var mobile:String;
		public var babyBirth:String;
		
		public var loggedIn:Boolean;
		
		public function User()
		{
		}
		
		public function login(name:String, password:String):void
		{
			this.username = name;
			this.password = password;
			var service:HTTPService = new HTTPService();
			service.url = Constants.LOGIN_URL;
			service.method = "POST";
			service.resultFormat = "text";
			service.addEventListener(ResultEvent.RESULT, resultListener);
			service.showBusyCursor = true;
			service.send(this);
		}
		
		private function resultListener(event:ResultEvent):void {
			var json:String = String(event.result);
			var obj:Object = JSON.parse(json);
			classes.Utils.log2c(json);
			var evt:LoginEvent = new LoginEvent();
			if (obj.state == "valid") {
				loggedIn = true;
				token = obj.data.token;
				hcode = obj.data.user.hcode;
				email = obj.data.user.email;
				mobile = obj.data.user.mobile;
				babyBirth = obj.data.user.babybirth;
				
				evt.success = true;
			}
			else {
				this.loggedIn = false;
				evt.error = "failed";
			}
			dispatchEvent(evt);
		}
		
		public function logout():void
		{
			loggedIn = false;
			username = "";
			token = "";
			hcode = "";
			email = "";
			mobile = "";
			babyBirth = "";
			
			var evt:LogoutEvent = new LogoutEvent();
			dispatchEvent(evt);
		}
	}
}