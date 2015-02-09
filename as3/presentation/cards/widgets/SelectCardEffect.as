package as3.presentation.cards.widgets {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.GradientType; 
	import flash.display.SpreadMethod;
	import flash.display.InterpolationMethod;
	import flash.geom.Matrix; 
	import as3.Registry;
	import lib.Helpers;
	import as3.presentation.cards.Card;
	
	public class SelectCardEffect extends MovieClip{
		protected var s1:Sprite;
		protected var s2:Sprite;
		//protected var bc:ButtonCancel;
		protected var callback:as3.presentation.cards.Card;
		protected const boxWidth:Number = 435; 
		protected const boxHeight:Number = 110; 
		protected const boxX:Number = 295; 
		
		public function SelectCardEffect() {
		}
		
		public function init(_s1:Sprite, _s2:Sprite, _m:as3.presentation.cards.Card){
			s1 = _s1;
			s2 = _s2;
			callback = _m;
			initSprite(s1,220);
			initSprite(s2,358);			
			//initButtonCancel();
			Registry.stage.addChild(this);
		}
		
		/*protected function initButtonCancel(){
			bc = new ButtonCancel();			
			bc.width = 40;
			bc.height = 40;
			Helpers.addMCat(bc,750,170,this);
			bc.addEventListener(MouseEvent.CLICK, closeHandler);			
		}*/
		
		/*protected function closeHandler(e:MouseEvent = null){
			destroy();
			callback.confirmOR(0);
		}*/
		
		protected function destroy(){
			Registry.stage.removeChild(this);
			removeSprite(s1);
			removeSprite(s2);
			//bc.removeEventListener(MouseEvent.CLICK, closeHandler);		
			//removeChild(bc);
		}
		
		protected function initSprite(s:Sprite, yy:uint){
			addChild(s);
			s.alpha = 0.33;
			s.height = 90;
			s.y = yy;
			s.scaleX = s.scaleY;
			s.x = 512 - s.width*0.5	
			s.buttonMode = true;
			s.mouseEnabled = true;
			s.addEventListener(MouseEvent.MOUSE_OVER, boxOverHandler);
			s.addEventListener(MouseEvent.MOUSE_OUT, boxOutHandler);
			s.addEventListener(MouseEvent.CLICK, boxClickHandler);
		}

		protected function removeSprite(s:Sprite){
			s.removeEventListener(MouseEvent.MOUSE_OVER, boxOverHandler);
			s.removeEventListener(MouseEvent.MOUSE_OUT, boxOutHandler);
			s.removeEventListener(MouseEvent.CLICK, boxClickHandler);
			removeChild(s);
		}
		
		protected function boxOverHandler(e:MouseEvent){
			trace("over");
			e.target.alpha = 1;
		}
		
		protected function boxOutHandler(e:MouseEvent){
			trace("out");
			e.target.alpha = 0.33;
		}
		
		protected function boxClickHandler(e:MouseEvent){
			destroy();
			if(e.target.y == s1.y) callback.confirmOR(1);
			if(e.target.y == s2.y) callback.confirmOR(2);
			
		}

	}
	
}
