package as3.domain {
	import as3.data.Deck;
	import as3.presentation.cards.Card;
	import as3.presentation.cards.GameCard;
	import as3.Registry;
	import as3.Constants;
	import lib.SRandom;
	import lib.Helpers;
	import flash.events.EventDispatcher;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	public class Table extends EventDispatcher{
		protected var _rand:Number, _card:Card;
		protected var rand:SRandom;
		
		protected var playerDeck:Array = new Array();
		protected var playerCards:Array = new Array();
		protected var playerGround:Array = new Array();
		protected var playerDiscard:Array = new Array();
		protected var playerHose:Array = new Array();
		
		protected var opponentDeck:Array = new Array();		
		protected var opponentCards:Array = new Array();		
		protected var opponentGround:Array = new Array();
		protected var opponentDiscard:Array = new Array();
		protected var opponentHose:Array = new Array();
		
		protected var townCards:Array = new Array();
		protected var eventDeck:Array = new Array();
		protected var eventLine:Array = new Array();
		
		protected var p1Stats:PlayerStats = new PlayerStats();
		protected var p2Stats:PlayerStats = new PlayerStats();
		
		protected var gv:GameVars;
		public function Table(_gv:GameVars, _seed:uint, _lang:uint) {
			
			rand = new SRandom(_seed);
			gv = _gv;
			gv.dlog("Table - being instantiated with seed " + _seed);
			var d:Deck = new Deck(_lang);
			
			d.initCardsTown(townCards);
			d.initEventDeck(eventDeck);
			
			shuffleEventDeck();		
			trace("eventdeck0", eventDeck[0].getID());
			if(gv.playerNum == 1){				
				d.initPlayerDeck(playerDeck);
				shuffle(playerDeck);
				d.initOpponentDeck(opponentDeck);
				shuffle(opponentDeck);
				//opponentDeck.push(eventDeck[4]);
				//eventDeck.splice(4,1);
			}
			else if(gv.playerNum ==2){				
				d.initOpponentDeck(opponentDeck);
				shuffle(opponentDeck);
				d.initPlayerDeck(playerDeck);				
				shuffle(playerDeck);
				//playerDeck.push(eventDeck[4]);
				//eventDeck.splice(4,1);
			}
			else throw new Error("Table: player number wrong " + gv.playerNum);
			
				
			playerDraws(5);
			swapPlayers();
			playerDraws(5);
			swapPlayers();
			buildEventLine();
			
			p1Stats.addEventListener(GameEvent.ON_WIN, winHandler);
			
			//if(gv.playerNum == 1) p1Stats.setMen(1);
			//else if(gv.playerNum == 2) p2Stats.setMen(1);
		}
		
		protected function winHandler(e:GameEvent = null){
			var e2:GameEvent = new GameEvent(GameEvent.ON_WIN);
			if(turnMe) e2.id = 1;
			else throw new Error("Table.winHandler - this shouldnt happen");
			
			gv.dlog("Table.winHandler " + p1Stats.getPX());
			e2.u1 = p1Stats.getPX();
			gv.dlog("Table.winHandler "+ p1Stats.getPX() +" " + e2.u1);
			e2.u2 = p1Stats.getDragonsKilled();
			e2.u3 = p2Stats.getPX();
			e2.u4 = p2Stats.getDragonsKilled();
			
			dispatchEvent(e2);
		}
		
		public function getPlayerDeck():Array{return playerDeck;}
		public function getPlayerCards():Array{return playerCards;}
		public function getPlayerGround():Array{return playerGround;}
		public function getPlayerDiscard():Array{return playerDiscard;}
		public function getPlayerHose():Array{return playerHose;}		
		public function getOpponentDeck():Array{return opponentDeck;}
		public function getOpponentCards():Array{return opponentCards;}
		public function getOpponentGround():Array{return opponentGround;}
		public function getOpponentDiscard():Array{return opponentDiscard;}
		public function getOpponentHose():Array{return opponentHose;}		
		public function getTownCards():Array{return townCards;}
		public function getEventDeck():Array{return eventDeck;}
		public function getEventLine():Array{return eventLine;}		
		public function getPlayerStats():PlayerStats{return p1Stats;}
		public function getOpponentStats():PlayerStats{return p2Stats;}	
		
		public function getPhaseIni():int{
			gv.dlog("Table.getPhaseIni -> "+ ((playerGround[0] as GameCard).getIni() - (opponentGround[0] as GameCard).getIni()));
			return	(playerGround[0] as GameCard).getIni() - (opponentGround[0] as GameCard).getIni();
		}
		
		protected function updateStats(){
			p1Stats.setDeck(playerDeck.length);
			p1Stats.setDiscard(playerDiscard.length);
			p1Stats.setHand(playerCards.length);
			
			p2Stats.setDeck(opponentDeck.length);
			p2Stats.setDiscard(opponentDiscard.length);
			p2Stats.setHand(opponentCards.length);
		}
		
		public function turnEnd(){
			p1Stats.newDay();
			p2Stats.newDay();
			updateStats();
		}
		
		public function swapPlayers(){
			gv.dlog("Table.swapPlayers " + playerCards.length +" "+ opponentCards.length);
			var ac:Array = opponentCards;
			var ad:Array = opponentDeck;
			var ag:Array = opponentGround;
			var ax:Array = opponentDiscard;
			var ah:Array = opponentHose;
			opponentCards = playerCards;
			opponentDeck = playerDeck;
			opponentGround = playerGround;
			opponentDiscard = playerDiscard;
			opponentHose = playerHose;
			playerCards = ac;
			playerDeck = ad;
			playerGround = ag;
			playerDiscard = ax;
			playerHose = ah;
			
			var ps:PlayerStats = p1Stats;
			p1Stats = p2Stats;
			p2Stats = ps;
			
			for(var i:int = 0; i < townCards.length; i++){
				(townCards[i] as Card).swapPlayers();
			}
			gv.dlog("SWAP SWAP " + playerCards.length +" "+ opponentCards.length);
		}
		
		public function playerDraws(n:uint){
			gv.dlog("Player drawing " + n);
			for(var nn:uint = 0; nn < n; nn++)
				drawOne();
		}
		
		/*public function opponentDraws(n:uint){
			for(var nn:uint = 0; nn < n; nn++) 
				drawOne(opponentDeck,opponentCards);
		}*/
		
		public function buildEventLine(){
			gv.dlog("Table.buildEventLine - " + eventLine.length);
			drawEvent(6 - eventLine.length);
			(eventLine[0] as GameCard).setExtraPrice(0);
			(eventLine[1] as GameCard).setExtraPrice(0);
			(eventLine[2] as GameCard).setExtraPrice(0);
			(eventLine[3] as GameCard).setExtraPrice(1);
			(eventLine[4] as GameCard).setExtraPrice(1);
			(eventLine[5] as GameCard).setExtraPrice(2);
		}
		
		protected function drawEvent(n:uint){			
			for(var nn:uint = 0; nn < n; nn++){
				//gv.dlog(eventDeck.length, eventLine.length);
				drawOneEvent();
			}
		}
		
		protected function drawOne(){
			gv.dlog("Drawing a card " + playerCards.length + " " + playerDeck.length);
			playerCards.push(playerDeck.pop());
			gv.dlog("  and now " + playerCards.length + " " + playerDeck.length);
			if(playerDeck.length == 0)
			{				
				shuffle(playerDiscard);
				while (playerDiscard.length > 0) {
					gv.dlog("  if " + playerDiscard.length + " " + playerDeck.length);
					playerDeck.push(playerDiscard.pop());
				}
			}
		}
		
		protected function drawOneEvent(){
			gv.dlog(eventDeck.length + "cards remain in the table deck");
			eventLine.push(eventDeck.shift());
			if(eventDeck.length == 0)
			{
				winHandler(new GameEvent(GameEvent.ON_WIN));
			}
		}
		/*
		public function shufflePlayerDeck(){
			Registry.screenLog.appendText("Table - shuffling player cards");
			shuffle(playerDeck);
		}
		public function shuffleOpponentDeck(){
			Registry.screenLog.appendText("Table - shuffling opponent cards");
			shuffle(opponentDeck);
		}*/
		public function shuffleEventDeck(){
			gv.dlog("Table - shuffling quest cards " + eventDeck.length);
			shuffleSubArray(eventDeck, 0, 11);
			shuffleSubArray(eventDeck, 11, 22);
			shuffleSubArray(eventDeck, 22, 34);
			shuffleSubArray(eventDeck, 34, 45);
			//shuffleSubArray(eventDeck, 0, 45);
		}
		
		protected function shuffle(a:Array){
			var _l:uint = a.length;
			for(var i:int = 0; i < _l; i++){
				_rand = rand.nextMinMax(0,_l);
				_card = a[i];
				a[i] = a[_rand];
				a[_rand] = _card;
			}
			return a;
		}
		protected function shuffleSubArray(a:Array, stt:uint, end:uint){
			for(var i:int = stt; i < end; i++){
				_rand = rand.nextMinMax(stt, end);
				_card = a[i];
				a[i] = a[_rand];
				a[_rand] = _card;
			}
			return a;
		}

		public function playCard(_id:uint, _or:uint = 0){
			gv.dlog("Table.playCard");		
			if(gv.currentPhase == Constants.PH_PLAN
			|| gv.currentPhase == Constants.PH_PLAN_SYNC){
				playCardPhase(_id,_or);
				return;
			}
				
			var w:int = whereIs(_id);
			switch(w){
				case Constants.IN_HAND:
					gv.dlog("Table.playCard - card is in hand")
					playCardHand(_id,_or);						
					break;
				case Constants.IN_TOWN:
					playCardTown(_id,_or);
					break;
				case Constants.IN_LINE:
					playCardEventLine(_id,_or);
					break;
				case Constants.IN_GROUND:
					replayCardGround(_id,_or);
					break;
				case Constants.IN_ERROR:
					gv.dlog("Table.playCard - card id="+_id+" not found");
					//throw new Error("Table.playCard: card id="+_id+" not found");
					break;
			}
			
		}
		
		protected function applyPost(_c:Card, _or:uint, _n:uint = uint.MAX_VALUE){
			gv.dlog("Table.applyPost OR: " + _or + " " + _n);
			var _first:Boolean = (_or < 2);
			var _ret:Boolean = true;
			var p:Vector.<int> = _c.getPost();
			var _evt:GameEvent;			
			if(gv.isHuman) Registry.log("Playing " + _c.getName()+":");
			for(var i:int = Constants.V_START; i <= Constants.V_END; i++){
				//gv.dlog(p[i], _first);
				if(p[i] != 0 && _first){
					var _num = Math.min(p[i], _n);
					switch(i){
						case Constants.V_PX:
							gv.dlog("Table - gain px " + _num);
							if(gv.isHuman) Registry.log("  +" +_num + "PX");
							p1Stats.addPX(_num);
							break;
						case Constants.V_MONEY:
							gv.dlog("Table - gain mo " + _num);
							if(gv.isHuman) Registry.log("  +" + _num + " coins");
							p1Stats.addMoney(_num);
							break;
						case Constants.V_FOLLOWER:
							gv.dlog("Table - gain followers " + _num);
							if(gv.isHuman) Registry.log("  +" + _num + " follower");
							p1Stats.addMen(_num);
							break;
						case Constants.V_DOUBLE_GOLD:
							gv.dlog("Table - double money");
							if(gv.isHuman) Registry.log("  double coins the rest of turn!");
							p1Stats.doubleMoney();
							break;
						case Constants.V_DOUBLE_PX:
							gv.dlog("Table - double px");
							if(gv.isHuman) Registry.log("  double PX the rest of turn!");
							p1Stats.doublePX();
							break;
						case Constants.V_DRAW:
							gv.dlog("Table - draw " + _num + " i:"+i);
							playerDraws(_num);
							if(gv.isHuman) Registry.log("  draws " + _num);
							gv.dlog("Table - drawn " + _num + " i:"+i);
							break;
						case Constants.V_CART:
							gv.dlog("Table - cart " + _num);
							if(gv.isHuman) Registry.log("  buying " + _num);
							_evt = new GameEvent(GameEvent.ON_EFFECT_CART);
							_evt.id = _c.getID();
							_evt.num = _num;
							dispatchEvent(_evt);
							break;
						case Constants.V_SAVE_HAND:
							if(gv.isHuman) Registry.log("  hides a card in its hose...");
							_evt = new GameEvent(GameEvent.ON_EFFECT_SAVE_HAND);
							_evt.id = _c.getID();
							_evt.num = _num;
							dispatchEvent(_evt);
							break;
						case Constants.V_NULLTOWN:
							gv.dlog("Table - nulltown ");
							if(gv.isHuman) Registry.log("  is nulling a town");
							_evt = new GameEvent(GameEvent.ON_EFFECT_NULLTOWN);
							_evt.id = _c.getID();
							_evt.num = _num;
							dispatchEvent(_evt);						
							break;
						case Constants.V_DOUBLE_USE:
							gv.dlog("Table - double use ");
							if(gv.isHuman) Registry.log("  reusing a card");
							_evt = new GameEvent(GameEvent.ON_EFFECT_DOUBLE_USE);
							_evt.id = _c.getID();
							_evt.num = _num;
							dispatchEvent(_evt);
							break;
						
						//double gold --> in player stats
					}
					if(p[Constants.V_OR] == 1) return;
				}
				else if(p[i] != 0) _first = true;
			}
		}
		
		public function payMoney(n:uint){
			gv.dlog("table.payMoney");
			p1Stats.subMoney(n);
		}
		public function payFollower(n:uint){
			gv.dlog("table.payFollower");
			p1Stats.subMen(n);
		}
		public function nulltown(_id:uint){
			var i:int = Helpers.indexOf(townCards, _id);
			townCards[i].nullTown();
			gv.log("Turns and nulls " + townCards[i].getName());
		}
		public function disCard(_id:uint){
			gv.dlog("table.disCard");
			var i:int = Helpers.indexOf(playerCards, _id);
			if(i<0) throw new Error("Table.disCard - card not found");
			gv.log("Discards " + playerCards[i].getName());
			playerDiscard.push(playerCards[i]);
			playerCards.splice(i,1);
			updateStats();
		}
		public function cartCard(_id:uint):Boolean{
			gv.dlog("table.cartCard");
			var i:int = Helpers.indexOf(eventLine, _id);
			gv.log("Resolves and gets " + eventLine[i].getName());
			if(i<0)
				throw new Error("Table.cartCard - card id not found:" +_id);
			if((eventLine[i] as QuestCard).getPrice() > p1Stats.getMoney()){
				gv.dlog("  No");
				return false;
			}
			
			payMoney((eventLine[i] as QuestCard).getPrice());
			eventLine[i].removeFromEvents();
			if( (eventLine[i] as Card).getID() == 453
			||	(eventLine[i] as Card).getID() == 454 ){
				gv.dlog("KD");
				p1Stats.incDragons();
			}
			playerDiscard.push(eventLine[i]);
			eventLine.splice(i,1);
			
			for(var j:int = i-1; j >= 0; j--){
				if((eventLine[j] as Card).isTether()){
					gv.log("  ...plus a tether!");
					eventLine[j].removeFromEvents();
					playerDiscard.push(eventLine[j]);
					eventLine.splice(j,1);
				}
			}
			updateStats();
			return true;
		}
		
		public function saveHand(_id:uint){
			gv.dlog("table.saveHand");
			var i:int = Helpers.indexOf(playerCards, _id);
			playerHose.push(playerCards[i]);
			playerCards.splice(i,1);			
			updateStats();
		}
		public function garbageCard(_id:uint){
			gv.dlog("table.garbageCard IN HAND");
			var i:int = Helpers.indexOf(playerCards, _id);
			playerCards[i].destroy();
			playerCards.splice(i,1);			
			updateStats();
		}
		
		protected function playCardPhase(_id:uint, _or:uint = 0){
			gv.dlog("Table.playCardPhase");
			var i:int = Helpers.indexOf(playerCards, _id);
			if(i == -1) throw new Error("Table.playCardPhase - invalid card ID");
			
			var _init:uint =  uint((playerCards[i] as GameCard).getIni());
			gv.log("Puts " + playerCards[i].getName() +" with " +_init +"initiative");
			playerCards[i].turn();
			playerGround.push(playerCards[i]);
			playerCards.splice(i,1);
			
			if(phaseEvents){
				gv.dlog("  it's plan phase");
				var _evt:GameEvent = new GameEvent(GameEvent.ON_TURN_PLAN_END);
				_evt.id = _id;
				_evt.choice = _or;
				_evt.eventMessage = _init.toString();
				dispatchEvent(_evt);
			}
		}

		protected var turnMe:Boolean;
		protected var phaseEvents:Boolean;
		public function before(me:Boolean = true, pe:Boolean = true, time:uint = 0){
			//time 1 -> new turn
			//time 2 -> new day
			gv.dlog("Table.BEFORE " + me);
			turnMe = me;
			phaseEvents = pe;
			updateStats();
			if(!turnMe) swapPlayers();
		}
		
		public function after(){
			gv.dlog("Table.AFTER " + turnMe);
			if(!turnMe) swapPlayers();
			updateStats();
			gv.blocked = false;
			/*
			var asd:Function = function (item:*, index:int, array:Array):String {return new String(item.getID())};
			gv.dlog("TEST", playerDeck.length, opponentDeck.length);
			gv.dlog(playerCards.map(asd).join(" "));
			gv.dlog(playerDeck.map(asd).join(" "));
			gv.dlog(opponentCards.map(asd).join(" "));
			gv.dlog(opponentDeck.map(asd).join(" "));*/
		}
			
		protected function playCardHand(_id:uint, _or:uint = 0){			
			gv.dlog("Table.playCardHand");
			var i:int = Helpers.indexOf(playerCards, _id);
			if(i == -1) throw new Error("Table.playCardHand - invalid card ID");
			
			var _card:Card = playerCards[i];
			if(_card.isTether()) return;
			if(_card.hasPre()){
				gv.dlog(" has pre");
				if(!Registry.rules.canPlayCardPre(_card,p1Stats)){
					gv.dlog(" no can play");
					dispatchEvent(new GameEvent(GameEvent.ON_CARD_CLICK_CANT));
					return;
				}
				var asdrubal:int = Registry.rules.preMaxValue(_card,p1Stats);
				if(gv.isHuman)					
					gv.selectNum.init(_card, asdrubal);
				_pdCard = _card;
				playerGround.push(playerCards[i]);
				playerCards.splice(i,1);
				_card.turn();
				var _e:GameEvent = new GameEvent(GameEvent.ON_PRE);
				_e.id = _card.getPreType();
				_e.choice = asdrubal;
				dispatchEvent(_e);
				return;
			}
			var _init:uint =  uint((playerCards[i] as GameCard).getIni());
			applyPost(_card, _or);					
			playerGround.push(playerCards[i]);
			playerCards.splice(i,1);
			_card.turn();	
			gv.dlog("Table.playCardHand BEFORE EVENT");
			
			if(phaseEvents){				
				var _evt:GameEvent = new GameEvent(GameEvent.ON_CARD_CLICK_CONFIRM);
				_evt.id = _id;
				_evt.choice = _or;
				_evt.eventMessage = _init.toString();
				dispatchEvent(_evt);
			}
			gv.dlog("Table.playCardHand END");
		}
		
		protected function replayCardGround(_id:uint, _or:uint = 0){			
			gv.dlog("Table.replayCardGround");
			var i:int = Helpers.indexOf(playerGround, _id);
			if(i == -1) throw new Error("Table.replayCardGround - invalid card ID");

			var _card:Card = playerGround[i];
			
			if(_card.hasPre()){	gv.dlog("  has pre");
				if(!Registry.rules.canPlayCardPre(_card, p1Stats)){
					gv.dlog("  can't, due to card prerequisites");
					dispatchEvent(new GameEvent(GameEvent.ON_CARD_CLICK_CANT));
					return;
				}
				var asdrubal:int = Registry.rules.preMaxValue(_card, p1Stats);
				if(gv.isHuman)
					gv.selectNum.init(_card, asdrubal);
				_pdCard = _card;
				var _e:GameEvent = new GameEvent(GameEvent.ON_PRE);
				_e.id = _card.getPreType();
				_e.choice = asdrubal;
				dispatchEvent(_e);
				return;
			}
			applyPost(_card, _or);
			
			if(phaseEvents){
				var _init:uint =  uint((playerGround[i] as GameCard).getIni());
				var _evt:GameEvent = new GameEvent(GameEvent.ON_CARD_CLICK_CONFIRM);
				_evt.id = _id;
				_evt.choice = _or;
				_evt.eventMessage = _init.toString();
				dispatchEvent(_evt);
			}
		}
		
		protected function playCardEventLine(_id:uint, _or:uint = 0){			
			gv.dlog("Table.playCardEventLine");
			var _c:GameCard = eventLine[Helpers.indexOf(eventLine, _id)];
			
			var _confirm:Boolean = false;
			
			if(Registry.rules.canBuyEvent(_c, p1Stats)){
				cartCard(_c.getID());
				p1Stats.subMoney((_c as QuestCard).getPrice());
				
				var _ec:GameEvent = new GameEvent(GameEvent.ON_CARD_CLICK_CONFIRM);
				_ec.id = _id;
				dispatchEvent(_ec);
			}			
			else{
				dispatchEvent(new GameEvent(GameEvent.ON_CARD_CLICK_CANT));
				gv.dlog("No");
				return;
			}
			
			gv.dlog("Table.playCardEventLine END");
		}
		
		public function addExtraPX(_id:uint, c:Card = null){
			if(c == null){
				var i:int = Helpers.indexOf(townCards, _id);
				if(i < 0) return;
				c = townCards[i];
			}
			if(!c.isInTown()) return;
			if(gv.isHuman && c.getExtraPX() > 0) Registry.log(c.getName() +":\n  +" + c.getExtraPX() + " extra PX");
			gv.dlog("Table.addExtraPX - " + c.getExtraPX());
			p1Stats.addPX(c.getExtraPX());
			c.resetExtraPX();
		}
		
		protected function playCardTown(_id:uint, _or:uint = 0){			
			gv.dlog("Table.playCardTown");
			var _tc:Card = townCards[Helpers.indexOf(townCards, _id)];
			var _confirm:Boolean = false;
			
			if(Registry.rules.canPlayTown(_tc, gv.modeReuse)){
				gv.dlog("  can Play");			
				if(_tc.hasPre()){
					if(!Registry.rules.canPlayCardPre(_tc, p1Stats)){
						gv.dlog("No");
						dispatchEvent(new GameEvent(GameEvent.ON_CARD_CLICK_CANT));
						return;
					}					
					if(gv.isHuman)
						gv.selectNum.init(_tc, Registry.rules.preMaxValue(_tc, p1Stats));
					_pdCard = _tc;
					addExtraPX(_id, _tc);
					var _evt:GameEvent = new GameEvent(GameEvent.ON_PRE);
					_evt.id = _tc.getPreType();
					_evt.choice = Registry.rules.preMaxValue(_tc, p1Stats);
					dispatchEvent(_evt);
					
					return;
				}
				else addExtraPX(_id, _tc);
				applyPost(_tc, _or, _tc.getID());
				_tc.turn();
				_confirm = true;
			}			
			else if(Registry.rules.canReserveTown(_tc, p1Stats)){
				if(gv.isHuman) Registry.log("Placing follower on " + _tc.getName());
				gv.dlog("...reserving");
				_tc.reserve();
				p1Stats.decMen();
				gv.dlog("Card reserved");				
				var _e:GameEvent = new GameEvent(GameEvent.ON_TOWN_RESERVE);
				dispatchEvent(_e);
				_confirm = true;
			}
			else{
				dispatchEvent(new GameEvent(GameEvent.ON_CARD_CLICK_CANT));
				gv.dlog("No");
				return;
			}
			
			if(_confirm){
				var _ec:GameEvent = new GameEvent(GameEvent.ON_CARD_CLICK_CONFIRM);
				_ec.id = _id;
				_ec.choice = _or;
				dispatchEvent(_ec);
			}
		}
		
		public function setDelayedPostCard(id:uint){			
			var w:int = whereIs(id);
			gv.dlog("setDelayedPostCard " + id + " " + w);		
			switch(w){
				case Constants.IN_HAND: _pdCard = playerCards[Helpers.indexOf(playerCards, id)];
					return;					
				case Constants.IN_TOWN: _pdCard = townCards[Helpers.indexOf(townCards, id)];
					return;
				default: throw new Error("setDelayedPostCard - " + id);
			}
		}
		
		var _pdCard:Card
		public function resumePost(num:uint, postDone:Boolean = false){
			if(whereIs(_pdCard.getID()) == Constants.IN_HAND){
				var _io:int = Helpers.indexOf(playerCards, _pdCard.getID()); 
				playerGround.push(playerCards[_io]);
				playerCards.splice(_io,1);	
			}
			resumeTownPost(num,postDone);
		}
		protected function resumeTownPost(num:uint, postDone:Boolean = false){
			gv.dlog("Table.resumeTownPost " + num +" " + postDone + " " + _pdCard.getID());
			if(!postDone){
				if(_pdCard.getID() == 448) num = 3;
				applyPost(_pdCard, 0, num);
				var _evt:GameEvent = new GameEvent(GameEvent.ON_CARD_CLICK_CONFIRM);
				_evt.id = _pdCard.getID();
				_evt.choice = num;
				dispatchEvent(_evt);
			}			
			_pdCard.turn();			
			_pdCard = null;
		}
		
		public function endJourney(){
			gv.dlog("Table.endJourney");
			var _c:Card;
			//Mantenimiento
			//1. Recompensa de PX
			for(var i:int = townCards.length-1; i >= 0; i--){
				_c = townCards[i] as Card;
				_c.denullTown();
				if(!_c.isReserved()){
					//add extra PX
					if(_c.addExtraPX() >= 3){
						garbageTownCard(i);						
					}
				}
				else{
					_c.unreserve();					
				}
			}
			
			//2. Descartes			
			while(playerCards.length > 0) playerDeck.push(playerCards.pop());
			while(playerGround.length > 0) playerDeck.push(playerGround.pop());
			while(playerDiscard.length > 0) playerDeck.push(playerDiscard.pop());
			while(opponentCards.length > 0) opponentDeck.push(opponentCards.pop());
			while(opponentGround.length > 0) opponentDeck.push(opponentGround.pop());
			while(opponentDiscard.length > 0) opponentDeck.push(opponentDiscard.pop());
			for(i=0;i<playerDeck.length;i++) playerDeck[i].straighten();
			for(i=0;i<opponentDeck.length;i++) opponentDeck[i].straighten();
			
			if(gv.playerNum == 1){
				shuffle(playerDeck);
				shuffle(opponentDeck);
			}
			else if(gv.playerNum ==2){
				shuffle(opponentDeck);	
				shuffle(playerDeck);
			}
			//3. And followers
			playerDraws(5);
			while(playerHose.length > 0) playerCards.push(playerHose.pop());
			p1Stats.newDay();
			p1Stats.setMen(3);
			
			swapPlayers(); //copypaste of the previous lines :D
			playerDraws(5);
			while(playerHose.length > 0) playerCards.push(playerHose.pop());
			p1Stats.newDay();
			p1Stats.setMen(3);
			swapPlayers(); //end copy paste
			
			for(var j:int=0;j<5;j++){
				gv.dlog(playerCards[j].getID() + " --- " + opponentCards[j].getID());
			}
			
			//4. Event line
			if(eventLine.length > 0) eventLine.splice(0,1);
			buildEventLine();
			
			//5. Reconstruction
			//undestroy cards
			
			//6. New Journey --> back to gv.class processing
		}
		
		protected function garbageTownCard(t:uint){
			townCards.splice(t, 1);
			
			var _c:Card;
			if(eventLine.length > 0){
				_c = eventLine[0];
				eventLine.splice(0,1);
			}
			else{
				_c = eventDeck[0];
				eventDeck.splice(0,1);
			}
			
			townCards.push(_c);
			_c.addedInTown();
		}
		
		protected function whereIs(_id:uint):uint{
			var i:int;
			for(i = 0; i < playerCards.length; i++){
				if((playerCards[i] as Card).getID() == _id){
					return Constants.IN_HAND;
				}
			}
			for(i = 0; i < townCards.length; i++){
				if((townCards[i] as Card).getID() == _id){
					return Constants.IN_TOWN;
				}
			}
			for(i = 0; i < eventLine.length; i++){
				if((eventLine[i] as Card).getID() == _id){
					return Constants.IN_LINE;
				}
			}
			for(i = 0; i < playerGround.length; i++){
				if((playerGround[i] as Card).getID() == _id){
					return Constants.IN_GROUND;
				}
			}
			return Constants.IN_ERROR;
		}
		
		
		
	}
	
}
