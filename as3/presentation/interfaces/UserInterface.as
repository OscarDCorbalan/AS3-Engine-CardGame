package as3.presentation.interfaces {	
	import as3.domain.GameEvent;
	import as3.domain.Table;
	import as3.presentation.CardEvent;
	import as3.presentation.cards.Card;
	import as3.presentation.interfaces.widgets.*;
	import as3.Registry;
	import flash.display.MovieClip;	
	import flash.display.SimpleButton;
	import flash.events.Event;
	import lib.Helpers;	
	import flash.events.MouseEvent;	
	import fl.controls.Button;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import as3.domain.GameVars;
	
	public class UserInterface extends Interface{
		
		//widgets
		protected var enemyStats:UIPlayerStats = new UIPlayerStats();
		protected var playerStats:UIPlayerStats = new UIPlayerStats();		
		
		protected var enemyGround:UIGround = new UIGround();
		protected var eline:UIEventLine = new UIEventLine();		
		protected var playerGround:UIGround = new UIGround();
		protected var hand:UIHand = new UIHand();
		
		protected var pass:PassTurn = new PassTurn();
		
		protected var town:UITown = new UITown();		
		
		protected var blockUI:WaitingClip = new WaitingClip();
		protected var blockUI_Hand:OnlyHand = new OnlyHand();
		protected var blockUI_Town:OnlyTown = new OnlyTown();
		protected var blockUI_Events:OnlyEventLine = new OnlyEventLine();
		protected var blockUI_Reuse:ReuseMode = new ReuseMode();
		
		protected var buyingCart:BuyingCart = new BuyingCart();
		protected var textCart:TextField = new TextField();
		protected var tFormat:TextFormat = 
			new TextFormat("Arial",20,null,null,null,null,null,null,TextFieldAutoSize.CENTER);
		
		//cards
		
		public function UserInterface(_gv:GameVars) {			
			super(_gv);
			Registry.screenLog.appendText("UI - being instantiated\n");
			trace("Initiating UI");
			
			//add childs
			Helpers.addMCat(enemyStats,0,0,this);
			Helpers.addMCat(Registry.screenLog,5,85,this);
			Helpers.addMCat(town,0,293,this);
			Helpers.addMCat(playerStats,0,688,this);
			
			Helpers.addMCat(enemyGround,285,0,this);
			Helpers.addMCat(pass,290,234,this);
			Helpers.addMCat(eline,335,234,this);
			Helpers.addMCat(playerGround,285,390,this);
			Helpers.addMCat(hand,285,618,this);	
			
			Helpers.addMCat(new UIAdorno(),0,0,this);
			
			Helpers.initTextField(textCart,"0",10,65,20,20,tFormat,buyingCart);
			
			passBlock();
			mouseBlock();		
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);			
		}
		
		protected function cardClickHandler(e:CardEvent){
			//var w:int = ;
			gv.dlog("UI.cardClickHandler");
			clickCard(e.cardID,e.cardOR);
		}
		
		private function addedToStageHandler(e:Event):void{
			gv.dlog("UI " + stage + "\n");
			Registry.stage = stage;
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(CardEvent.ON_CLICK, cardClickHandler);
			pass.addEventListener(MouseEvent.CLICK, passTurnHandler);
		}
		
		override public function update(){
			gv.dlog("Updating UI");
			//trace("UI.update");
			town.displayCards();
			//trace("UI.update 2");
			hand.displayCards();
			//trace("UI.update 3");
			enemyGround.displayCards(false);
			//trace("UI.update 4");
			eline.displayCards();
			//trace("UI.update 5");
			playerGround.displayCards();
			enemyStats.update();
			//trace("UI.update 7");
			playerStats.update();
			
		}
		
		override public function setTable(t:Table){
			//table=t;
			Registry.screenLog.appendText("UI - loading the table\n");
			
			town.init(t.getTownCards());
			town.displayCards();
			Registry.screenLog.appendText("UI - town ready\n");
			
			hand.init(t.getPlayerCards());
			hand.displayCards();
			Registry.screenLog.appendText("UI - hands ready\n");
			
			eline.init(t.getEventLine());
			eline.displayCards();			
			Registry.screenLog.appendText("UI - event line ready\n");
			
			playerGround.init(t.getPlayerGround());
			enemyGround.init(t.getOpponentGround());
			
			enemyStats.init(t.getOpponentStats());
			playerStats.init(t.getPlayerStats());		
				
		}
		
		override public function mouseBlock(){
			addChild(blockUI);
		}
		
		override public function mouseUnblock(unused:int = 0){
			removeChild(blockUI);
		}
		
		override public function passBlock(){
			pass.alpha = 0;
			pass.enabled = false;
			pass.mouseEnabled = false;
		}
		
		override public function passUnblock(){
			pass.alpha = 1;
			pass.enabled = true;
			pass.mouseEnabled = true;
		}
		
		override public function allowOnlyHand(b:Boolean){
			armc(b, blockUI_Hand);
		}
		
		override public function allowOnlyEvents(b:Boolean){
			armc(b, blockUI_Events);
		}
		
		override public function reuseMode(b:Boolean){
			armc(b, blockUI_Reuse);
		}
		
		override public function allowOnlyTown(b:Boolean){
			armc(b, blockUI_Town);
		}
		
		public function endCartingHandler(e:MouseEvent){
			endCarting();
		}
		
		override public function carting(b:Boolean,left:uint){
			gv.dlog("UI.carting " + b);
			if(b){
				if(contains(pass)){
					gv.dlog("  removing pass");
					removeChild(pass);
					buyingCart.addEventListener(MouseEvent.CLICK, endCarting);
				}
								   
				//addChildAt(buyingCart, this.getc
				Helpers.addMCat(buyingCart, 290, 234, this);
				Helpers.initTextField(textCart,left.toString(),0,62,40,20,tFormat,buyingCart);
			}
			else{
				buyingCart.removeEventListener(MouseEvent.CLICK, endCartingHandler);
				removeChild(buyingCart);
				addChild(pass);
				Helpers.addMCat(pass, 290, 234, this);
				passUnblock();
			}
		}
		
		protected function armc(ar:Boolean, mc:MovieClip){
			if(ar) addChild(mc);
			else if(contains(mc)){
				removeChild(mc);
			}
			else throw new Error("UI.armc - trying to remove hover without adding it previously");
		}
	}
	
}
