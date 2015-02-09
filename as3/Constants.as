package as3 {
	
	public class Constants {
		
		
		public static const V_CLASSES:Vector.<Class> = new <Class>
			[null,null,null,null,SymPX,SymGold,SymCard,SymCard,	SymGarbage, SymCart, SymMan, SymBook, SymDoubleUse, SymDoubleGold, SymDoublePX, SymHand];
		// 	 0    1    2    3    4     5       6       7       	8		  	9		 10		 11		  12			13				14
		// EE AN OR .. PX MO DR DI BU 
		
		public static const V_EMPTY = 0;
		public static const V_AND = 1;
		public static const V_OR = 2;
		
		public static const V_START = 4;
		public static const V_PX = 4;
		public static const V_MONEY = 5;
		public static const V_DRAW = 6;
		public static const V_DISCARD = 7;
		public static const V_GARBAGE = 8;
		public static const V_CART = 9;
		public static const V_FOLLOWER = 10;
		public static const V_NULLTOWN = 11;
		public static const V_DOUBLE_USE = 12;
		public static const V_DOUBLE_GOLD = 13;
		public static const V_DOUBLE_PX = 14;
		public static const V_SAVE_HAND = 15;
		public static const V_END = 15;
		public static const VLENGTH = V_END+1;
		
		public static const IN_ERROR = 0;
		public static const IN_HAND = 1;
		public static const IN_TOWN = 2;
		public static const IN_LINE = 3;
		public static const IN_GROUND = 4;
		
		public static const PH_WAIT = 0;
		public static const PH_ERROR = -1;
		public static const PH_PLAN = 1;
		public static const PH_PLAN_SYNC = 2;
		public static const PH_TURN = 3;
		public static const PH_TURN_MINE = 4;
		public static const PH_TURN_OPPO = 5;
		//public static const IN_TOWN = 2;
		//public static const IN_LINE = 3;
		//public static const IN_GROUND = 4;
		
		public static const NEW_TURN = 1;
		public static const NEW_DAY = 2;
		
		public static const _CardWidth:Number = 143;
		public static const _CardHeight:Number = 200;
		
		
		public static const L_ENG = 1;
		public static const L_ESP = 2;
		public static const L_CAT = 3;
		
		public function Constants() {
			// constructor code
		}

	}
	
}
