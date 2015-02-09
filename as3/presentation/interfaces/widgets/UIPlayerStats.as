package as3.presentation.interfaces.widgets {
	import lib.Helpers;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import as3.domain.PlayerStats;
	
	
	public class UIPlayerStats extends MovieClip{
		protected var px:uint = 0;
		protected var hand:uint = 5;
		protected var deck:uint = 4;
		protected var discard:uint = 0;
		protected var money:uint = 0;
		protected var men:uint = 3;
		
		protected var stats:PlayerStats;
		
		protected var tfHand:TextField = new TextField();
		protected var tfDeck:TextField = new TextField();
		protected var tfDiscard:TextField = new TextField();
		protected var tfPX:TextField = new TextField();
		protected var tfMoney:TextField = new TextField();
		protected var tfMen:TextField = new TextField();
		protected static var tFormatCenterSmall:TextFormat = new TextFormat("Arial",18,null,null,null,null,null,null,TextFieldAutoSize.CENTER);
		protected static var tFormatCenter:TextFormat = new TextFormat("Arial",24,null,true,null,null,null,null,TextFieldAutoSize.CENTER);
		
		public function UIPlayerStats() {
			
		}
		
		public function init(ps:PlayerStats){
			stats = ps;
			update();
		}
		
		public function update(){
			//trace("UIPlayerStats.update");
			Helpers.initTextField(tfDeck, stats.getDeck().toString(), 
								  20, 8, 30, 25, tFormatCenterSmall, this);
			Helpers.initTextField(tfDiscard, stats.getDiscard().toString() ,//discard.toString(), 
								  20, 43, 30, 25, tFormatCenterSmall, this);
			Helpers.initTextField(tfHand, stats.getHand().toString(), 
								  87, 26, 25, 25, tFormatCenterSmall, this);			
			Helpers.initTextField(tfMen, stats.getMen().toString(), 
								  135, 38, 25, 25, tFormatCenterSmall, this);	
			Helpers.initTextField(tfMoney, stats.getMoney().toString(), 
								  171, 23, 35, 30, tFormatCenter, this);			
			Helpers.initTextField(tfPX, stats.getPX().toString(), 
								  230, 21, 35, 30, tFormatCenter, this); 
		}
		

	}
	
}
