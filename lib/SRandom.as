package lib{
	import flash.utils.ByteArray;

public class SRandom
	{
		// Fields
		private var _inext:int;
		private var _inextp:int;
		private const MBIG:int = 0x7fffffff;
		private const MSEED:int = 0x9a4ec86;
		private const MZ:int = 0;
		private var _seed:int;
		private var _seedArray:Vector.<int>;
		
		// Methods
		public function SRandom(seed:int)
		{
			_seed = seed;
			_seedArray = new Vector.<int>(0x38, true);
			var num2:int = 0x9a4ec86 - Math.abs(seed);
			_seedArray[0x37] = num2;
			var num3:int = 1;
			for (var i:int = 1; i < 0x37; i++)
			{
				var index:int = (0x15 * i) % 0x37;
				_seedArray[index] = num3;
				num3 = num2 - num3;
				if (num3 < 0)
				{
					num3 += 0x7fffffff;
				}
				num2 = _seedArray[index];
			}
			for (var j:int = 1; j < 5; j++)
			{
				for (var k:int = 1; k < 0x38; k++)
				{
					_seedArray[k] -= _seedArray[1 + ((k + 30) % 0x37)];
					if (_seedArray[k] < 0)
					{
						_seedArray[k] += 0x7fffffff;
					}
				}
			}
			_inext = 0;
			_inextp = 0x15;
			seed = 1;
		}
		
		public function get seed():int
		{
			return _seed;
		}
		
		private function getSampleForLargeRange():Number
		{
			var num:int = internalSample();
			if ((internalSample() % 2) == 0)
			{
				num = -num;
			}
			var num2:Number = num;
			num2 += 2147483646.0;
			return (num2 / 4294967293);
		}
		
		private function internalSample():int
		{
			var inext:int = _inext;
			var inextp:int = _inextp;
			if (++inext >= 0x38)
			{
				inext = 1;
			}
			if (++inextp >= 0x38)
			{
				inextp = 1;
			}
			var num:int = _seedArray[inext] - _seedArray[inextp];
			if (num < 0)
			{
				num += 0x7fffffff;
			}
			_seedArray[inext] = num;
			_inext = inext;
			_inextp = inextp;
			return num;
		}
		
		public function nextInt():int
		{	
			return internalSample();
		}
		
		public function nextMax(maxValue:int):int
		{
			if (maxValue < 0)
			{
				throw new ArgumentError("Argument \"maxValue\" must be positive.");
			}
			return int(sample() * maxValue);
		}
		
		public function nextMinMax(minValue:int, maxValue:int):int
		{
			if (minValue > maxValue)
			{
				throw new ArgumentError("Argument \"minValue\" must be less than or equal to \"maxValue\".");
			}
			var num:Number = maxValue - minValue;
			if (num <= 0x7fffffff)
			{
				return (((int) (sample() * num)) + minValue);
			}
			return (((int) (Number(getSampleForLargeRange() * num))) + minValue);
		}
		
		public function nextBytes(buffer:ByteArray, length:int):void
		{
			if (buffer == null)
			{
				throw new ArgumentError("Argument \"buffer\" cannot be null.");
			}
			for (var i:int = 0; i < length; i++)
			{
				buffer.writeByte(internalSample() % 0x100);
			}
		}
		
		public function nextNumber():Number
		{
			return sample();
		}
		
		protected function sample():Number
		{
			return (internalSample() * 4.6566128752457969E-10);
		}
	}
}