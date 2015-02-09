package as3.domain {
	import flash.events.EventDispatcher;
	
	public class PlayerStats extends EventDispatcher{
		protected var px:uint = 0;
		protected var hand:uint = 0;
		protected var deck:uint = 9;
		protected var discard:uint = 0;
		protected var money:uint = 0;
		protected var men:uint = 3;
		protected var extraMen:uint = 0	
		protected var menAva:Boolean = true;
		protected var dragonsKilled:uint = 0;
		
		protected var moneyMult:uint = 1;
		protected var pxMult:uint = 1;
		
		public function PlayerStats() {
			// constructor code
		}
		
		//public function incPX(){px += pxMult;}
		public function addPX(n:uint){
			px += n*pxMult;
			if(px >= 100){
				trace("TRACE: PX win condition =",px);
				dispatchEvent(new GameEvent(GameEvent.ON_WIN));
			}
		}
		public function setPX(n:uint){px = n;}
		public function doublePX(){pxMult = 2;}
		
		public function incHand(){hand++;}
		public function addHand(n:uint){hand += n;}
		public function setHand(n:uint){hand = n;}
		public function subHand(n:uint){hand -= n;}
		public function decHand(){hand--;}		
		
		public function setDeck(n:uint){deck = n;}
		public function decDeck(){
			if(deck == 0) throw new Error("PlayerStats.decDeck - deck is already 0");
			deck--;
		}
		
		public function incDiscard(){discard++;}
		public function setDiscard(n:uint){discard = n;}
		
		//public function incMoney(){money += 1*moneyMult;}
		public function addMoney(n:uint){money += n*moneyMult;}
		public function setMoney(n:uint){money = n;}
		public function subMoney(n:uint){money -= n;}
		//public function decMoney(){money--;}
		public function doubleMoney(){moneyMult = 2;}
		
		public function addMen(n:int){
			for(var i:uint = 0; i < n; i++){
				incMen();
			}
		}
		protected function incMen(){
			if(extraMen == 2) return;
			men++;
			extraMen++;
		}
		public function setMen(n:uint){men = n;}
		public function decMen(){men--; menAva = false;}
		public function subMen(n:uint){
			while(extraMen > 0 && n > 0){
				extraMen--;
				n--;
			}
			while(men > 0 && n > 0){
				men--;
				n--;
			}
		}
		
		public function incDragons(){
			dragonsKilled++;
			if(dragonsKilled == 2){
				dispatchEvent(new GameEvent(GameEvent.ON_WIN));
			}
		}
		
		public function availableMen():Boolean{return menAva && men > 0;}		
		public function getPX():uint{return px;}
		public function getMoney():uint{return money;}
		public function getHand():uint{return hand;}
		public function getDeck():uint{return deck;}
		public function getDiscard():uint{return discard;}
		public function getMen():uint{return men;}
		public function getMenAva():Boolean{return menAva;}		
		public function getExtraMen():uint{return extraMen;}
		public function getTotalMen():uint{return men+extraMen;}
		public function getDragonsKilled():uint{return dragonsKilled;}
		public function getMoneyMult():uint{return moneyMult;}
		public function getPXMult():uint{return pxMult;}
		
		public function newDay(){
			menAva = true;
			extraMen = 0;
			money = 0;
			moneyMult = 1;
			pxMult = 1;			
		}

	}
	
}
