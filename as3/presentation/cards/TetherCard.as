package as3.presentation.cards{
	import lib.Helpers;
	import flash.display.MovieClip;
	import fl.motion.Color;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class TetherCard extends GameCard {

		public function TetherCard(){
			super();
			wide=false;
		}
		
		override public function isTether(){return true;}
		
	}	
}
