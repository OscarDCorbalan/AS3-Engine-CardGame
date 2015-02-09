package as3.data {
	import as3.Registry;
	import flash.net.Socket;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import as3.domain.GameEvent;
	import as3.domain.GameVars;
	
	public class SocketLord extends EventDispatcher {
		protected const terminator:String = "0123456789";
		protected var _beenVerified:Boolean = false;
		protected var serverIP:String = "localhost";
		protected var serverPort:uint = 8000;
		protected var s:Socket = new Socket();
		protected var buffer:ByteArray = new ByteArray();
		protected var buffLen:uint = 0;
		protected var gv:GameVars;
		
		protected var timer:Timer;
		protected var outgoing:Array = new Array();
		protected var ack:Boolean = true;
		
		public function SocketLord(_gv:GameVars) {			
			gv = _gv;
			s.addEventListener(IOErrorEvent.IO_ERROR, handlerIO_Error);
			s.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handlerSecurity_Error);
			s.addEventListener(Event.CONNECT, handlerConnect);
			s.connect(serverIP, serverPort);
			
		}
		
		public function destroy(){
			s.close();
			timer.removeEventListener(TimerEvent.TIMER, handlerOut)
			s.removeEventListener(IOErrorEvent.IO_ERROR, handlerIO_Error);
			s.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handlerSecurity_Error);
			s.removeEventListener(ProgressEvent.SOCKET_DATA, handlerTCP);
		}
		
		protected function handlerConnect(e:Event){
			//Registry.screenLog.appendText("Succesfully connected to server");
			s.removeEventListener(Event.CONNECT, handlerConnect);
			s.addEventListener(ProgressEvent.SOCKET_DATA, handlerTCP);
			
			timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER, handlerOut);
			timer.start();
			//trace("DASDADASDASDASDADASDASDASDAS",ack,ack,ack,ack,ack,ack,ack);
		}
		
		protected function handlerOut(e:TimerEvent){
			//gv.dlog("SocketLord.handlerOut " +ack+" "+outgoing.length+" "+outgoing[0]);
			if(!ack) return;
			if(outgoing.length == 0) return;			
			
			gv.dlog("SocketLord.handlerOut " + outgoing[0]);
			s.writeUTFBytes(outgoing.shift());					
			s.flush();
			//trace("22222222222222222222222222222222222222222222222222222",ack,ack,ack,ack,ack,ack,ack);
			
			ack = false;
		}
		
		protected function handlerTCP(e:ProgressEvent){
			//gv.dlog("SocketLord.handlerTCP");
			var _l:uint = s.bytesAvailable;
			if(_beenVerified)
			{
				buffer.writeUTFBytes(s.readUTFBytes(_l));
				if(buffer.length >= 4 && buffLen == 0){
					//we're expecting a new packet				
					buffer.position = 0;
					buffLen = uint(buffer.readUTFBytes(4));
					buffer.position = _l;
				}
				else{
					//we're completing a fragmented packet					
				}
				//trace("  SOCKET received:", buffer.toString());			
			
				if(buffer.length == buffLen){
					//packet completed
					//trace("  SOCKET current packet finished");
					processPayload();
					buffer.clear();
					buffLen = 0;
				}
				else if(buffer.length > buffLen){
					this.write(buffer.toString());
					throw new Error("Handler TCP buffer overflown");
				}
			}
			else
			{				
				_beenVerified = true;
				trace(s.readUTFBytes(_l));
				s.writeUTFBytes("OK");
				s.flush();
			}
		}

		
		protected function handlerSecurity_Error(e:SecurityErrorEvent){
			gv.dlog("SocketLord.handlerSecurity_Error");
		}
		
		protected function handlerIO_Error(e:IOErrorEvent){
			gv.dlog("SocketLord.handlerIO_Error");
		}
		
		protected function processPayload(){
			//gv.dlog("SocketLord.processPayload\n   " + buffer.toString());
			buffer.position = 4;
			var _evt:RemoteEvent;
			var msg:String;
			var sss:String = buffer.readUTFBytes(4)
			switch(sss){
				case "Seed":
					msg = "SL dispatching ON_SEED_READY";
					_evt = new RemoteEvent(RemoteEvent.ON_SEED_READY);
					_evt.eventMessage = buffer.readUTFBytes(4);
					_evt.id = 1+uint(buffer.readUTFBytes(4));
					break;
				case "Plan":
					ack = true;
					if(buffLen > 8){
						msg = "SL dispatching ON_TURN_PLAN_2";
						_evt = new RemoteEvent(RemoteEvent.ON_TURN_PLAN_2);
						_evt.id = uint(buffer.readUTFBytes(4));
					}
					else{
						msg = "SL dispatching ON_TURN_PLAN_1";
						_evt = new RemoteEvent(RemoteEvent.ON_TURN_PLAN_1);
					}
					break;
				case "PlSy":
					msg = "SL dispatching ON_TURN_PLAN_SYNC";
					_evt = new RemoteEvent(RemoteEvent.ON_TURN_PLAN_SYNC);
					_evt.id = uint(buffer.readUTFBytes(4));
					break;				
				case "TSBu":
					msg = "SL dispatching ON_TURN_SYNC_BUY";
					_evt = new RemoteEvent(RemoteEvent.ON_TURN_SYNC_BUY);
					_evt.id = uint(buffer.readUTFBytes(4));
					_evt.num = uint(buffer.readUTFBytes(4));
					break;
				case "TSNu":
					msg = "SL dispatching ON_TURN_SYNC_NULLTOWN";
					_evt = new RemoteEvent(RemoteEvent.ON_TURN_SYNC_NULLTOWN);
					_evt.id = uint(buffer.readUTFBytes(4));
					break;					
				case "TSPC":
					msg = "SL dispatching ON_TURN_SYNC_PRE_CLICK";
					_evt = new RemoteEvent(RemoteEvent.ON_TURN_SYNC_PRE_CLICK);
					_evt.id = uint(buffer.readUTFBytes(4));	
					_evt.choice = uint(buffer.readUTFBytes(4));
					break;	
				case "TSPE":
					msg = "SL dispatching ON_TURN_SYNC_PRE_END";
					_evt = new RemoteEvent(RemoteEvent.ON_TURN_SYNC_PRE_END);
					_evt.id = uint(buffer.readUTFBytes(4));	
					_evt.choice = uint(buffer.readUTFBytes(4));
					_evt.num = uint(buffer.readUTFBytes(4));
					break;
				case "TSPF":
					msg = "SL dispatching ON_TURN_SYNC_PRE";
					_evt = new RemoteEvent(RemoteEvent.ON_TURN_SYNC_PRE);
					_evt.id = uint(buffer.readUTFBytes(4));
					_evt.choice = uint(buffer.readUTFBytes(4));
					_evt.eventMessage = buffer.readUTFBytes(4);
					break;
				case "TSPS":
					msg = "SL dispatching ON_TURN_SYNC_PRE_START";
					_evt = new RemoteEvent(RemoteEvent.ON_TURN_SYNC_PRE_START);
					_evt.id = uint(buffer.readUTFBytes(4));
					break;			
				case "TSRe":
					msg = "SL dispatching ON_TURN_SYNC_REUSE";
					_evt = new RemoteEvent(RemoteEvent.ON_TURN_SYNC_REUSE);
					_evt.eventMessage = buffer.readUTFBytes(4);
					break;	
				case "TSSH":
					msg = "SL dispatching ON_TURN_SYNC_SAVE_HAND";
					_evt = new RemoteEvent(RemoteEvent.ON_TURN_SYNC_SAVE_HAND);
					_evt.id = uint(buffer.readUTFBytes(4));
					break;	
				case "TSyn":
					msg = "SL dispatching ON_TURN_SYNC";
					_evt = new RemoteEvent(RemoteEvent.ON_TURN_SYNC);
					_evt.id = uint(buffer.readUTFBytes(4));
					_evt.choice = uint(buffer.readUTFBytes(4));
					_evt.eventMessage = "Sync";
					break;
				case "STRT":
				case "TEND":
					msg = "SL dispatching ON_TURN_START";
					_evt = new RemoteEvent(RemoteEvent.ON_TURN_START);
					if(sss=="STRT") _evt.eventMessage = "First";
					break;				
				case "thxy":
					ack = true;
					return;
				case "GWON":
					var e:GameEvent = new GameEvent(GameEvent.ON_WIN);
					e.u1 = uint(buffer.readUTFBytes(4));
					e.u2 = uint(buffer.readUTFBytes(4));
					e.u3 = uint(buffer.readUTFBytes(4));
					e.u4 = uint(buffer.readUTFBytes(4));
					e.id = uint(buffer.readUTFBytes(4));
					dispatchEvent(e);
					return;
				default:
					throw new Error("Socket error: packet unrecognized");
			}
			if(sss != "Seed" && sss != "Plan" && sss!="PlSy"){
				s.writeUTFBytes("0008thxy");
				s.flush();
			}
			gv.dlog(msg);
			dispatchEvent(_evt);
		}
		
		protected function write(_data:String){
			//gv.dlog("enqueuing in socket " + _data);
			outgoing.push(_data);
		}
		
		public function readyToStart(){
			gv.dlog("SL readyToStart");
			s.writeUTFBytes("ACKSeed");
			s.flush();
		}
		
		public function won(p1:uint, d1:uint, p2:uint, d2:uint,won:uint){
			write("0028GWON"+uToString(p1)+uToString(d1)+uToString(p2)+uToString(d2)+uToString(won));
		}
		public function reuseMode(b:Boolean){
			if(b) write("0012TSRe0001");
			else write("0012TSRe0000");
		}
		public function endPlan(id:uint,ini:uint){
			//gv.dlog("SocketLord.endPlan");
			var st:String;
			if (id==0) st = "PE";
			else{
				st = "PE#"+id+"#"+ini;
			}
			s.writeUTFBytes(st);
			s.flush();
		}
		
		public function endTurn(){
			//gv.dlog("SocketLord.endTurn");
			write("0008TEND");
		}
		public function journeyEnd(){
			//gv.dlog("SocketLord.journeyEnd");
			write("JEND");
			/*s.writeUTFBytes("JEND");
			s.flush();*/
		}
		public function playCard(id:uint, o:uint){
			//gv.dlog("SocketLord.playCard");
			var _id:String = uToString(id);
			var _or:String = uToString(o);
			write("0016TSyn"+_id+_or);
		}
		
		public function playCardPre(id:uint, n:uint, type:uint){
			var _id:String = uToString(id);
			var _n:String = uToString(n);
			var _t:String = uToString(type);
			write("0020TSPF"+_id+_n+_t);
		}
		
		public function playCardPreStart(id:uint){
			var _id:String = uToString(id);
			write("0012TSPS"+_id);
		}
		
		public function playCardPreClick(id:uint, type:uint){
			var _id:String = uToString(id);
			var _t:String = uToString(type);
			write("0016TSPC"+_id+_t);
		}
		public function playCardPreEnd(id:uint, type:uint, actions:uint){
			var _id:String = uToString(id);
			var _t:String = uToString(type);
			var _a:String = uToString(actions);
			write("0020TSPE"+_id+_t+_a);
		}
		public function buyCard(id:uint, cost:uint = 0){
			write("0016TSBu"+uToString(id)+uToString(cost));
		}		
		public function nulltown(id:uint){
			write("0012TSNu"+uToString(id));
		}
		public function saveHand(id:uint){
			write("0012TSSH"+uToString(id));
		}
		protected function uToString(n:uint):String{
			if(n < 10) return "000"+n;
			if(n < 100) return "00"+n;
			if(n < 1000) return "0"+n;
			throw new Error("SocketLord.uToString overflow " +n);
		}
	}
	
}
