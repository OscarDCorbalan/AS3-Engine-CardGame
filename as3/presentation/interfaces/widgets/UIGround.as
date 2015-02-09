package as3.presentation.interfaces.widgets {
	import as3.Constants;
	
	public class UIGround extends UIWidgetCards {
		protected var xx:int, yy:int, w:Number, h:Number;
		protected var displayWidth:int = 80;
		protected const totalWidth:int = 739-displayWidth-10;
		
		public function UIGround() {
			// constructor code
			/*graphics.beginFill(0xff0000, 0.4);
			graphics.drawRect(0,0,totalWidth+90,240);
			graphics.endFill();*/
		}
		
		public function displayCards(clickable:Boolean = true){			
			xx = 0;
			yy = 0;
			w = displayWidth * 1/Constants._CardWidth;
			
			//trace("a");			
			removeCards();
			for(i = 0; i < cards.length; i++){				
				addChild(cards[i]);
				cards[i].mouseEnabled = clickable;
				if(xx < 739-114-5) {
					xx += 114+5;
				}
				else{
					xx = 114+5;
					yy += 80+5;
				}		
				cards[i].x = xx;
				cards[i].y = yy;				
				cards[i].scaleX = w;
				cards[i].scaleY = w;
				/*
				graphics.beginFill(0x00ff00+i*16);
				graphics.drawRect(xx,yy-20,2,150);
				graphics.endFill();
				trace(i, cards[i].getID(), cards[i].x, xx, yy);	*/
			}
			//trace("b");
		}
		
	}
	
}
