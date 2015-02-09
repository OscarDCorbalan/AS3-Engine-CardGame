package as3
{
	import flash.display.Stage;
	import fl.controls.TextArea;
	import flash.events.Event;
	import as3.domain.Rules;
	
	public class Registry 
	{			
		public static var debug:Boolean = true;
		public static var debugInterface:Boolean = true;
		public static var debugAI:Boolean = true;
		public static var stage:Stage;
		public static var screenLog:TextArea;
		public static var rules:Rules = new Rules();
		
		public function Registry() 
		{
			
		}
		public static function log(s:String, nl:Boolean = true){
			gvlog(s,true,nl);
		}
		public static function logSeparator(){
			gvlog("-------------------------------------------------------",true);
		}
		public static function gvlog(s:String, tr:Boolean = true, nl:Boolean = true){
			trace(s);
			screenLog.appendText(s);
			if(nl) screenLog.appendText("\n");
		}
		
		public static function gvdlog(s:String){			
			trace("1");
			if(debug){
				trace("2");
				gvlog("d: " + s, false);		
				trace("3");
			}
		}
		public static function gvdlogAI(s:String){
			if(debugAI){
				gvlog("d.ai: " + s, false);
			}
			
		}
		public static function gvdlogInt(s:String){
			if(debugAI){
				gvlog("d.int: " + s, false);
			}
		}
		public static function screenLogAutoscroll(e:Event):void
		{
			screenLog.verticalScrollPosition = screenLog.maxVerticalScrollPosition;
		}
	
	}

}