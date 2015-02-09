package as3.presentation.screen {
	import lib.Helpers;
	import as3.Constants;
	import flash.display.MovieClip;
	import as3.domain.PlayerStats;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	
	
	public class EndGameScreen extends MovieClip {
		[Embed(source="/assets/Lang.xml", mimeType="application/octet-stream")]
			protected const EmbeddedXML:Class;
		protected var xml:XML = new XML();
		
		protected var tFormatSmall:TextFormat = 
			new TextFormat("Arial",28,0xFFFFFF,null,null,null,null,null,TextFieldAutoSize.LEFT);
		protected var tFormatBig:TextFormat = 
			new TextFormat("Arial",40,0xFFFFFF,true,null,null,null,null,TextFieldAutoSize.CENTER);
		 
		protected var whoWon:TextField = new TextField();
		protected var leftPlayer:TextField = new TextField();
		protected var leftPX:TextField = new TextField();
		protected var leftDragons:TextField = new TextField();
		protected var rightPlayer:TextField = new TextField();
		protected var rightPX:TextField = new TextField();
		protected var rightDragons:TextField = new TextField();
		
		protected var language:uint;
		
		public function EndGameScreen(){
			xml = Helpers.loadFromXML(EmbeddedXML);		
			whoWon.embedFonts = true;
			leftPlayer.embedFonts = true;
			leftDragons.embedFonts = true;
			rightPlayer.embedFonts = true;
			rightDragons.embedFonts = true;
		}
		
		public function init(p1:uint, d1:uint, p2:uint, d2:uint,won:Boolean,lang:uint){
			language = lang;
			if(won)	initWhoWon(translate(xml.won));  
			else	initWhoWon(translate(xml.lost));

			Helpers.initTextField(leftPlayer, translate(xml.you),
								  310,320,192,30,tFormatSmall,this);
			Helpers.initTextField(leftPX, "PX... " + p1,
								  310,370,192,30,tFormatSmall,this);
			Helpers.initTextField(leftDragons, translate(xml.dragon) + "... " + d1,
								  310,410,192,30,tFormatSmall,this);
			
			
			Helpers.initTextField(rightPlayer, translate(xml.enemy),
								  522,320,192,30,tFormatSmall,this);
			Helpers.initTextField(rightPX, "PX... " + p2,
								  522,370,192,30,tFormatSmall,this);
			Helpers.initTextField(rightDragons, translate(xml.dragon) + "... " + d2,
								  522,410,192,30,tFormatSmall,this);
		}
		
		protected function initWhoWon(t:String){
			Helpers.initTextField(whoWon,t,0,150,1024,50,tFormatBig,this);	
		}
		
		protected function translate(e:XMLList):String{
			switch(language){
				case Constants.L_ENG:
					return e.ENG.valueOf();
				case Constants.L_ESP:
					return e.ES.valueOf();
				case Constants.L_CAT:
					return e.CAT.valueOf();
				default:
					return "ERROR";
			}
		}
	}
	
}
