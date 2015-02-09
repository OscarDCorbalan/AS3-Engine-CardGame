package as3.domain
{
	import flash.events.Event;
	public class GameEvent extends Event
	{
		public static const ON_TURN_PASS:String = "onTurnPass";		
		public static const ON_JOURNEY_END:String = "onJourneyEnd";
		public static const ON_TURN_PLAN_END:String = "onTurnPlanEnd";	
		
		public static const ON_CARD_CLICK:String = "onCardClick";
		public static const ON_CARD_CLICK_CONFIRM:String = "onCardClickConfirm";
		public static const ON_CARD_CLICK_CANT:String = "onCardClickCant";
		
		public static const ON_EFFECT_CART:String = "onEffectCart";
		public static const ON_EFFECT_CART_END:String = "onEffectCartEnd";
		public static const ON_EFFECT_DOUBLE_USE:String = "onEffectDoubleUse";
		public static const ON_EFFECT_NULLTOWN:String = "onEffectNullTown";
		public static const ON_EFFECT_SAVE_HAND:String = "onEffectSaveHand";
		
		public static const ON_PRE:String = "onPre";
		public static const ON_PRE_CHOICE:String = "onPreChoice";
		public static const ON_PRE_END:String = "onPreEnd";
		
		public static const ON_TOWN_RESERVE:String = "onTownReserve";
		public static const ON_TOWN_USE:String = "onTownUse";
		
		public static const ON_WIN:String = "onWin";
		
		public var eventMessage:String = "";
		public var id:int = -1;
		public var choice:uint;
		public var num:uint;
		public var u1:uint;
		public var u2:uint;
		public var u3:uint;
		public var u4:uint;
		public function GameEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false):void
		{
		   //we call the super class Event
		   super(type, bubbles, cancelable);
		}
		override public function clone():Event {
			// Return a new instance of this event with the same parameters.
			return new GameEvent(type, bubbles, cancelable);
		}
		
	}
}