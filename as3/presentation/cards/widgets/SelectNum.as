package as3.presentation.cards.widgets {
	import as3.Registry;	
	import as3.domain.GameEvent;
	import as3.presentation.cards.Card;
	import lib.Helpers;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.GradientType; 
	import flash.display.SpreadMethod;
	import flash.display.InterpolationMethod;
	import flash.geom.Matrix; 	
	import fl.controls.NumericStepper;	
	
	public class SelectNum extends MovieClip{
		protected var s:Sprite;
		protected var bo:ButtonOK;
		protected var cardID:uint;
		protected var ns:NumericStepper;
		protected const boxWidth:Number = 435; 
		protected const boxHeight:Number = 110; 
		protected const boxX:Number = 295; 
		
		public function SelectNum(){}
		
		public function init(_m:as3.presentation.cards.Card, u:uint){
			s = _m.getPreSymbol();
			cardID = _m.getID();
			//callback = _m;
			initSprite();
			initButtonOK();
			initStepper(u);
			Registry.stage.addChild(this);
		}
		
		protected function initSprite(){
			addChild(s);
			s.height = 50;
			s.y = 359;
			s.scaleX = s.scaleY;
			s.x = 460;
		}

		protected function initButtonOK(){
			bo = new ButtonOK();			
			bo.width = 50;
			bo.height = 50;
			Helpers.addMCat(bo,580,359,this);
			bo.addEventListener(MouseEvent.CLICK, okHandler);			
		}
		
		protected function initStepper(_u:uint){
			ns = new NumericStepper();		
			Helpers.addMCat(ns,400,374,this);
			ns.width = 40;
			ns.height = 20;
			ns.minimum = 1;
			ns.maximum = _u;
			ns.stepSize = 1;
		}

		protected function okHandler(e:MouseEvent){
			var _e:GameEvent = new GameEvent(GameEvent.ON_PRE_CHOICE);
			_e.id = cardID;
			_e.choice = ns.value;
			dispatchEvent(_e);
			destroy();			
		}

		protected function destroy(){
			Registry.stage.removeChild(this);
			removeChild(s);
			removeChild(bo);
			removeChild(ns);
			bo.removeEventListener(MouseEvent.CLICK, okHandler);			
		}

	}
	
}
