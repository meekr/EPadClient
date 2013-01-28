package classes
{
	import classes.Constants;
	
	import com.adobe.crypto.MD5;
	
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
		public var asso_type:String;
		
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
			var evt:LoginEvent = new LoginEvent();
			if (obj.state == "valid") {
				loggedIn = true;
				token = obj.data.token;
				hcode = obj.data.user.hcode;
				email = obj.data.user.email;
				mobile = obj.data.user.mobile;
				babyBirth = obj.data.user.babybirth;
				asso_type = obj.data.user.asso_type;
				
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
			asso_type = "";
			
			var evt:LogoutEvent = new LogoutEvent();
			dispatchEvent(evt);
		}
		
		public function register(user:String, mobile:String, email:String, hcode:String, password:String, assotype:String):void {
			this.username = user;
			this.password = password;
			
			// md5( $salt . $hcode . $asso_type . $ts ). "_" . $ts
			var salt:String = 'askfIUH&*()h23:>KJ)(&%!@lkjKLHI(*&^%KJHDF&*KHL^&Y(FDL*&(F^FGG^(*G(&OIJ';
			var date:Date = new Date();
			var ts:Number = date.time;
			var tkn:String = MD5.hash(salt + hcode + assotype + ts) + '_' + ts; 
			trace('token=', tkn);
			
			var param:Object = {username:user, password:password, mobile:mobile, email:email, hcode:hcode, asso_type:assotype, token:tkn};
			var service:HTTPService = new HTTPService();
			service.url = Constants.REGISTER_URL;
			service.method = "POST";	
			service.resultFormat = "text";
			service.addEventListener(ResultEvent.RESULT, registerResultListener);
			service.showBusyCursor = true;
			service.send(param);
		}
		
		private function registerResultListener(event:ResultEvent):void {
			var json:String = String(event.result);
			trace(json);
			var obj:Object = JSON.parse(json);
			if (obj.result == 'error') {
				this.username = '';
				this.password = '';
				
				var errors:Array = [];
				for (var prop:String in obj.error) {
					if (obj.error.hasOwnProperty(prop))
						errors.push(obj.error[prop]);
				}
				Alert.show(errors.join('\n'), '');
			}
			else if (obj.result == 'success') {
				loggedIn = true;
				token = obj.user.token;
				hcode = obj.user.hcode;
				email = obj.user.email;
				mobile = obj.user.mobile;
				asso_type = obj.user.asso_type;
				
				var evt:LoginEvent = new LoginEvent();
				evt.success = true;
				dispatchEvent(evt);
			}
		}
	}
}