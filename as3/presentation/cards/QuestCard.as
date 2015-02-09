package as3.presentation.cards {
	import lib.Helpers;
	import flash.text.TextField;
	
	public class QuestCard extends GameCard{
		protected var price:uint;
		protected var tfPrice:TextField = new TextField();
		
		protected var extraPrice:uint = 0;
		public function QuestCard() {
			super();
			wide=false;
		}

		public function init3(_id:uint, _nm:String, _color:uint, _ini:int, _price:uint, _pre:Vector.<int>,_post:Vector.<int>){		
			init2(_id,_nm,_color,_ini,_pre,_post);			
			price = _price;			
			Helpers.initTextField(tfPrice, price.toString(), 0, 168, 40, 24, tFormatBig,this);
			/*if(id > 200 && id < 300){
				paintBackground(0x99ff99);
			}
			else if(id > 300 && id < 400){
				paintBackground(0xffff66);
			}
			else if(id > 400 && id < 500){
				paintBackground(0xdd7777);
			}*/
		}
		
		override public function getPrice():uint{return price + extraPrice;}
		
		override public function setExtraPrice(p:uint){
			extraPrice = p;
			Helpers.initTextField(tfPrice, (price + extraPrice).toString(), 0, 168, 40, 24, tFormatBig,this);
		}
		
		
	}
	
}
