package as3.presentation.interfaces.widgets {
	import as3.Constants;
	import as3.Registry;
	import flash.display.MovieClip;
	import as3.presentation.cards.Card;

	public class UIHand extends UIWidgetCards{
		protected var xx:int, yy:int, w:Number, h:Number;
		protected const displayWidth:int = 100;
		protected const totalWidth:int = 739-displayWidth-10;
		
		
		public function UIHand() {
			trace("Initiating UI-hand");
		}
		
		public function displayCards(){
			xx = 5;
			yy = 5;
			w = displayWidth / Constants._CardWidth;
			removeCards();
			if(cards.length > 4){
				for(i = 0; i < cards.length; i++){
					addChild(cards[i]);
					cards[i].x = xx;
					cards[i].y = yy;	
					cards[i].scaleX = w;
					cards[i].scaleY = w;
					xx += totalWidth/(cards.length-1);
				}
			}
			else{
				for(i = 0; i < cards.length; i++){
					addChild(cards[i]);
					cards[i].x = xx;
					cards[i].y = yy;	
					cards[i].scaleX = w;
					cards[i].scaleY = w;
					xx += displayWidth + 10;
				}
			}
			
			
		}

	}
	
}
