package as3.ai {
	import as3.domain.PlayerStats;
	
	public class AIPStats {
		protected var px:uint;
		protected var money:uint;
		protected var men:uint;
		protected var extraMen:uint;
		protected var menAva:Boolean;
		protected var dragonsKilled:uint;
		
		protected var moneyMult:uint;
		protected var pxMult:uint;
		
		public function AIPStats(ps:*) {
			px = ps.getPX();
			money = ps.getMoney();
			men = ps.getMen();
			extraMen = ps.getExtraMen();
			menAva = ps.getMenAva();
			dragonsKilled = ps.getDragonsKilled();
			moneyMult = ps.getMoneyMult();
			pxMult = ps.getPXMult();
		}

		public function addPX(n:uint){
			px += n*pxMult;
		}
		public function setPX(n:uint){px = n;}
		public function doublePX(){pxMult = 2;}
		
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
		}
		
		public function availableMen():Boolean{return menAva && men > 0;}		
		public function getPX():uint{return px;}
		public function getMoney():uint{return money;}
		public function getMen():uint{return men;}
		public function getMenAva():Boolean{return menAva;}		
		public function getExtraMen():uint{return extraMen;}
		public function getTotalMen():uint{return extraMen+men;}
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
