package as3.presentation.cards {
	import lib.Helpers;
	import flash.events.MouseEvent;

	public class TownCard extends Card{
		
		
		public function TownCard() {
			super();
		}
		
		public function init2(_id:uint, _nm:String, _color:uint, _pre:Vector.<int>,_post:Vector.<int>){
			init(_id, _nm, _color, _pre, _post);
			inTown = true;
			//Helpers.initTextField(tfEffect, "Effect", 5, 167, 130, 24, tFormatBig, this);
		}
		
		
		
		
	}
	
}
