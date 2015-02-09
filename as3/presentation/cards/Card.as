package as3.presentation.cards{
	import as3.Constants;	
	import as3.presentation.CardEvent;
	import as3.presentation.interfaces.UserInterface;
	import as3.Registry;
	import as3.domain.GameVars;
	import com.greensock.TweenMax;
	import lib.Helpers;
	import flash.display.MovieClip;
	import fl.motion.Color;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.display.Sprite;	
	import flash.events.Event;
	import flash.events.MouseEvent;	
	import flash.events.EventDispatcher;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.display.Bitmap;
	
	public class Card extends MovieClip {
		//instance variables
		protected var nm:String;
		protected var color:uint;
		protected var effect:String = "EFFECT";
		protected var wide:Boolean = true;
		protected const _wideDx:uint = 40;
		protected var id:uint;
		protected var rotated:Boolean = false;
		
		//instance child UI elements
		protected var tfName:TextField = new TextField();
		protected var tfEffect:TextField = new TextField();
		
		//class variables		
		protected static var tFormatSmall:TextFormat = new TextFormat("Arial",14,null,null,null,null,null,null,TextFieldAutoSize.LEFT);
		protected static var tFormatBig:TextFormat = new TextFormat("Arial",20,null,null,null,null,null,null,TextFieldAutoSize.CENTER);
		
		protected var pre:Vector.<int>;
		protected var post:Vector.<int>;
		protected var spritePre:Sprite;
		protected var spritePost:Sprite;		
		protected var spritePostOR1:Sprite;
		protected var spritePostOR2:Sprite;
		
		protected var reserved:Boolean = false;
		protected var mine:Boolean = false;
		protected var nulled:Boolean = false;
		protected var inTown:Boolean = false;
		protected var inEventLine:Boolean = false;
		
		protected var extraPX:uint = 0;
		protected var extraPX_1:SymPX;
		protected var extraPX_2:SymPX;
		//protected var inEvents:Boolean = false;
		
		protected var animTurn:TweenMax;
		public function Card(){
			super();
			buttonMode = true;
			mouseChildren = false;
			animTurn = new TweenMax(this,1,{rotation:90, paused:true});
		}
		
		var ldr:Loader;
		public function setImage(s:String){	
			ldr = new Loader();
 			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, imageReadyHandler);
			var fileRequest:URLRequest = new URLRequest(s);
			//Registry.screenLog.appendText(fileRequest);
 			ldr.load(fileRequest); 
		}
		var image:Bitmap;
		protected function imageReadyHandler(e:Event){
			ldr.contentLoaderInfo.removeEventListener(Event.COMPLETE, imageReadyHandler);			
			image = new Bitmap(e.target.content.bitmapData);
			addChild(image);
      		image.width = 140;
     		image.height = 100;
			image.x = 0;
			image.y = 45;
      		
		}
		public function getName():String{return nm;}
		public function getID():uint{return id;}
		public function getPost():Vector.<int>{return post;}
		public function getPre():Vector.<int>{return pre;}
		public function getPrice():uint{return uint.MAX_VALUE;}
		public function isRotated(){return rotated;}		
		public function isReserved():Boolean{return reserved;}		
		public function isNulled():Boolean{return nulled;}
		public function isAvailable():Boolean{return !nulled && !reserved;}
		public function isMine():Boolean{return mine;}
		public function isInTown():Boolean{return inTown;}		
		public function isInEventLine():Boolean{return inEventLine;}		
		public function isTether(){return false;}
		
		public function hasPre():Boolean{
			//Registry.dlog("Card.hasPre - " + nm +" "+ pre);
			if(pre == null) return false;
			//Registry.dlog("   Card.hasPre - " + pre[Constants.V_EMPTY]);
			return pre[Constants.V_EMPTY] != 1;
		}	
		public function hasOr():Boolean{
			//Registry.dlog("Card.hasOr");
			if(post == null) return false;
			return post[Constants.V_OR] == 1;
		}		
		public function getPreMax():uint{
			for(var i:uint = Constants.V_START; i <= Constants.V_END; i++){
				if(pre[i] != 0){
					return Math.abs(pre[i]);
				}
			}
			throw new Error("Card.getPreMax - pre not found");
			return 0;
		}
		public function getPreType():uint{
			for(var i:uint = Constants.V_START; i <= Constants.V_END; i++)
				if(pre[i] != 0)	return i;
			throw new Error("Card.getPreType - pre not found");
			return 0;
		}
		
		protected function init(_id:uint, _nm:String, _color:uint, _pre:Vector.<int>,_post:Vector.<int>){		
			graphics.beginFill(_color);
			graphics.drawRect( 0 , 0 , Constants._CardWidth, Constants._CardHeight );
			graphics.endFill();
			nm = _nm;
			color = _color;
			id = _id;
			pre = _pre;
			post = _post;
			if(pre != null && post != null){
				//trace(nm);
				effectPaint();}
			else{
				//Helpers.initTextField(tfEffect, effect, 45, 172, 90, 24, tFormatSmall, this);
			}
			Helpers.initTextField(tfName, nm, 45, 5, 90, 20, tFormatSmall, this);
			tfName.embedFonts = true;
			//Helpers.initTextField(tfEffect, effect, 45, 172, 90, 24, tFormatSmall, this);
			if(id > 100) inEventLine = true;
			addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		public function getPreSymbol():MovieClip{
			for(var i:uint = Constants.V_START; i <= Constants.V_END; i++){
				if(pre[i] != 0){
					switch(i){
						case Constants.V_GARBAGE: return new SymGarbage();
						case Constants.V_DISCARD: return new SymCard();
						case Constants.V_MONEY: return new SymGold();
						case Constants.V_FOLLOWER: return new SymMan();
					}
				}
			}
			throw new Error("Card.getPreSymbol - pre not found");
			return 0;
		}
		
		protected function dispatchClick(cid:uint){
			var _evt:CardEvent = new CardEvent(CardEvent.ON_CLICK);
			_evt.cardID = cid;
			dispatchEvent(_evt);
		}
		protected function clickHandler_cart(e:MouseEvent = null){
			//Registry.dlog("Card.clickHandler_cart " + nm );
			if(!inEventLine) return;
			if(isTether()) return;
			dispatchClick(id);
		}
		protected function clickHandler_savehand(e:MouseEvent = null){
			//Registry.dlog("Card.clickHandler_savehand " + nm );
			if(inEventLine) return;
			if(inTown) return;
			dispatchClick(id);
		}
		protected function clickHandler_killtown(e:MouseEvent = null){
			//Registry.dlog("Card.clickHandler_killtown " + nm );
			if(!inTown) return;
			if(reserved) return;
			if(rotated) return;
			dispatchClick(id);
		}
		
		protected function clickHandler(e:MouseEvent){
			//Registry.dlog("Card.clickHandler " + nm );
			var _gv:GameVars = (parent.parent as UserInterface).getGV();
			/*Registry.dlog("  te=" + isTether() 
						  + " ro=" + rotated 
						  + " ev=" + inEventLine 
						  + " to=" + inTown  
						  + " rm=" + _gv.modeReuse 
						  + " cm=" + _gv.modeCart);*/
			if(_gv.modeCart) {clickHandler_cart();return;}
			else if(inEventLine) return;
			if(_gv.modeSaveHand)	{clickHandler_savehand();return;}
			if(_gv.modeTown)		{clickHandler_killtown();return;}			
			if(_gv.modeReuse){
				if(inEventLine) return;
				if(isGesta()) return;
				if(inTown && (!mine || !rotated)) return;
			}
			else if(rotated) return;				
			
			if(inTown){
				if(isTether())	return;
				if(nulled)		return;
			}
			
			if(_gv.currentPhase != Constants.PH_PLAN
			   && post != null && post[Constants.V_OR] == 1
			   && (!inTown && !inEventLine || inTown && reserved )){
				//Registry.dlog("  MODE A " + id + " click (OR) " + nm);
				_gv.selectEffect.init(spritePostOR1,spritePostOR2,this);				
			}
			else{
				//Registry.dlog("  MODE B " +id + " click on " + nm);
				var _evt:CardEvent = new CardEvent(CardEvent.ON_CLICK);
				_evt.cardID = id;
				dispatchEvent(_evt);
			}
		}
		
		public function isGesta(){
			if(id==125||id==234||id==341||id==342||id==343||id==452) return true;
			return false;
		}
		public function confirmOR(_u:uint){
			//Registry.dlog(id + "Click (OR) " + _u);		
			var _evt:CardEvent = new CardEvent(CardEvent.ON_CLICK);
			_evt.cardID = id;
			_evt.cardOR = _u;
			dispatchEvent(_evt);
		}
		/*
		public function confirmNum(_u:uint){
			//Registry.dlog(id + "Click (pre) choosed " + _u);		
			var _evt:CardEvent = new CardEvent(CardEvent.ON_CLICK);
			_evt.cardID = id;
			_evt.cardOR = _u;
			dispatchEvent(_evt);
		}*/

		private function effectPaint(){				
			var dx:uint = 0;
			var spriteEffect:Sprite = new Sprite();
			var spriteArrow:Sprite;
			
			if(pre[Constants.V_EMPTY] == 0){
				//trace("pre",pre);
				spritePre = toSprite(pre, true);
				spriteEffect.addChild(spritePre);
				
				spriteArrow = new SymArrow();
				spriteArrow.x = spriteEffect.width+5;
				spriteEffect.addChild(spriteArrow);
				//sprite
			}
			
			
			spritePost = toSprite(post);
			if(pre[Constants.V_EMPTY] == 0)
				spritePost.x = spriteEffect.width+5;
			spriteEffect.addChild(spritePost);			
			
			addChild(spriteEffect);
			if(wide){
				spriteEffect.x = (Constants._CardWidth - spriteEffect.width)*0.5;
			}
			else{				
				spriteEffect.x = _wideDx + (Constants._CardWidth - _wideDx - spriteEffect.width)*0.5;
				//Registry.screenLog.appendText(nm + " " + spriteEffect.x + "\n");
			}
			spriteEffect.y = 167;
		}
		
		private function toSprite(v:Vector.<int>, neg:Boolean = false):Sprite{
			var g:Sprite = new Sprite();		
			var m:MovieClip;
			var dx:uint = 0;
			var OR:Boolean = (v[Constants.V_OR] == 1);
			var AND:Boolean = (v[Constants.V_AND] == 1);
			for(var i:uint = Constants.V_START; i <= Constants.V_END; i++){
				if(v[i] != 0){
					m = new Constants.V_CLASSES[i]();
					if( v[Constants.V_OR] == 1) dup(Constants.V_CLASSES[i]);
					
					if(v[i] != 1) 
						addNumber(g, v[i], neg);
					if(g.numChildren > 0)
						m.x = g.width+2;
					g.addChild(m);
					
					if(OR || AND){
						if(OR){
							m = new SymOr();
							OR = false;
						}
						if(AND){
							m = new SymAnd();
							AND = false;
						}	
						m.x = g.width+2;
						g.addChild(m);
					}									
				}
			}
			return g;
		}
		
		private function dup(fa80f32q8nhjfa809h:Class){
			if(spritePostOR1 == null)
				spritePostOR1 = new fa80f32q8nhjfa809h();
			else 
				spritePostOR2 = new fa80f32q8nhjfa809h();
		}
		private function addNumber(g:Sprite, n:int, neg:Boolean = false){
			//if it's a +one dont add anything
			//trace("addnumber",n);
			if(n==1) return;
			
			var s:Sprite;
			var d:uint = 0;
			//add + or -
			
			/*if(n>0) s = new SymPlus();
			else */
			if (neg) {
				s = new SymMinus();
				d = s.width+2;
				g.addChild(s);
			}
			else if(n==0) throw new Error("ERROR - Card.addNumber received 0!!!!!!11!");
			
			//add the number
			switch(Math.abs(n)){
				case 1: s = new Sym1(); break;
				case 2: s = new Sym2(); break;
				case 3: s = new Sym3(); break;
				case 4: s = new Sym4(); break;
				case 5: s = new Sym5(); break;
				case 6: s = new Sym6(); break;
				case 10: s = new Sym10(); break;
				break;
			}
			s.x = d;
			d += s.width+3;
			g.addChild(s);

		}
		
		public function resetInTown(){
			inTown = false;
		}
		public function addedInTown(){
			inTown = true;
			//resetInEvent();
		}
		
		public function removeFromEvents(){
			inEventLine = false;
		}

		public function nullTown(){
			if(!inTown) throw new Error("Trying to destroy a card that is not in town");
			nulled = true;
			alpha = 0;
		}
		public function denullTown(){
			if(!inTown) throw new Error("Trying to rebuild a card that is not in town");
			nulled = false;
			alpha = 1;
		}
		
		public function turn(){
			//Registry.dlog("Card.turn");
			if(rotated) return;
			rotated = true;
			if(inTown) turnTown();
			else{
				animTurn.play();
			}
		}
		
		protected function turnTown(){
			//Registry.dlog("    .turnTown");
			//alpha = 0.5;			
			//mouseEnabled = false;
			if(mine) 
				paintBackground(0x333355);
			else
				paintBackground(0x553333);
		}
		
		public function straighten(){
			//Registry.dlog("Card.straighten");
			if(!rotated) return;
			rotated = false;
			if(inTown) straightenTown();
			else{
				animTurn.reverse();
			}
		}
		
		protected function straightenTown(){			
			//mouseEnabled = true;
			//Registry.dlog("    .straightenTown");			
			if(reserved){
				if(mine) 
					paintBackground(0xddddff);
				else
					paintBackground(0xffdddd);
			}
		}
		
		public function reserve(){
			//Registry.dlog("Card.reserve");
			reserved = true;
			mine = true;
			paintBackground(0xddddff);
		}
		
		public function unreserve(){
			//Registry.dlog("Card.unreserve");
			reserved = false;
			mine = false;
			paintBackground(color);
			straighten();			
		}
		
		public function resetExtraPX(){
			extraPX = 0;
			if(extraPX_1 != null && contains(extraPX_1)){
				removeChild(extraPX_1);
				extraPX_1 = null;
			}
			if(extraPX_2 != null && contains(extraPX_2)){
				removeChild(extraPX_2);
				extraPX_2 = null;
			}
		}
		public function getExtraPX():uint{return extraPX;}
		public function addExtraPX():uint{
			if(extraPX == 0){
				extraPX_1 = new SymPX();
				addChild(extraPX_1);
				extraPX_1.y = 35;
				extraPX_1.x = 5 + extraPX * 30;
			}else if(extraPX == 1){
				extraPX_2 = new SymPX();
				addChild(extraPX_2);
				extraPX_2.y = 35;
				extraPX_2.x = 5 + extraPX * 30;
			}			
			extraPX++;			
			return extraPX;
		}
		/*
		protected var preMult:uint = 1;
		public function getPreMult():uint{return preMult;}
		*/
		public function swapPlayers(){
			////Registry.dlog("Card.swapPlayers");
			if(reserved){
				mine = !mine;
				if(mine && rotated) paintBackground(0x333355);
				else if(mine) paintBackground(0xccccff);
				else if(!mine && rotated) paintBackground(0x553333);
				else paintBackground(0xffcccc);
			}
			else{
				paintBackground(0xffffff);
			}
		}
		
		protected function paintBackground(_color:uint = 0){
			graphics.clear();
			graphics.beginFill(_color);
			graphics.drawRect( 0 , 0 , Constants._CardWidth, Constants._CardHeight );
			graphics.endFill();
		}
		
		public function debugBackground(){
			graphics.beginFill(0x0000ff,0.5);
			graphics.drawRect(0,0,120,120);
			graphics.endFill();
		}
		
		public function destroy(){
			graphics.clear();
			removeEventListener(MouseEvent.CLICK, clickHandler);
			tfName = null;
			tfEffect = null;
			pre = null;
			post = null;
			animTurn = null;
		}
	}	
}
