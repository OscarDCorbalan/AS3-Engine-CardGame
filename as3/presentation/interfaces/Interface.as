package as3.presentation.interfaces{
	import flash.display.MovieClip;
	import as3.domain.Table;
	import as3.domain.GameEvent;
	import as3.Registry;
	import flash.events.MouseEvent;
	import as3.domain.GameVars;

	public class Interface extends MovieClip{
		//protected var table:Table;
		protected var gv:GameVars;
		public function getGV():GameVars{return gv;}
		
		public function Interface(_gv:GameVars) {			
			gv = _gv;
			gv.dlog("Initiating Interface");
		}
		public function setTable(t:Table){
		}
		
		//virtuals
		public function mouseBlock(){}		
		public function mouseUnblock(for_subClass_dont_delete:int = 0){}		
		public function passBlock(){}		
		public function passUnblock(){}
		public function allowOnlyHand(b:Boolean){}
		public function allowOnlyTown(b:Boolean){}
		public function allowOnlyEvents(b:Boolean){}
		public function reuseMode(b:Boolean){}
		public function addPreOKButton(){}
		public function update(){}
		public function carting(b:Boolean,left:uint){}
		
		protected function endCarting(me:MouseEvent = null){
			gv.dlog("UI.passTurnHandler");
			passBlock();
			var _e:GameEvent = new GameEvent(GameEvent.ON_EFFECT_CART_END);
			dispatchEvent(_e);
		}
		
		public function clickCard(_id:uint, _or:uint=1){
			gv.dlogInt("Interface dispatching clickCard Event "+_id+"-"+_or);
			var _evt:GameEvent = new GameEvent(GameEvent.ON_CARD_CLICK);
			_evt.id = _id;
			_evt.choice = _or;
			dispatchEvent(_evt);
		}		
		
		protected function passTurnHandler(me:MouseEvent = null){
			gv.dlogInt("UI.passTurnHandler");
			passBlock();
			var _e:GameEvent = new GameEvent(GameEvent.ON_TURN_PASS);
			dispatchEvent(_e);
		}
	}
	
}
