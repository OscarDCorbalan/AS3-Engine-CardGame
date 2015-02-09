package as3.presentation.interfaces.widgets  {
	import as3.Constants;
	import flash.display.MovieClip;
	import as3.presentation.cards.Card;
	import as3.Registry;
	
	public class UITown extends UIWidgetCards{
		//somevars
		protected var xx:int, yy:int, w:Number, h:Number;
		protected const displayWidth:int = 90;
		
		public function UITown() {
			
		}
		
		public function displayCards(){			
			xx = 5;
			yy = 5;
			w = displayWidth * 1/Constants._CardWidth;
			removeCards();
			for(i = 0; i < 9; i++){
				addChild(cards[i]);
				cards[i].x = xx;
				cards[i].y = yy;				
				(cards[i] as Card).addedInTown();
				/*if((cards[i] as Card).isReserved()
				&& !(cards[i] as Card).isMine())
					cards[i].mouseEnabled = false;*/
				cards[i].scaleX = w;
				cards[i].scaleY = w;
				if(xx < (displayWidth+5)*2) 
					xx += displayWidth+3;
				else{
					xx = 5;
					yy += cards[i].height + 3; ;
				}
			}
		}
		
		
	}	
}
