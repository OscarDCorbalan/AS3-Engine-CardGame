package as3.domain {
	import as3.Constants;
	import as3.Registry;
	import as3.data.*;
	import as3.presentation.cards.widgets.SelectCardEffect;
	import as3.presentation.interfaces.*;
	
	import fl.controls.TextArea;
	import flash.utils.setTimeout;
	import flash.geom.Rectangle;
	import flash.events.TextEvent;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import as3.presentation.screen.EndGameScreen;
	
	public class Engine{
		protected var gv:GameVars = new GameVars();
		protected var ui:Interface;
		protected var table:Table;
		protected var sl:SocketLord;
		
		protected var startedLastPlan:Boolean = false;
		
		var numPreMax:uint;
		var numPreActions:uint;
		var numPreMult:uint = 1;
		var preType:uint;
		var diffAI:Boolean;
		var lang:uint;
		
		public function Engine(_lang:uint, _h:Boolean, _hard:Boolean = false){
			lang = _lang;
			gv.debug = false;
			diffAI =_hard;
			gv.isHuman = _h;
			initScreenLog();
			sl = new SocketLord(gv);				
			gv.selectEffect = new SelectCardEffect();
			gv.selectEffect.x = 0;
			gv.selectEffect.y = 0;
			gv.selectNum = new SelectNum();
			gv.selectNum.x = 0;
			gv.selectNum.y = 0;
			
			sl.addEventListener(RemoteEvent.ON_SEED_READY, connected);		
		}
		
		public function connected(e:RemoteEvent){
			//we can set up the game
			sl.removeEventListener(RemoteEvent.ON_SEED_READY, connected);
			var _u:uint = uint(e.eventMessage);
			gv.playerNum = e.id;
			table = new Table(gv, _u, lang);
			
			if(gv.isHuman){
				ui = new UserInterface(gv);
				Registry.stage.addChild(ui);
			}
			else{
				ui = new AIInterface(gv, diffAI);
				
			}
			ui.setTable(table);									
			ui.addEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler);
			table.addEventListener(GameEvent.ON_WIN, winHandler);
			waitOpponentEvents(true);
			sl.readyToStart();
		}
		
		protected function initScreenLog(){
			Registry.screenLog = new TextArea();					
			Registry.screenLog.width = 275;
			Registry.screenLog.height = 208;
			Registry.screenLog.editable = false;
			Registry.screenLog.addEventListener(Event.EXIT_FRAME,Registry.screenLogAutoscroll);			
		}
		
		protected function winHandler(e:GameEvent){	
			gv.dlog("Engine.winHandler "+e.u1);
			sl.won(e.u3, e.u4, e.u1, e.u2, (e.id+1)%2);
			showEndGameScreen(e);   														  
		}

		protected function showEndGameScreen(e:GameEvent){
			waitOpponentEvents(false);
			cardClickListeners(false);
			//sl.destroy();
			var egs:EndGameScreen = new EndGameScreen();			
			egs.init(e.u1, e.u2, e.u3, e.u4, e.id == 1, lang);
			Registry.stage.addChild(egs);	
		}
		
		protected function turnSync(e:RemoteEvent){
			gv.dlog("Engine.turnSync");
			table.before(false,false);
			table.playCard(e.id, e.choice);
			table.after();
			ui.update();
		}
				
		protected function turnSyncBuy(e:RemoteEvent){
			gv.dlog("Engine.turnSyncBuy");
			table.before(false,false);
			table.cartCard(e.id);
			table.payMoney(e.num);
			table.after();
			ui.update();
		}
		protected function turnSyncNulltown(e:RemoteEvent){
			gv.dlog("Engine.turnSyncNulltown");
			table.before(false,false);
			table.nulltown(e.id);
			table.after();
			ui.update();
		}
		protected function turnSyncSaveHand(e:RemoteEvent){
			gv.dlog("Engine.turnSyncSaveHand");
			table.before(false,false);
			table.saveHand(e.id);
			table.after();
			ui.update();
		}
		protected function turnSyncPre(e:RemoteEvent){
			gv.dlog("Engine.turnSyncPre");
			table.before(false,false);
			//table.playCard(e.id, e.choice);
			//table.after();
			switch(uint(e.eventMessage)){
				case Constants.V_MONEY: 
					table.payMoney(e.choice);
					break;
				case Constants.V_FOLLOWER:
					gv.dlog("TODO Engine.turnSyncPre->follower");
					table.payFollower(e.choice);
					break;
				default:
					throw new Error("Engine.turnSyncPre - " + e.eventMessage + " " + uint(e.eventMessage));
			}
			table.addExtraPX(e.id);
			table.setDelayedPostCard(e.id);
			table.resumePost(e.choice);			
			table.after();				
			ui.update();
		}
		
		protected function turnSyncPreStart(e:RemoteEvent){
			gv.dlog("Engine.turnSyncPreStart");
			table.before(false,false);
			table.addExtraPX(e.id);
			table.setDelayedPostCard(e.id); //--> look post in opponent hand??
			table.after();
		}
		protected function turnSyncPreEnd(e:RemoteEvent){
			gv.dlog("Engine.turnSyncPreEnd");
			turnSyncPreClick(e);			
			table.before(false,false);
			table.resumePost(e.num);			
			table.after();				
			ui.update();
		}
		protected function turnSyncPreClick(e:RemoteEvent){
			gv.dlog("Engine.turnSyncPreClick");
			table.before(false,false);
			switch(e.choice){
				case Constants.V_DISCARD: table.disCard(e.id); break;
				case Constants.V_GARBAGE: table.garbageCard(e.id); break;
				default: throw new Error("Engine.turnSyncPreClick - default case");
			}
			table.after();
			ui.update();
		}		
		
		protected function cardClickHandler(e:GameEvent){			
			gv.dlog("Engine.cardClickHandler " +e.id);
			cardClickListeners(true);			
			table.playCard(e.id,e.choice);
		}
		
		protected function cardClickConfirmHandler(e:GameEvent = null){			
			gv.dlog("Engine.cardClickConfirmHandler");
			cardClickListeners(false);						
			if(e != null) sl.playCard(e.id,e.choice);
			table.after();
			ui.update();
		}
		
		protected function cardClickCantHandler(e:GameEvent = null){		
			gv.dlog("Engine.cardClickCantHandler");
			gv.log("Can't do that");
			cardClickListeners(false);			
		}
		
		protected function townReservedHandler(e:GameEvent){
			gv.dlog("Engine.townReservedHandler");
			gv.log("Town reserved");
			ui.passUnblock();
		}
		
		
		protected function cardPreHandler(e:GameEvent){
			gv.dlog("Engine.cardPreHandler");
			cardClickListeners(false);
			preType = e.id;
			numPreMax = e.choice;
			if(gv.isHuman)
				gv.selectNum.addEventListener(GameEvent.ON_PRE_CHOICE, cardPreChoiceHandler);
			else
				ui.addEventListener(GameEvent.ON_PRE_CHOICE, cardPreChoiceHandler);
		}

		protected function cardPreChoiceHandler(e:GameEvent){			
			gv.dlog("Engine.cardPreChoiceHandler");
			if(preType == Constants.V_FOLLOWER){
				gv.dlog(" pre is follower --> resume");
				gv.log("Paying " +e.choice +" followers");
				table.payFollower(e.choice);
				table.resumePost(e.choice);
				table.after();
				sl.playCardPre(e.id, e.choice, Constants.V_FOLLOWER);
				cardClickListeners(true);
			}
			else if(preType == Constants.V_MONEY){		
				gv.dlog(" pre is money --> resume");
				gv.log("Paying " +e.choice +" coins");
				table.payMoney(e.choice);
				table.resumePost(e.choice);
				table.after();
				sl.playCardPre(e.id, e.choice, Constants.V_MONEY);
				cardClickListeners(true);
			}
			else{
				sl.playCardPreStart(e.id);
				numPreMax = e.choice;			
				numPreActions = 0;
				ui.allowOnlyHand(true);			
				ui.removeEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler);
				
				switch(preType){
					case Constants.V_DISCARD:
						gv.log("Discarding " +e.choice +" cards");
						ui.addEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler_Discard);
						break;
					case Constants.V_GARBAGE:
						gv.log("Removing from game " +e.choice +" cards");
						ui.addEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler_Garbage);
						break;
					default:
						throw new Error("cardPreChoiceHandler - switch error: " + preType);
				}
			}
			cardClickConfirmHandler();			
			gv.blocked = false;
		}
		
		protected function cardClickHandler_Discard(e:GameEvent){//PRE
			gv.dlog("Engine.cardClickHandler_Discard");
			table.disCard(e.id);
			if(!updatePreParams())
				sl.playCardPreClick(e.id, Constants.V_DISCARD);
			else
				sl.playCardPreEnd(e.id, Constants.V_DISCARD, numPreActions);
			gv.blocked = false;			
		}	
		
		protected function cardClickHandler_Garbage(e:GameEvent){ //PRE
			gv.dlog("Engine.cardClickHandler_Garbage");
			table.garbageCard(e.id);
			if(!updatePreParams())
				sl.playCardPreClick(e.id, Constants.V_GARBAGE);
			else
				sl.playCardPreEnd(e.id, Constants.V_GARBAGE, numPreActions);
			gv.blocked = false;
		}
		
		protected function effectCartHandler(e:GameEvent){
			gv.dlog("Engine.effectCartHandler");
			gv.modeCart = true;
			ui.allowOnlyEvents(true);
			ui.carting(true,e.num);
			numPreMax = e.num;
			numPreActions = 0;			
			ui.addEventListener(GameEvent.ON_EFFECT_CART_END, cardClickHandler_CartEnd);
			ui.removeEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler);
			ui.addEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler_Cart);
			gv.blocked = false;
			//BC WE SHUT THE CONFIRM HANDLER
			//sl.playCard(e.id,0);
		}
		
		protected function effectDoubleUseHandler(e:GameEvent){ 
			gv.dlog("Engine.effectDoubleUseHandler");
			reuseMode(true);
			ui.removeEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler);
			ui.addEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler_Reuse);
			gv.blocked = false;
			//BC WE SHUT THE CONFIRM HANDLER
			//sl.playCard(e.id,0);
		}
				
		protected function effectNulltownHandler(e:GameEvent){
			gv.dlog("Engine.effectNulltownHandler");
			gv.modeTown = true;
			ui.allowOnlyTown(true);
			numPreMax = 1;
			numPreActions = 0;		
			ui.removeEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler);
			ui.addEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler_Nulltown);
		}
		
		protected function effectSaveHandHandler(e:GameEvent){
			gv.dlog("Engine.effectSaveHandHandler");
			ui.allowOnlyHand(true);
			gv.modeSaveHand = true;
			ui.removeEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler);
			ui.addEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler_SaveHand);
		}
		
		protected function cardClickHandler_SaveHand(e:GameEvent){
			gv.dlog("Engine.cardClickHandler_SaveHand");			
			table.saveHand(e.id);
			sl.saveHand(e.id);
			ui.removeEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler_SaveHand);
			ui.addEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler);		
			gv.modeSaveHand = false;
			ui.allowOnlyHand(false);		
			ui.update();
		}		
		
		protected function cardClickHandler_CartEnd(e:GameEvent){ //POST
			gv.dlog("Engine.cardClickHandler_CartEnd " + e.id);
			
			ui.allowOnlyEvents(false);
			ui.carting(false, 0)
			gv.modeCart = false;
			ui.removeEventListener(GameEvent.ON_EFFECT_CART_END, cardClickHandler_CartEnd);
			ui.removeEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler_Cart);
			ui.addEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler);
			ui.update();
		}
		
		protected function cardClickHandler_Cart(e:GameEvent){ //POST
			gv.dlog("Engine.cardClickHandler_Cart " + e.id);
			if(!table.cartCard(e.id)) return;
			numPreActions++;			
			sl.buyCard(e.id);
			if(numPreActions > numPreMax) throw new Error("Engine.cardClickHandler_Cart - overflow");
			if(numPreActions == numPreMax){	
				ui.carting(false, 0)
				ui.allowOnlyEvents(false);
				gv.modeCart = false;
				ui.removeEventListener(GameEvent.ON_EFFECT_CART_END, cardClickHandler_CartEnd);
				ui.removeEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler_Cart);
				ui.addEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler);
			}
			else{
				ui.carting(true, numPreMax - numPreActions);
			}
			ui.update();
		}
		
		protected function cardClickHandler_Nulltown(e:GameEvent){
			gv.dlog("Engine.cardClickHandler_Nulltown");
			numPreActions++;
			table.nulltown(e.id);
			sl.nulltown(e.id);
			if(numPreActions > numPreMax) throw new Error("Engine.cardClickHandler_Cart - overflow");
			if(numPreActions == numPreMax){
				ui.removeEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler_Nulltown);
				ui.addEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler);			
				ui.allowOnlyTown(false);	
				gv.modeTown = false;
			}			
			ui.update();
		}		
		
		protected function cardClickHandler_Reuse(e:GameEvent){ //POST
			gv.dlog("Engine.cardClickHandler_Reuse " + e.id);				
			cardClickHandler(e);
			reuseMode(false);
			ui.removeEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler_Reuse);
			ui.addEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler);			
			ui.update();
		}
		
		protected function updatePreParams():Boolean{
			var preFinished:Boolean = false;
			numPreActions++;
			if(numPreActions > numPreMax) throw new Error("Engine.updatePreParams - overflow");
			if(numPreActions == numPreMax){
				ui.removeEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler_Discard);
				ui.removeEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler_Garbage);
				ui.addEventListener(GameEvent.ON_CARD_CLICK, cardClickHandler);
				cardClickListeners(false);
				ui.allowOnlyHand(false);
				
				table.resumePost(numPreMax);
				table.after();								
				preFinished = true;
			}			
			ui.update();
			return preFinished;
		}
				
		protected function turnPlanStart1(e:RemoteEvent){
			Registry.log("Planification phase");
			gv.dlog("PLAN-1 phase started");					
			gv.currentPhase = Constants.PH_PLAN;
			table.before();
			ui.mouseUnblock(Constants.PH_PLAN);
			ui.allowOnlyHand(true);
			gv.dlog("Pick a card to check who starts");	
			ui.update();
		}
		
		protected function turnPlanStart2(e:RemoteEvent){
			Registry.log("Planification phase");
			gv.dlog("PLAN-2 phase started");		
			gv.dlog("Pick a card to check who starts");	
			gv.currentPhase = Constants.PH_PLAN;
			table.before(false,false);
			table.playCard(e.id);
			table.after();			
			table.before();
			ui.mouseUnblock(Constants.PH_PLAN);
			ui.allowOnlyHand(true);
			//ui.update();
		}
		
		protected function turnPlanEnd(e:GameEvent){
			ui.allowOnlyHand(false);
			ui.mouseBlock();
			gv.dlog("PLAN phase finished");	
			//TODO: NO BEFORE CALLED?
			table.after();	
			ui.update();
			
			sl.endPlan(e.id,uint(e.eventMessage));	
			
			if(gv.playerNum == 1){
				gv.dlog(" state = PH_PLAN_SYNC");	
				gv.currentPhase = Constants.PH_PLAN_SYNC;				
			}
			if(gv.playerNum == 2){
				gv.dlog(" state = PH_WAIT");	
				gv.currentPhase = Constants.PH_WAIT;
				checkPhaseInis();			
			}
		}
		
		protected function turnPlanSync(e:RemoteEvent){
			gv.dlog("Engine.turnPlanSync");
			
			table.before(false,false);
			table.playCard(e.id);
			table.after();
			ui.update();
			sl.endPlan(0,0);			
			checkPhaseInis();
		}
				
		protected function checkPhaseInis(){
			gv.dlog("Engine.checkPhaseInis - started last turn? " +startedLastPlan);		
			turnPlanListeners(false);
			gv.currentPhase = Constants.PH_TURN;
			
			var _r:int = table.getPhaseIni();
			if(_r > 0 || (_r == 0 && !startedLastPlan)){
				turnStart();
				startedLastPlan = true;
			}
			else if ( _r < 0 || (_r == 0 && startedLastPlan)){				
				gv.dlog("OPPONENT's TURN started");
				waitOpponentEvents(true);
				startedLastPlan = false;
			}
			else throw new Error("Engine.checkPhaseInis " +_r+", "+startedLastPlan);
		}

		protected function turnStart(e:RemoteEvent = null){
			Registry.logSeparator();
			if(gv.isHuman) Registry.log("Your turn starts...");
			gv.dlog("Checking turn start");
			
			if(e != null && e.eventMessage != null && e.eventMessage == "First"){
				gv.dlog("  first");
				startedLastPlan = true;
				ui.update();
			}else{
				if(Registry.rules.isJourneyFinished(table.getTownCards(),
													table.getPlayerStats(),
													table.getOpponentStats())){
					gv.dlog("  if ijf");
					endJourney();
					Registry.logSeparator();
					//Registry.log("Journey finished");
					return;
				}else{
					if(!Registry.rules.canStartTurn(table.getPlayerStats())){
						gv.dlog("  else cst");
						table.turnEnd();
						return;
					}
						
				}
			}
			gv.dlog(  "your turn started " + gv.playerNum);
					
			waitOpponentEvents(false);
			table.turnEnd();
			ui.update();			
			table.before();
			ui.mouseUnblock();
			ui.passBlock();
			ui.addEventListener(GameEvent.ON_TURN_PASS, turnEndHandler);
		}
		
		protected function turnEndHandler(e:GameEvent = null){
			gv.dlog("Engine.turnEndHandler");
			Registry.logSeparator();
			if(gv.isHuman) Registry.log("Opponent's turn starts...");
			ui.removeEventListener(GameEvent.ON_TURN_PASS, turnEndHandler);
			ui.mouseBlock();
			table.after();
			table.turnEnd();
			
			cardClickListeners(false);
			var _p1:PlayerStats = table.getPlayerStats();
			var _p2:PlayerStats = table.getOpponentStats();
			
			//Registry.gvdlog(gv.playerNum +" " + gv.isHuman + " " + Registry.rules.canStartTurn_DUM(_p1, _p2));
			if(Registry.rules.canStartTurn(_p2)){				
				waitOpponentEvents(true);
				sl.endTurn();
			}
			else{
				if(Registry.rules.canStartTurn(_p1)){
					gv.dlog("   canIStartTurn");
					turnStart();
					sl.endTurn();
				}
				else{//end Journey
					gv.dlog("   end Journey");
					endJourney();
				}			
			}
			ui.update();
			//else throw new Error("Engine.turnEndHandler - my logic is flawed");
		}
		
		protected function endJourney(){
			gv.dlog("Engine.endJourney");
			table.endJourney();
			ui.update();
			turnPlanListeners(true);				
			sl.journeyEnd();
		}
		
		protected function turnPlanListeners(b:Boolean){
			if(b){
				sl.addEventListener(RemoteEvent.ON_TURN_PLAN_1, turnPlanStart1);
				sl.addEventListener(RemoteEvent.ON_TURN_PLAN_2, turnPlanStart2);
				sl.addEventListener(RemoteEvent.ON_TURN_PLAN_SYNC, turnPlanSync);
				table.addEventListener(GameEvent.ON_TURN_PLAN_END, turnPlanEnd);
			}else{
				sl.removeEventListener(RemoteEvent.ON_TURN_PLAN_1, turnPlanStart1);
				sl.removeEventListener(RemoteEvent.ON_TURN_PLAN_2, turnPlanStart2);
				sl.removeEventListener(RemoteEvent.ON_TURN_PLAN_SYNC, turnPlanSync);
				table.removeEventListener(GameEvent.ON_TURN_PLAN_END, turnPlanEnd);			
			}
		}
		
		
		protected function cardClickListeners(_on:Boolean){
			gv.dlog("Engine.cardClickListeners "+ _on + " " + gv.currentPhase);
			if(_on && gv.currentPhase != Constants.PH_PLAN){
				table.addEventListener(GameEvent.ON_TOWN_RESERVE, townReservedHandler);
				table.addEventListener(GameEvent.ON_CARD_CLICK_CONFIRM, cardClickConfirmHandler);
				table.addEventListener(GameEvent.ON_CARD_CLICK_CANT, cardClickCantHandler);
				table.addEventListener(GameEvent.ON_PRE, cardPreHandler);
				table.addEventListener(GameEvent.ON_EFFECT_CART, effectCartHandler);
				table.addEventListener(GameEvent.ON_EFFECT_DOUBLE_USE, effectDoubleUseHandler);
				table.addEventListener(GameEvent.ON_EFFECT_NULLTOWN, effectNulltownHandler);
				table.addEventListener(GameEvent.ON_EFFECT_SAVE_HAND, effectSaveHandHandler);			
			}
			else{
				table.removeEventListener(GameEvent.ON_TOWN_RESERVE, townReservedHandler);
				table.removeEventListener(GameEvent.ON_CARD_CLICK_CONFIRM, cardClickConfirmHandler);
				table.removeEventListener(GameEvent.ON_CARD_CLICK_CANT, cardClickCantHandler);
				table.removeEventListener(GameEvent.ON_PRE, cardPreHandler);
				table.removeEventListener(GameEvent.ON_EFFECT_CART, effectCartHandler);
				table.removeEventListener(GameEvent.ON_EFFECT_DOUBLE_USE, effectDoubleUseHandler);
				table.removeEventListener(GameEvent.ON_EFFECT_NULLTOWN, effectNulltownHandler);
				table.removeEventListener(GameEvent.ON_EFFECT_SAVE_HAND, effectSaveHandHandler);	
			}
			
		}
		
		protected function waitOpponentEvents(b:Boolean){
			gv.dlog("waitOpponentEvents " + b);
			if(b){
				sl.addEventListener(RemoteEvent.ON_TURN_START, turnStart);
				//direct effects
				sl.addEventListener(RemoteEvent.ON_TURN_SYNC, turnSync);
				//effects that require actions
				sl.addEventListener(RemoteEvent.ON_TURN_SYNC_BUY, turnSyncBuy);
				sl.addEventListener(RemoteEvent.ON_TURN_SYNC_REUSE, turnSyncReuse);
				sl.addEventListener(RemoteEvent.ON_TURN_SYNC_NULLTOWN, turnSyncNulltown);
				sl.addEventListener(RemoteEvent.ON_TURN_SYNC_SAVE_HAND, turnSyncSaveHand);	
				//effects that require previous selections
				sl.addEventListener(RemoteEvent.ON_TURN_SYNC_PRE, turnSyncPre);
				sl.addEventListener(RemoteEvent.ON_TURN_SYNC_PRE_START, turnSyncPreStart);
				sl.addEventListener(RemoteEvent.ON_TURN_SYNC_PRE_CLICK, turnSyncPreClick);
				sl.addEventListener(RemoteEvent.ON_TURN_SYNC_PRE_END, turnSyncPreEnd);		
				//game won
				sl.addEventListener(GameEvent.ON_WIN, showEndGameScreen);
							
			}
			else{
				sl.removeEventListener(RemoteEvent.ON_TURN_START, turnStart);
				sl.removeEventListener(RemoteEvent.ON_TURN_SYNC, turnSync);
				sl.removeEventListener(RemoteEvent.ON_TURN_SYNC_BUY, turnSyncBuy);
				sl.removeEventListener(RemoteEvent.ON_TURN_SYNC_REUSE, turnSyncReuse);
				sl.removeEventListener(RemoteEvent.ON_TURN_SYNC_NULLTOWN, turnSyncNulltown);
				sl.removeEventListener(RemoteEvent.ON_TURN_SYNC_SAVE_HAND, turnSyncSaveHand);
				sl.removeEventListener(RemoteEvent.ON_TURN_SYNC_PRE, turnSyncPre);
				sl.removeEventListener(RemoteEvent.ON_TURN_SYNC_PRE_START, turnSyncPreStart);
				sl.removeEventListener(RemoteEvent.ON_TURN_SYNC_PRE_CLICK, turnSyncPreClick);
				sl.removeEventListener(RemoteEvent.ON_TURN_SYNC_PRE_END, turnSyncPreEnd);
				sl.removeEventListener(GameEvent.ON_WIN, showEndGameScreen);
			}
		}
		
		
		protected function turnSyncReuse(e:RemoteEvent){
			if(e.eventMessage == "0000") gv.modeReuse = false;
			if(e.eventMessage == "0001") gv.modeReuse = true;
		}
		protected function reuseMode(b:Boolean){
			gv.dlog("Engine.reuseMode " +b);
			gv.modeReuse = b;
			ui.reuseMode(b);
			sl.reuseMode(b);
		}
		
		
		
		

	}
	
}
