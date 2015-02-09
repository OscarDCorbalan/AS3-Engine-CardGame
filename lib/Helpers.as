package lib {
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import mx.core.ByteArrayAsset;

	public class Helpers {
		protected static const debug:Boolean = false;
		
		public function Helpers() {
			// constructor code
		}
		
		/*public static function clone(source:Object):*{
    		var myBA:ByteArray = new ByteArray();
    		myBA.writeObject(source);
    		myBA.position = 0;
    		return(myBA.readObject());
		}*/
		
		public static function loadFromXML(EmbeddedXML:Class):XML{
			var contentfile:ByteArrayAsset = new EmbeddedXML();
			var contentstr:String = contentfile.readUTFBytes( contentfile.length );
			return new XML( contentstr );	
		}
		
		//sets given TextField with the given text, coordinates and format
		//then adds it to father if the parameter exists
		public static function initTextField(field:TextField, txt:String, 
											 xx:int, yy:int, 
											 w:uint, h:uint,
											 format:TextFormat, 
											 father:Object = null){
			field.x = xx;
			field.y = yy;
			field.width = w;
			field.height = h;
			field.selectable = false;
			field.embedFonts = true;
			if(debug){
				debugTextField(field);				
			}
			if(father != null)
				father.addChild(field);
				
			field.text = txt;						
			field.setTextFormat(format);
		}
		
		public static function addMCat(c:DisplayObject, xx:uint, yy:uint, p:MovieClip){
			c.x = xx;
			c.y = yy;
			p.addChild(c);
		}
		
		protected static function debugTextField(f:TextField){
			f.background = true;
			f.backgroundColor = 0x77eecc00;
		}
		
		public static function indexOf(source:Array, _var:*, startPos:int = 0):int {
			var len:int = source.length;
			for (var i:int = startPos; i < len; i++) 
				if (filterCardID(source[i],_var))
					return i;
			return -1;
		}

		protected static function filterCardID(val:Card,_id:uint):Boolean { 
			return val.getID() == _id; 
		}
	}
	
}
