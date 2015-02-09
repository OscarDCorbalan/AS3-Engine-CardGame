package as3 {
	import as3.Registry;
	import flash.display.MovieClip;
	import as3.domain.Engine;
	import flash.events.MouseEvent;
	
	[SWF (width = 1024, height = 768)]
	public class Launcher extends MovieClip{
		var pvp:ButtonPvP = new ButtonPvP();
		var pv1:ButtonPvIA1 = new ButtonPvIA1();
		var pv2:ButtonPvIA2 = new ButtonPvIA2();
		var bg:MenuBG = new MenuBG();
		var flag:Flag = new Flag();
		
		public function Launcher() {
			
			Registry.stage = this.stage;
			addChild(bg)
			addChild(pvp);
			pvp.x = 180;
			pvp.y = 270;
			addChild(pv1);
			pv1.x = 25;
			pv1.y = 510;
			addChild(pv2);
			pv2.x = 305;
			pv2.y = 500;
			addChild(flag);
			flag.x = 610 + 130;
			flag.y = 230 + 130;
			pvp.addEventListener(MouseEvent.CLICK, startPVP);
			pv1.addEventListener(MouseEvent.CLICK, startEasy);
			pv2.addEventListener(MouseEvent.CLICK, startHard);
			
			
		}
		
		private function destroy():uint{
			pvp.removeEventListener(MouseEvent.CLICK, startPVP);
			pv1.removeEventListener(MouseEvent.CLICK, startEasy);
			pv2.removeEventListener(MouseEvent.CLICK, startHard);
			removeChild(pvp);
			removeChild(pv1);
			removeChild(pv2);
			removeChild(bg);
			var _lan = flag.getLang();
			flag.destroy();
			return _lan;
		}
		
		private function startPVP(e:MouseEvent){			
			var l:uint = destroy();
			var engine:Engine = new Engine(l, true);
		}
		
		private function startEasy(e:MouseEvent){		
			var l:uint = destroy();
			var engine:Engine = new Engine(l, true);
			var engine2:Engine = new Engine(l, false);			
		}
		
		private function startHard(e:MouseEvent){			
			var l:uint = destroy();
			var engine:Engine = new Engine(l, true);
			var engine2:Engine = new Engine(l, false, true);			
		}

	}
	
}
