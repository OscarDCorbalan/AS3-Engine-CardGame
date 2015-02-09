package as3.presentation.interfaces {
	import as3.domain.Table;
	import as3.Registry;
	import as3.Constants;
	import as3.presentation.CardEvent;
	import as3.ai.*;
	import as3.domain.GameVars;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import as3.domain.GameEvent;
	
	public class AIInterface extends Interface{
		
		protected var ais:AIState = new AIState();		
		protected var table:Table;
		protected var timer:Timer;
		
		private const _EASY:uint = 5000;
		private var cut:Boolean;
		private var nodesEvaluated:uint;
		private var cturn:uint;
		private var moves:Vector.<AICard>;
		
		public function AIInterface(_gv:GameVars, h:Boolean) {
			super(_gv);
			cut = !h;
			timer = new Timer(67);
			timer.addEventListener(TimerEvent.TIMER, timerMoves);
		}
		
		override public function setTable(t:Table){
			table = t;			
		}
		
		override public function mouseUnblock(s:int = -1){
			ais = new AIState();
			ais.parseTable(table);
			
			if(s == Constants.PH_PLAN){
				randomPlan();			
			}
			else
				minimax();
		}
		
		private function timerMoves(e:TimerEvent){
			if(gv.blocked){
				trace("BLOCK BLOCK BLOCK BLOCK BLOCK", moves.length);
				return;
			}
			var c:AICard = moves.shift();
			trace("AIPLAY", c.cID);
			switch(c.cID){
				case AICard._END_TURN:
					timer.stop();
					passTurnHandler();
					break;
				case AICard._END_CART:
					endCarting();
					break;
				case AICard._PRE_CHOICE:
					var _e:GameEvent = new GameEvent(GameEvent.ON_PRE_CHOICE);
					_e.id = c.reserved;
					_e.choice = c.cOR;
					dispatchEvent(_e);
					break;
				default:
					clickCard(c.cID, c.cOR);	
					break;
			}
		}
		
		private function randomPlan(){
			gv.dlogAI("AIInterface.randomPlan");
			clickCard(ais.playerCards[0].cID);
		}
		
		
		private function minimax(){
			gv.dlogAI("AIInterface.minimax");
			cturn = 1;
			movesVal = int.MIN_VALUE;
			nodesEvaluated = 0;
			var dsa:int = max(ais);
			gv.dlogAI("AIInterface.minimax: max="+dsa);
			gv.dlogAI("AIInterface.minimax: mov="+moves.length);
			Registry.log("AI evaluated " + nodesEvaluated +" possibilities");
			timer.start();			
		}
		
		private function max(a:AIState):int{
			//terminal or sterile node -> return utility
			if(a.terminalTest()) return a.utility();
			var scs:Vector.<AIState> = getAllSuccessors(a);
			if(scs.length == 0) return a.utility();
			if(cut && nodesEvaluated >= _EASY) return uint.MIN_VALUE;
			
			var tmp:AIState;
			var best:AIState;
			var val:int;
			var upper:int = int.MIN_VALUE;// a.utility();
			//gv.dlogAI("max.. scs.len: " + scs.length);
			for(var i:int = 0; i < scs.length; i++){				
				tmp = scs[i];
				val = max(tmp);
				//gv.dlogAI("max..val=" + val.toString());
				if(upper < val){
					upper = val;
					setMoves(tmp, upper);					
				}						
			}			
			return upper;
		}
		
		private var movesVal:int;
		private function setMoves(a:AIState, v:int){
			//gv.dlogAI("setMoves " + v.toString() +" " +a.moves.length);
			if(v > movesVal){
				moves = a.moves;
				movesVal = v;
			}
		}
		private function min(a:AIState):int{
			//gv.dlogAI("min 1");
			if(a.terminalTest()) return a.utility();
			//gv.dlogAI("min 2");			
			return max(a);
		}
		
		private function getAllSuccessors(a:AIState):Vector.<AIState>{
			//gv.dlogAI("AIInterface.getAllSuccessors");
			nodesEvaluated++;
			var i:int;
			var r:uint;
			var b:AIState;
			var so:Vector.<AIState> = new Vector.<AIState>();
			
			switch(a.mod){
				case AIState._RES:
				//reserve a town card
					//gv.dlogAI("  case AIState._RES");
					for(i = 0; i < a.townCards.length; i++){
						//trace("reserve",i);
						//gv.dlogAI("  _res " + i);
						if(a.canReserveTown(i)){
							//gv.dlogAI("    can " + i);
							b = new AIState();
							b.parseAIS(a);
							b.reserveTown(i);
							so.push( b );
						}						
					}
				break;
				
				case AIState._PLAY_POST:
					b = new AIState(); b.parseAIS(a);
					b.resumePost();
					so.push( b );
				break;
				
				case AIState._DISCARD:
					for(i = 0; i < a.playerCards.length; i++){
						b = new AIState(); b.parseAIS(a);
						b.disCard(i);
						so.push( b );
					}
				break;
				
				case AIState._GARBAGE:
					for(i = 0; i < a.playerCards.length; i++){
						b = new AIState(); b.parseAIS(a);
						b.garbageCard(i);
						so.push( b );
					}
				break;
				
				case AIState._CART:
					//gv.dlogAI("  _cart");
					//player can stop carting at any moment
					b = new AIState(); b.parseAIS(a);
					b.endCart();
					so.push(b);
					//or continue buying
					for(i = 0; i < a.eventLine.length; i++){
						if(a.canBuyEvent(i)){
							//gv.dlogAI("    " + i);
							b = new AIState(); b.parseAIS(a);
							b.buyEvent(i);
							so.push( b );
						}
					}
				break;
				
				case AIState._SAVE_HAND:
					for(i = 0; i < a.playerCards.length; i++){
						b = new AIState(); b.parseAIS(a);
						b.saveHand(i);
						so.push(b);							
					}
				break;
				
				case AIState._PLAY:
					//gv.dlogAI("  case AIState._PLAY");
					//ending turn is always an option
					b = new AIState();
					b.parseAIS(a);
					b.endTurn();
					so.push(b);
					
					for(i = 0; i < a.townCards.length; i++){
						//int return var --> no / si / si con pre / si con or...
						//trace("tw",i);
						switch(a.playMode_Town(i)){
							case AICard._PLAY_OR:
								//gv.dlogAI("    town or  " + i);
								//right effect
								b = new AIState(); b.parseAIS(a);
								b.playTown(i,2);
								so.push(b);
								//left effect, cascades to the next case in the switch
							case AICard._PLAY_YES:
								//gv.dlogAI("    town yes " + i);
								b = new AIState(); b.parseAIS(a);
								b.playTown(i,1);
								so.push(b);
								break;
							case AICard._PLAY_PRE:
								//trace("mins",a.getPreMax_Town(i), a.getPostMax_Town(i));
								r = Math.min(a.getPreMax_Town(i), a.getPostMax_Town(i));
								for(var j:uint = 1; j <= r; j++){
									b = new AIState(); b.parseAIS(a);
									b.playPre_Town(i,j);
									so.push(b);
								}
								break;								
							case AICard._PLAY_NO:
							default:
								break;
						}
					}
					for(i = 0; i < a.playerCards.length; i++){
						switch(a.playMode_Hand(i)){
							case AICard._PLAY_OR:
								//gv.dlogAI("    hand or  " + i);
								b = new AIState(); b.parseAIS(a);
								b.playHand(i,2);
								so.push(b);
							case AICard._PLAY_YES:
								b = new AIState(); b.parseAIS(a);
								b.playHand(i,1);
								so.push(b);
								//gv.dlogAI("    hand yes " + i);
								break;							
							case AICard._PLAY_PRE:
								r = Math.min(a.getPreMax_Hand(i), a.getPostMax_Hand(i));
								for(j = 1; j <= r; j++){
									b = new AIState(); b.parseAIS(a);
									b.playPre_Hand(i,j);
									so.push(b);
								}
							case AICard._PLAY_NO:
								//gv.dlogAI("    hand no  " + i);
							default:
								break;	
						}
					}
				break;
				case AIState._END_TURN:
				break;
			}
			//gv.dlogAI("gAS"+  so.length.toString());
			/*for(i = 0; i < so.length; i++){
				//gv.dlogAI("  so " +so[i].moves.length);
				for(var j = 0; j < so[i].moves.length; j++){
					gv.dlogAI("     " + so[i].moves[j].cID);
				}
			}*/
			return so;
		
		}
		
		
		
		

	}
	
}
