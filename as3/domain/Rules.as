package as3.domain  {
	import as3.presentation.cards.GameCard;
	import as3.presentation.cards.TownCard;
	import as3.presentation.cards.Card;
	import as3.Constants;
	import as3.presentation.cards.QuestCard;
	import as3.Registry;
	
	public class Rules {
		
		public function Rules() {}
		
		public function canStartTurn(ps:PlayerStats):Boolean{
			//trace("canIStartTurn", p1Stats.getMen() > 0);
			return ps.getMen() > 0;
		}
		
		public function canStartTurn_DUM(p1:PlayerStats, p2:PlayerStats):String{
			return ("canStartTurn ", p1.getMen() +"/"+ p1.getPX() +" "+p2.getMen() +"/"+ p2.getPX() );
		}
		
		public function isJourneyFinished(a:Array, p1:PlayerStats, p2:PlayerStats):Boolean{
			/*Registry.gvdlog("Rules.isJourneyFinished (!)" 
						  + canStartTurn(p1)+"|"+ canStartTurn(p2)+"\n"
						  + p1.getMen()+"|"+p2.getMen());*/
			if(!remainingTowns(a)) return false;
			//Registry.dlog("   there are towns remaining");
			return !(canStartTurn(p1) || canStartTurn(p2));
		}
		
		protected function remainingTowns(a:Array):Boolean{
			var _c:Card;
			for(var i:uint = 0; i < a.length; i++)
				if( (a[i] as Card).isAvailable() && !(a[i] as Card).isTether())
					return true;
			return false;
		}
		
		public function canReserveTown(c:Card, ps:PlayerStats):Boolean{
			//Registry.dlog("Rules.canReserveTown - " + p1Stats.getMen()+","+p1Stats.availableMen());
			if(ps.availableMen()) return !c.isReserved();
			return false;
		}
		
		public function canPlayTown(c:Card, mReuse:Boolean):Boolean{		
			//Registry.dlog("Rules.canPlayTown - " + c.isMine()+","+c.isRotated()+","+mReuse);
			if(c.isMine() && !c.isRotated()) return true;
			if(c.isMine() && c.isRotated() && mReuse) return true;
			return false;			
		}
		
		public function canPlayCardPre(c:Card, ps:PlayerStats):Boolean{
			var _pre:Vector.<int> = c.getPre();
			for(var i:uint = Constants.V_START; i <= Constants.V_END; i++){
				if(_pre[i] != 0){
					switch(i){
						case Constants.V_MONEY:
							return 0 < ps.getMoney();
						case Constants.V_GARBAGE:
						case Constants.V_DISCARD:
							return 0 < ps.getHand();
						case Constants.V_FOLLOWER:
							return 0 < ps.getTotalMen();
						default:
							throw new Error("Rules.canPlayCard - pre out of bounds: " + i);
							return false;
					}
				}
			}
			return false;
		}
		
		public function canBuyEvent(c:GameCard, ps:PlayerStats):Boolean{
			//trace("Rules.canBuyEvent");
			if(c.isTether()) return false;
			var _qc:QuestCard = c as QuestCard;
			return _qc.getPrice() <= ps.getMoney();
		}
		
		public function preMaxValue(c:Card, ps:PlayerStats):uint{
			var _pre:Vector.<int> = c.getPre();
			for(var i:uint = Constants.V_START; i <= Constants.V_END; i++){
				if(_pre[i] != 0){
					switch(i){
						case Constants.V_MONEY:
							return Math.min(_pre[i], ps.getMoney());
						case Constants.V_GARBAGE:
						case Constants.V_DISCARD:
							return Math.min(_pre[i], ps.getHand());
						case Constants.V_FOLLOWER:
							return Math.min(_pre[i], ps.getMen());
						default:
							throw new Error("Rules.canPlayCard - pre out of bounds: " + i);
							return false;
					}
				}
			}
			throw new Error("Rules.preMaxValue - pre not found");							
			return 0;
		}

	}
	
}
