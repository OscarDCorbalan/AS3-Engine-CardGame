package as3.presentation.interfaces.widgets  {
	import flash.display.MovieClip;
	import as3.presentation.cards.Card;
	
	public class UIWidgetCards extends MovieClip{
		protected var cards:Array;
		protected var i:int;
		
		public function UIWidgetCards() {
			// constructor code
		}

		public function init(a:Array){
			if(cards != null) removeCards();
			cards = a;
		}
		protected function removeCards(){
			while (numChildren > 0) {
				removeChildAt(0);
			}
			for(i = 0; i < cards.length; i++){
				(cards[i] as Card).resetInTown();
			}
				
			
		}
		
	}
	
}
