package as3 {
	import as3.Constants;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class Flag extends MovieClip{
		
		protected var current:uint;
		protected var fEsp:Flag_ESP = new Flag_ESP();
		protected var fCat:Flag_CAT = new Flag_CAT();
		protected var fUsa:Flag_US = new Flag_US();		
		
		public function Flag() {
			addEventListener(MouseEvent.CLICK, clickHandler);
			fEsp.buttonMode = true;
			fCat.buttonMode = true;
			fUsa.buttonMode = true;
			current = Constants.L_ESP;
			addChild(fEsp);
		}
		public function getLang():uint{return current;}
		
		public function destroy(){
			removeEventListener(MouseEvent.CLICK, clickHandler);
			if(contains(fEsp)) removeChild(fEsp);
			if(contains(fCat)) removeChild(fCat);
			if(contains(fUsa)) removeChild(fUsa);
			fEsp = null;
			fCat = null;
			fUsa = null;			
		}
		
		protected function clickHandler(e:MouseEvent){
			switch(current){
				case Constants.L_ESP:
					current = Constants.L_ENG;
					removeChild(fEsp);
					addChild(fUsa);
					break;
				case Constants.L_ENG:
					current = Constants.L_CAT;
					removeChild(fUsa);
					addChild(fCat);
					break;
				case Constants.L_CAT:
					current = Constants.L_ESP;
					removeChild(fCat);
					addChild(fEsp);
					break;
			}

		}

	}
	
}
