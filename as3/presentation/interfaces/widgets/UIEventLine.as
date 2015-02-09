package as3.presentation.interfaces.widgets {
	import as3.Constants;
	import as3.Registry;
	import flash.display.MovieClip;
	public class UIEventLine extends UIWidgetCards{
		protected var xx:int, yy:int, w:Number, h:Number;
		protected const displayWidth:int = 100;
		protected const totalWidth:int = 680-displayWidth-10;
		
		
		public function UIEventLine() {
			trace("Initiating UI-eventline");
		}
		/*override public function init(a:Array){
			cards = a;
			trace("Dsada", cards.length);
		}*/
		public function displayCards(){
			xx = 5;
			yy = 5;
			w = displayWidth / Constants._CardWidth;
			removeCards();
			for(i = 0; i < cards.length; i++){
				//trace("UI-eventline ", cards[i]);
				addChild(cards[i]);
				cards[i].x = xx;
				cards[i].y = yy;			
				cards[i].scaleX = w;
				cards[i].scaleY = w;
				//cards[i].alpha = 1 - i*0.1;
				xx += totalWidth/(cards.length-1);
			}
		}

	}
	
}
