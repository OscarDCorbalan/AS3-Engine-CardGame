package as3.data{
	import flash.utils.ByteArray;
	import mx.core.ByteArrayAsset;
	import as3.presentation.cards.*;
	import as3.Registry;
	import as3.Constants;
	import lib.Helpers;
	public class Deck {
		
		
		[Embed(source="/assets/Cards.xml", mimeType="application/octet-stream")] protected const EmbeddedXML:Class;
		protected var xml:XML = new XML();
		protected var language:uint;
		
		public function Deck(l:uint) {
			Registry.screenLog.appendText("Deck - loading XML file\n");
			trace("Loading cards deck");
			language = l;
			xml = Helpers.loadFromXML(EmbeddedXML);
			Registry.screenLog.appendText("");
		}
		
		public function initCardsTown(t:Array){
			Registry.screenLog.appendText("Deck - creating town cards...\n");
			trace("Parsing Town Cards.xml");
			var _pre:Vector.<int>, _post:Vector.<int>;
			
			for(var i:int = 0; i < 9; i++){
				t[i] = new TownCard();
				t[i].setImage(xml.towncards.card[i].pic);
				_pre = parseEffect(xml.towncards.card[i].effect.pre.children());
				_post = parseEffect(xml.towncards.card[i].effect.post.children());
				t[i].init2(xml.towncards.card[i].id, parseTitle(xml.towncards.card[i].title), 0xffffff, _pre, _post);				
			}
		}
		
		
		public function initPlayerDeck(t:Array, color:uint = 0xddddff){
			Registry.screenLog.appendText("Deck - creating player cards...\n");
			trace("Parsing Player Cards.xml");
			var _pre:Vector.<int>, _post:Vector.<int>;
			for(var i:int = 0; i < 9; i++){
				//trace(xml.playercards.card[i].id);
				t[i] = new GameCard();
				t[i].setImage(xml.playercards.card[i].pic);
				_pre = parseEffect(xml.playercards.card[i].effect.pre.children());
				_post = parseEffect(xml.playercards.card[i].effect.post.children());
				t[i].init2(xml.playercards.card[i].id,
						   parseTitle(xml.playercards.card[i].title),
						   color,
						   xml.playercards.card[i].ini,
						   _pre,
						   _post);
			}
		}
		
		public function initOpponentDeck(t:Array){
			initPlayerDeck(t, 0xffdddd);
		}
		
		public function initEventDeck(t:Array){
			Registry.screenLog.appendText("Deck - creating quest cards...\n");
			trace("Parsing Table Cards.xml");
			var u:Card;
			var _pre:Vector.<int>, _post:Vector.<int>;
			var card:XML;
			for each(card in xml.gamecards.tier1.card){
				if(card.type == "Quest"){
					u = new QuestCard();					
					u.setImage(card.pic);
					_pre = parseEffect(card.effect.pre.children());
					_post = parseEffect(card.effect.post.children());
					(u as QuestCard).init3(card.id, parseTitle(card.title), 0xffffff, card.ini, card.buycost, _pre, _post);
				}else if (card.type == "Tether"){
					u = new TetherCard();
					_pre = parseEffect(card.effect.pre.children());
					_post = parseEffect(card.effect.post.children());
					(u as TetherCard).init2(card.id, parseTitle(card.title), 0xffffff, card.ini, null, null);
				}
				t.push(u);
			}
			for each(card in xml.gamecards.tier2.card){
				trace(card.id);
				if(card.type == "Quest"){
					u = new QuestCard();
					u.setImage(card.pic);
					_pre = parseEffect(card.effect.pre.children());
					_post = parseEffect(card.effect.post.children());
					(u as QuestCard).init3(card.id, parseTitle(card.title), 0x99ff99, card.ini, card.buycost, _pre, _post);
				}else if (card.type == "Tether"){
					u = new TetherCard();
					_pre = parseEffect(card.effect.pre.children());
					_post = parseEffect(card.effect.post.children());
					(u as TetherCard).init2(card.id, parseTitle(card.title), 0x99ff99, card.ini, null, null);
				}
				t.push(u);
			}
			for each(card in xml.gamecards.tier3.card){
				if(card.type == "Quest"){
					u = new QuestCard();
					u.setImage(card.pic);
					_pre = parseEffect(card.effect.pre.children());
					_post = parseEffect(card.effect.post.children());
					(u as QuestCard).init3(card.id, parseTitle(card.title), 0xffff66, card.ini, card.buycost, _pre, _post);
				}else if (card.type == "Tether"){
					u = new TetherCard();
					_pre = parseEffect(card.effect.pre.children());
					_post = parseEffect(card.effect.post.children());
					(u as TetherCard).init2(card.id, parseTitle(card.title), 0xffff66, card.ini, null, null);
				}
				t.push(u);
			}
			for each(card in xml.gamecards.tier4.card){
				if(card.type == "Quest"){
					u = new QuestCard();
					u.setImage(card.pic);
					_pre = parseEffect(card.effect.pre.children());
					_post = parseEffect(card.effect.post.children());
					(u as QuestCard).init3(card.id, parseTitle(card.title), 0xdd7777, card.ini, card.buycost, _pre, _post);
				}else if (card.type == "Tether"){
					u = new TetherCard();
					_pre = parseEffect(card.effect.pre.children());
					_post = parseEffect(card.effect.post.children());
					(u as TetherCard).init2(card.id, parseTitle(card.title), 0xdd7777, card.ini, null, null);
				}
				t.push(u);
			}
		}
		
		protected function parseTitle(e:XMLList):String{
			switch(language){
				case Constants.L_ENG:
					return e.ENG.valueOf();
				case Constants.L_ESP:
					return e.ES.valueOf();
				case Constants.L_CAT:
					return e.CAT.valueOf();
				default:
					return "ERROR";
			}
		}
		protected function parseEffect(e:XMLList):Vector.<int>{
			var v:Vector.<int> = new Vector.<int>(Constants.VLENGTH);
			if(e.length() == 0){
				v[Constants.V_EMPTY] = 1;
			}
			else{
				//trace("e", e);
				if(e.length() > 1) v[Constants.V_AND] = 1;
				for each (var node:XML in e) { 
					//trace(node.name());
					switch(node.name().toString()){
						case "money": 		v[Constants.V_MONEY] = node.valueOf();		break;
						case "px":			v[Constants.V_PX] = node.valueOf();			break;
						case "discard":		v[Constants.V_DISCARD] = node.valueOf();	break;
						case "drawcard":	v[Constants.V_DRAW] = node.valueOf();		break;
						case "cart":		v[Constants.V_CART] = node.valueOf();		break;
						case "follower":	v[Constants.V_FOLLOWER] = node.valueOf();	break;
						case "garbage":		v[Constants.V_GARBAGE] = node.valueOf();	break;
						case "doubleuse":	v[Constants.V_DOUBLE_USE] = 1;	break;
						case "doublegold":	v[Constants.V_DOUBLE_GOLD] = 1;	break;
						case "doublepx":	v[Constants.V_DOUBLE_PX] = 1;	break;
						case "savehand":	v[Constants.V_SAVE_HAND] = 1;	break;
						case "nulltown":	v[Constants.V_NULLTOWN] = 1;	break;
						case "or":			
							v[Constants.V_OR] = 1;
							v[Constants.V_AND] = 0;
							break;
						default:
					}
				}
			}
			//trace(v);
			return v;
		}

	}
	
}
