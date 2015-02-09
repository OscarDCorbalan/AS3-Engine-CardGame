package as3.presentation
{
	import flash.events.Event;
	public class CardEvent extends Event
	{
		public static const ON_CLICK:String = "onClick";
		
		/*customMessage is the property will contain the message for each event type dispatched */
		public var cardID:uint;
		public var cardOR:uint = 0;
		
		public function CardEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false):void
		{
		   //we call the super class Event
		   super(type, bubbles, cancelable);
		}
		public function setCard(i:uint, o:uint){
			cardID = i;
			cardOR = o;
		}
		override public function clone():Event {
			var e:CardEvent = new CardEvent(type, bubbles, cancelable);
			setCard(e.cardID, e.cardOR);
			return e;
		}
		
	}
}