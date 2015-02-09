package as3.ai {
	import flash.utils.ByteArray;
	import as3.Registry;
	import as3.domain.PlayerStats;
	import lib.SRandom;
	import as3.presentation.CardEvent;
	import as3.presentation.cards.Card;
	import as3.Constants;
	import as3.domain.Table;
	import as3.domain.GameVars;
	
	public class AIState {
		public static const _RES:int = 1;
		public static const _PLAY:int = 2;
		public static const _CART:int = 3;
		public static const _SAVE_HAND:int = 4;
		public static const _DISCARD:int = 5;
		public static const _GARBAGE:int = 6;
		public static const _PLAY_POST:int = 7;
		
		public static const _END_TURN:int = -1;
		//protected static const
		public var turn:uint = 1;
		
		public var p1Stats:AIPStats;
		public var p2Stats:AIPStats;
		
		public var playerDeck:Vector.<AICard> = new Vector.<AICard>();
		public var playerCards:Vector.<AICard> = new Vector.<AICard>();
		public var playerGround:Vector.<AICard> = new Vector.<AICard>();
		public var playerDiscard:Vector.<AICard> = new Vector.<AICard>();
		public var playerHose:Vector.<AICard> = new Vector.<AICard>();
		
		public var opponentDeck:Vector.<AICard> = new Vector.<AICard>();		
		public var opponentCards:Vector.<AICard> = new Vector.<AICard>();		
		public var opponentGround:Vector.<AICard> = new Vector.<AICard>();
		public var opponentDiscard:Vector.<AICard> = new Vector.<AICard>();
		public var opponentHose:Vector.<AICard> = new Vector.<AICard>();
		
		public var townCards:Vector.<AICard> = new Vector.<AICard>();
		public var eventDeck:Vector.<AICard> = new Vector.<AICard>();
		public var eventLine:Vector.<AICard> = new Vector.<AICard>();
		
		public var mod:uint;		
		public var nEffect:int = 0;
		public var moves:Vector.<AICard> = new Vector.<AICard>;
		
		public function AIState() {}
		
		public function terminalTest():Boolean{
			if(p1Stats.getPX() >= 100) return true;
			if(p2Stats.getPX() >= 100) return true;
			if(p1Stats.getDragonsKilled() >= 2) return true;
			if(p2Stats.getDragonsKilled() >= 2) return true;
			return false;			
		}		
		
		public function utility():int{
			if(p1Stats.getDragonsKilled() >= 2 || p1Stats.getPX() >= 100) return int.MAX_VALUE;
			if(p2Stats.getDragonsKilled() >= 2 || p2Stats.getPX() >= 100) return int.MIN_VALUE;
			////trace ("u",(p1Stats.getPX() - p2Stats.getPX()) - p1Stats.getMoney());
			var factor:int = playerCards.length + 0.5*playerDeck.length + playerGround.length + playerDiscard.length + (playerHose.length*2);
			return factor * ( p1Stats.getPX() - p1Stats.getMoney());
		}
		
		public function parseAIS(t:AIState){
			//trace("parseAIS");
			fromCardAI(t.playerDeck, playerDeck);
			fromCardAIT(t.playerCards, playerCards);
			fromCardAI(t.playerGround, playerGround);
			fromCardAI(t.playerDiscard, playerDiscard);
			fromCardAI(t.playerHose, playerHose);

			fromCardAI(t.opponentDeck, opponentDeck);
			fromCardAI(t.opponentCards, opponentCards);
			fromCardAI(t.opponentGround, opponentGround);
			fromCardAI(t.opponentDiscard, opponentDiscard);
			fromCardAI(t.opponentHose, opponentHose);
			
			fromCardAI(t.townCards, townCards);
			fromCardAI(t.eventDeck, eventDeck);
			fromCardAI(t.eventLine, eventLine);
			
			p1Stats = new AIPStats( t.p1Stats );
			p2Stats = new AIPStats( t.p2Stats );
			
			fromCardAI(t.moves, moves);
			mod = t.mod;
			nEffect = t.nEffect;
			_postActions = t._postActions;
			_postCard = t._postCard;
		}
		public function parseTable(t:Table){
			trace("parseAIS");
			fromCardArray(t.getPlayerDeck(), playerDeck);
			fromCardArrayT(t.getPlayerCards(), playerCards);
			fromCardArray(t.getPlayerGround(), playerGround);
			fromCardArray(t.getPlayerDiscard(), playerDiscard);
			fromCardArray(t.getPlayerHose(), playerHose);

			fromCardArray(t.getOpponentDeck(), opponentDeck);
			fromCardArray(t.getOpponentCards(), opponentCards);
			fromCardArray(t.getOpponentGround(), opponentGround);
			fromCardArray(t.getOpponentDiscard(), opponentDiscard);
			fromCardArray(t.getOpponentHose(), opponentHose);
			
			fromCardArray(t.getTownCards(), townCards);
			fromCardArray(t.getEventDeck(), eventDeck);
			fromCardArray(t.getEventLine(), eventLine);
			
			p1Stats = new AIPStats( t.getPlayerStats() );
			p2Stats = new AIPStats( t.getOpponentStats() );
			
			moves = new Vector.<AICard>();
			mod = _RES;
		}

		public function dum():String{
			return ("\nD\tC\tG\tX\tH\n"	+
					  playerDeck.length + "\t" + playerCards.length + "\t" + playerGround.length + "\t" + playerDiscard.length + "\t" + playerHose.length + "\n" +
					  opponentDeck.length + "\t" + opponentCards.length + "\t" + opponentGround.length + "\t" + opponentDiscard.length + "\t" + opponentHose.length + "\n" +
					  "----\n"+
					  townCards.length + "\t" + eventDeck.length + "\t" + eventLine.length + "\n" +
					  p1Stats.getTotalMen() + "\t" + p1Stats.getPX() + "\n" + 
					  p2Stats.getTotalMen() + "\t" + p2Stats.getPX() + "\n");					  
		}
		
		protected function fromCardArrayT(o:Array, d:Vector.<AICard>){
			var c:AICard;
			for(var i:uint = 0; i < o.length; i++){
				trace(i, o[i].getID());
				c = new AICard();
				c.fcard( o[i] );
				d.push( c );
			}
		}
		protected function fromCardArray(o:Array, d:Vector.<AICard>){
			var c:AICard;
			for(var i:uint = 0; i < o.length; i++){
				c = new AICard();
				c.fcard( o[i] );
				d.push( c );
			}
		}
		protected function fromCardAIT(o:Vector.<AICard>, d:Vector.<AICard>){
			var c:AICard;
			trace("l", o.length);
			for(var i:uint = 0; i < o.length; i++){
				c = new AICard();
				//if(o[i] == null) trace ("i",i, o[i]);
				//else trace("u", i,o[i].cID)
				c.faic( o[i] );
				d.push( c );
			}
		}
		protected function fromCardAI(o:Vector.<AICard>, d:Vector.<AICard>){
			var c:AICard;
			
			for(var i:uint = 0; i < o.length; i++){
				c = new AICard();
				c.faic( o[i] );
				d.push( c );
			}
		}
		
		
		public function endTurn(){
			var c:AICard = new AICard();
			c.cID = AICard._END_TURN;
			moves.push(c);
			mod = AIState._END_TURN;
			if(turn == 1) turn = 2;
			else if(turn == 2) turn = 1;
			else throw new Error("Inconsistent turn variable: " + turn);
		}
		public function endCart(){
			var c:AICard = new AICard();
			c.cID = AICard._END_CART;
			moves.push(c);
			mod = AIState._PLAY;
		}
		public function reserveTown(i:int){
			moves.push(townCards[i]);
			mod = AIState._PLAY;
			townCards[i].reserved = AICard._MINE;
			p1Stats.decMen();
		}
		public function playTown(i:int, o:int){
			//index factor or
			moves.push(townCards[i]);
			townCards[i].reserved = AICard._MINE_USED;
			p1Stats.addPX(townCards[i].extraPX);
			applyPost(townCards[i], o);
		}
		
		public function playHand(i:int, o:int){
			var c:AICard = playerCards[i];
			moves.push(playerCards[i]);
			playerGround.push(playerCards[i]);
			playerCards.splice(i,1);
			applyPost(c, o);
		}
		public function saveHand(i:int){
			moves.push(playerCards[i]);
			playerHose.push(playerCards[i]);
			playerCards.splice(i,1);
			mod = AIState._PLAY;
		}
		public function disCard(i:int){
			//trace("disCard",i);
			playerDiscard.push(playerCards[i]);
			garbageCard(i);
		}
		public function garbageCard(i:int){
			moves.push(playerCards[i]);
			playerCards.splice(i,1);
			nEffect--;
			//trace("nEffect",nEffect);
			if(nEffect < 0) throw new Error("Inconsistent #garbageable-cards")
			else if(nEffect == 0){
				mod = AIState._PLAY_POST;
			}
		}
			
		public function buyEvent(i:int){
			moves.push(eventLine[i]);
			p1Stats.subMoney(eventLine[i].price);
			if(eventLine[i].isGesta())
				p1Stats.incDragons();
			playerDiscard.push(eventLine[i]);
			eventLine.splice(i,1);			
			for(var j:int = i-1; j >= 0; j--){
				if(eventLine[j].tether){
					playerDiscard.push(eventLine[j]);
					eventLine.splice(j,1);
				}
			}
			nEffect--;
			if(nEffect < 0) throw new Error("Inconsistent #buyable-cards")
			else if(nEffect ==0){
				endCart();
			}
			
		}
		public function canBuyEvent(i:int):Boolean{
			if(eventLine[i].tether) return false;
			return p1Stats.getMoney() >= eventLine[i].price;
		}
		
		public function canReserveTown(i:int):Boolean{
			if(p1Stats.getMen() == 0) throw new Error("no men available");
			return townCards[i].reserved == AICard._FREE;
		}
		
		public function playMode_Town(i:int):uint{
			//gv.dlog("   ." + townCards[i].reserved.toString());
			if(townCards[i].reserved != AICard._MINE)
				return AICard._PLAY_NO;
			return playMode(townCards[i]);
		}		
		public function playMode_Hand(i:int):uint{return playMode(playerCards[i]);}		
		public function playMode_Ground(i:int):uint{return playMode(playerGround[i]);}		
		private function playMode(c:AICard):uint{
			if(c.tether)
				return AICard._PLAY_NO;
			if(c.hasPre() && !canDoPre(c))
			 	return AICard._PLAY_NO;
			if(!canDoPost(c))
				return AICard._PLAY_NO;  
				
			if(c.hasPre())return AICard._PLAY_PRE;
			if(c.hasOr()) return AICard._PLAY_OR;
			return AICard._PLAY_YES;
		}
		
		public function getPreType_Town(i:int):uint{return townCards[i].getPreType();}
		public function getPreType_Hand(i:int):uint{return playerCards[i].getPreType();}
		public function getPreType_Ground(i:int):uint{return playerGround[i].getPreType();}
		
		public function getPreMax_Town(i:int):uint{return getPreMax(townCards[i]);}
		public function getPreMax_Hand(i:int):uint{return getPreMax(playerCards[i]);}
		public function getPreMax_Ground(i:int):uint{return getPreMax(playerGround[i]);}
		private function getPreMax(c:AICard):uint{
			for(var i:uint = Constants.V_START; i <= Constants.V_END; i++){
				if(c.pre[i] != 0){
					switch(i){
						case Constants.V_MONEY:
							return Math.min(c.getPreMax(), p1Stats.getMoney());
						case Constants.V_GARBAGE:
						case Constants.V_DISCARD:
							return Math.min(c.getPreMax(), playerCards.length-1);
						case Constants.V_FOLLOWER:
							return Math.min(c.getPreMax(), p1Stats.getTotalMen());
					}
				}
			}
			throw new Error("pre out of bounds: " + i);
			return false;
		}
		
		public function getPostMax_Town(i:int):uint{return getPostMax(townCards[i]);}
		public function getPostMax_Hand(i:int):uint{return getPostMax(playerCards[i]);}
		public function getPostMax_Ground(i:int):uint{return getPostMax(playerGround[i]);}
		private function getPostMax(c:AICard):uint{
			if(c.pre[Constants.V_DRAW] > 0)
				return playerDeck.length;
			return uint.MAX_VALUE;
		}
		
		var _postCard:AICard;
		var _postActions:uint;
		public function playPre_Town(i:int, n:int){
			playPre(townCards[i], n);
			townCards[i].reserved = AICard._MINE_USED;
		}
		public function playPre_Hand(i:int, n:int){
			playPre(playerCards[i], n);
			playerGround.push(playerCards[i]);
			playerCards.splice(i,1);
		}
		public function playPre_Ground(i:int, n:int){
			playPre(playerGround[i], n);
		}
		private function playPre(c:AICard, n:int){
			moves.push(c);
			
			var choice:AICard = new AICard();
			choice.cID = AICard._PRE_CHOICE;
			choice.cOR = n;
			choice.reserved = c.cID;
			moves.push(choice);
			
			_postActions = n;
			nEffect = n;
			_postCard = c;
			//trace("playPre", _postCard.cID, n);
			switch(c.getPreType()){
				case Constants.V_MONEY:
					p1Stats.subMoney(n);
					mod = AIState._PLAY_POST;
					break;
				case Constants.V_FOLLOWER:
					p1Stats.subMen(n);
					mod = AIState._PLAY_POST;
					break;
				case Constants.V_DISCARD:
					mod = AIState._DISCARD;
					break;
				case Constants.V_GARBAGE:
					mod = AIState._GARBAGE;
					break;
				default: throw new Error("pre out of bounds: " + c.getPreType());
			}
		}
		
		private function canDoPre(c:AICard):Boolean{
			for(var i:uint = Constants.V_START; i <= Constants.V_END; i++){
				if(c.pre[i] != 0){
					switch(i){
						case Constants.V_MONEY:
							return 0 < p1Stats.getMoney();
						case Constants.V_GARBAGE:
						case Constants.V_DISCARD:
							return 0 < playerCards.length;
						case Constants.V_FOLLOWER:
							return 0 < p1Stats.getTotalMen();
						default:
							throw new Error("pre out of bounds: " + i);
							return false;
					}
				}
			}
			return false;
		}		
		
		private function canDoPost(c:AICard):Boolean{
			//trace("cdp",c.cID);
			//trace("   ",c.post);
			for(var i:uint = Constants.V_START; i <= Constants.V_END; i++){
				if(c.post[i] != 0){
					switch(i){
						// case Constants.V_CART: siempre se puede porque se pueden descartar las compras sobrantes							
						case Constants.V_NULLTOWN:
							if(!freeTowns()) return false;
							break;
						case Constants.V_DOUBLE_USE:
							if(!freeGestaObj()) return false;
							break;
						case Constants.V_SAVE_HAND:
							if(playerCards.length < 2) return false;
							break;
						case Constants.V_DRAW:
							if(playerDeck.length == 0) return false;
							break;
					}
				}
			}
			return true;
		}
		
		
		public function resumePost(){
			//trace("resumePost", _postCard.cID);
			for(var i:int = Constants.V_START; i <= Constants.V_END; i++){
				if(_postCard.post[i] != 0){
					switch(i){
						case Constants.V_PX: p1Stats.addPX(_postActions); mod = AIState._PLAY;return;
						case Constants.V_MONEY: p1Stats.addMoney(_postActions); mod = AIState._PLAY;return;
						case Constants.V_FOLLOWER: p1Stats.addMen(_postActions); mod = AIState._PLAY;return;
						case Constants.V_DRAW:
							//trace("  rp:", _postActions, playerDeck.length);
							var sss:String = "";
							for(var k:int = 0; k < playerDeck.length; k++){
								sss.concat(playerDeck[k].cID.toString() + " ");
							}
							for(var j:int = 0; j < _postActions && playerDeck.length > 0; j++){
								playerCards.push(playerDeck.pop());
							}
							mod = AIState._PLAY;
							return;
						case Constants.V_CART:
							mod = AIState._CART;
							nEffect = _postActions;
						return;
					}
				}
			}
		}
		protected function applyPost(_c:AICard, _or:uint, _n:uint = uint.MAX_VALUE){
			var _first:Boolean = (_or < 2);
			var _ret:Boolean = true;
			var p:Vector.<int> = _c.post;
			
			for(var i:int = Constants.V_START; i <= Constants.V_END; i++){
				//gv.dlog(p[i], _first);
				if(p[i] != 0 && _first){
					var _num = Math.min(p[i], _n);
					switch(i){
						case Constants.V_PX: p1Stats.addPX(_num); break;
						case Constants.V_MONEY: p1Stats.addMoney(_num); break;
						case Constants.V_FOLLOWER: p1Stats.addMen(_num); break;
						case Constants.V_DOUBLE_GOLD: p1Stats.doubleMoney(); break;
						case Constants.V_DOUBLE_PX: p1Stats.doublePX(); break;
						case Constants.V_DRAW:
							for(var j:int = 0; j < _num && playerDeck.length > 0; j++){
								playerCards.push(playerDeck.pop());
							}
							break;
						case Constants.V_CART:
							mod = AIState._CART;
							nEffect = _num;
							break;
						case Constants.V_SAVE_HAND:
							mod = AIState._SAVE_HAND;
							if(_num != 1) throw new Error("SAVE_HAND should be 1, but is " + _num);
							nEffect = _num;
							break;
						case Constants.V_NULLTOWN:
							break;
						case Constants.V_DOUBLE_USE:
							break;
						
						//double gold --> in player stats
					}
					if(p[Constants.V_OR] == 1) return;
				}
				else if(p[i] != 0) _first = true;
			}
		}
		
		private function freeTowns():Boolean{
			for(var i:uint = 0; i < townCards.length; i++)
				if( townCards[i].reserved == AICard._FREE )
					return true;
			return false;
		}
		
		private function freeGestaObj():Boolean{
			var i:uint;
			for(i = 0; i < townCards.length; i++)
				if( townCards[i].reserved == AICard._MINE_USED )
					return true;
			for(i = 0; i < playerGround.length; i++)
				if( !playerGround[i].isGesta() )
					return true;
			return false;
		}
	}
	
	
	
}
