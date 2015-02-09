package as3.presentation.cards{
	import lib.Helpers;
	import flash.display.MovieClip;
	import fl.motion.Color;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class GameCard extends Card {
		//instance variables
		protected var ini:int;		
		
		//instance child UI elements
		protected var tfIni:TextField = new TextField();
		

		public function GameCard(){
			super();
		}
		
		public function init2(_id:uint, _nm:String, _color:uint, _ini:int, _pre:Vector.<int>,_post:Vector.<int>){		
			init(_id,_nm,_color,_pre,_post)
			ini = _ini;			
			Helpers.initTextField(tfIni, ini.toString(), 0, 2, 40, 26, tFormatBig,this);
		}
		
		public function getIni():int{return ini;}		
		public function setExtraPrice(p:uint){}
	}	
}
