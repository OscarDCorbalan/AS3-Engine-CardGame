package as3.domain {
	import as3.Registry;
	
	public class GameVars {
		public var playerNum:uint = 0;
		public var currentPhase:uint = 0;
		public var modeReuse:Boolean = false;
		public var modeCart:Boolean = false;
		public var modeTown:Boolean = false;
		public var modeSaveHand:Boolean = false;
		public var selectEffect:SelectCardEffect;
		public var selectNum:SelectNum;
		public var blocked:Boolean = false;
		public var isHuman:Boolean;
		
		public var debug:Boolean;
		
		public function GameVars() {}
		
		public function log(s:String){
			if(debug) Registry.gvlog(playerNum + " " + blocked + " " + s);
		}
		public function dlog(s:String){
			if(debug) Registry.gvdlog(playerNum + " " + blocked + " " + s);
		}
		public function dlogAI(s:String){
			if(debug) Registry.gvdlogAI(playerNum + " " + blocked + " " + s);
		}
		public function dlogInt(s:String){
			if(debug) Registry.gvdlogInt(playerNum + " " + blocked + " " + s);
		}

	}
	
}
