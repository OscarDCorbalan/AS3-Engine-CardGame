package as3.ai  {
	import as3.Constants;
	import as3.Registry;
	import as3.presentation.cards.Card;
	
	public class AICard {
		public static var _FREE = 0;
		public static var _MINE = 1;
		public static var _MINE_USED = 2;
		public static var _CANT = 3;
		
		public static var _PLAY_NO:uint = 0;
		public static var _PLAY_YES:uint = 1;
		public static var _PLAY_PRE:uint = 2;
		public static var _PLAY_OR:uint = 3;
		
		public static var _END_TURN:int = -1;
		public static var _END_CART:int = -2;
		public static var _PRE_CHOICE:int = -3;
		
		public var cID:int;
		public var cOR:uint = 0;
		public var price:uint;
		public var extraPX:uint = 0;		
		public var pre:Vector.<int>;
		public var post:Vector.<int>;
		
		//for effects
		public var reserved:uint; //0 free, 1 mine, 2 otro
		public var nulled:Boolean;
		public var tether:Boolean;
		public function AICard(){}
		
		public function faic(c:AICard){
			//if(c.cID == 5) Registry.dlogAI("AICard.faic " + c.cID +" "+ c.reserved);
			//trace("c ",c.cID)
			cID = c.cID;
			cOR = c.cOR;
			price = c.price;
			extraPX = c.extraPX;
			pre = c.pre;
			post = c.post;
			reserved = c.reserved;
			nulled = c.nulled;
			tether = c.tether;
		}
		
		public function fcard(c:Card) {
			//if(c.getID() == 5) Registry.dlogAI("AICard.fcard " + c.getID() +" "+ c.isReserved());
			cID = c.getID();
			extraPX = c.getExtraPX();
			price = c.getPrice();
			pre = c.getPre();
			post = c.getPost();
			if(!c.isReserved()) reserved = _FREE;
			else{
				if(c.isMine()){
					if(c.isRotated()) reserved = _MINE_USED;
					else reserved = _MINE;
				}
				else reserved = _CANT;
			}
			nulled = c.isNulled();
			tether = c.isTether();
		}
		
		public function addPX(){
			if(extraPX == 2) return;
			extraPX++;
		}
		
		public function hasPre():Boolean{
			if(pre == null) return false;
			return pre[Constants.V_EMPTY] != 1;
		}	
		public function getPreType():uint{
			for(var i:uint = Constants.V_START; i <= Constants.V_END; i++)
				if(pre[i] != 0)	return i;
			throw new Error("AICard.getPreType - pre not found");
			//return 0;
		}
		public function getPostType():uint{
			for(var i:uint = Constants.V_START; i <= Constants.V_END; i++)
				if(post[i] != 0)	return i;
			throw new Error("AICard.getPostType - post not found");
			//return 0;
		}
		public function getPreMax():uint{
			for(var i:uint = Constants.V_START; i <= Constants.V_END; i++)
				if(pre[i] != 0)
					return Math.abs(pre[i]);
			throw new Error("Card.getPreMax - pre not found");
			//return 0;
		}
		public function hasOr():Boolean{
			//Registry.dlog("Card.hasOr");
			if(post == null) return false;
			return post[Constants.V_OR] == 1;
		}	
		public function isGesta(){
			if(cID==125||cID==234||cID==341||cID==342||cID==343||cID==452) return true;
			return false;
		}

	}
	
}
