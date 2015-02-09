package as3.data {
	import flash.events.Event;
	
	public class RemoteEvent extends Event {
		//the event type ON_SEED_READY is used when a random seed is ready
		public static const ON_SEED_READY:String = "onSeedReady";
		public static const ON_TURN_PLAN_1:String = "onTurnPlan1";
		public static const ON_TURN_PLAN_2:String = "onTurnPlan2";
		public static const ON_TURN_PLAN_SYNC:String = "onTurnPlanSync";
		
		public static const ON_TURN_START:String = "onTurnStart";
		
		public static const ON_TURN_SYNC:String = "onTurnSync";
		public static const ON_TURN_SYNC_BUY:String = "onTurnSyncBuy";
		public static const ON_TURN_SYNC_NULLTOWN:String = "onTurnSyncNullTown";
		public static const ON_TURN_SYNC_REUSE:String = "onTurnSyncReuse";
		public static const ON_TURN_SYNC_PRE:String = "onTurnSyncPre";
		public static const ON_TURN_SYNC_PRE_START:String = "onTurnSyncPreStart"; //pre that needs user actions
		public static const ON_TURN_SYNC_PRE_CLICK:String = "onTurnSyncPreClick"; //pre that needs user actions
		public static const ON_TURN_SYNC_PRE_END:String = "onTurnSyncPreEnd"; //pre that needs user actions
		public static const ON_TURN_SYNC_SAVE_HAND:String = "onTurnSyncSaveHand";
		
		public var eventMessage:String = "";
		public var id:int = -1;
		public var choice:uint;
		public var num:uint;
		
		public function RemoteEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false):void{
		   super(type, bubbles, cancelable);
		}
		override public function clone():Event {
			// Return a new instance of this event with the same parameters.
			return new RemoteEvent(type, bubbles, cancelable);
		}

	}
	
}
