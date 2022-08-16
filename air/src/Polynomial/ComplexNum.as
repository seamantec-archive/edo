/*
Copyright (c) 2011, Timothy Atkinson
All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met:
- Redistributions of source code must retain the above copyright notice, 
  this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING 
IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY 
OF SUCH DAMAGE.
*/

package Polynomial
{
	/**
	 * This class stores a number of the form: a + b*i where i is square root 
	 * of -1.  
	 * 
	 * It allows the user to +,-,*,/.  As well as compute a few other handy
	 * functions like the sqrt, distance, conjecate (a - b*i).
	 */
	public class ComplexNum
	{
		static public const negOne:ComplexNum = new ComplexNum(-1);
		static public const one:ComplexNum = new ComplexNum(1);
		static public const zero:ComplexNum = new ComplexNum();
		
		public function ComplexNum(real:Number = 0, imag:Number = 0)
		{
			this.real = real;
			this.imag = imag;
		}
		
		public var real:Number;
		public var imag:Number;
		
		public function toString():String
		{
			return real + " + " + imag+"i";
		}
		
		public function add(b:ComplexNum):ComplexNum
		{
			var ret:ComplexNum = new ComplexNum();
			
			ret.real = real + b.real;
			ret.imag = imag + b.imag;
			
			return ret;
		}
		
		public function sub(b:ComplexNum):ComplexNum
		{
			var ret:ComplexNum = new ComplexNum();
			
			ret.real = real - b.real;
			ret.imag = imag - b.imag;
			
			return ret;
		}
		
		public function multiply(b:ComplexNum):ComplexNum
		{
			var ret:ComplexNum = new ComplexNum();
			
			ret.real = real * b.real - imag * b.imag;
			ret.imag = real * b.imag + b.real * imag;
			
			return ret;
		}
		
		public function divide(b:ComplexNum):ComplexNum
		{
			var ret:ComplexNum = new ComplexNum();
			
			var r:Number;
			var d:Number;
			
			if (Math.abs(b.real) < Math.abs(b.imag))
			{
				r = b.real / b.imag;
				d = b.imag + r * b.real;
				ret.real = (real * r + imag) / d;
				ret.imag = (imag * r - real) / d;
				return ret;
			} else
			{
				r = b.imag / b.real;
				d = b.real + r*b.imag;
				ret.real = (real + imag * r)/d;
				ret.imag = (imag - real * r)/d;
				return ret;
			}
		}
		
		public function equals(b:ComplexNum):Boolean
		{
			if (real == b.real && imag == b.imag)
				return true;
			else
				return false;
		}
		
		public function clone():ComplexNum
		{
			var ret:ComplexNum = new ComplexNum();
			ret.real = real;
			ret.imag = imag;
			return ret;
		}
		
		public function conjecate():ComplexNum
		{
			var ret:ComplexNum = new ComplexNum();
			ret.real = real;
			ret.imag = -imag;
			return ret;
		}
		
		public function dist():Number
		{
			var ar:Number = Math.abs(real);
			var ai:Number = Math.abs(imag);
			if (ar < ai)
				return ai * Math.sqrt(1 + Math.pow( ar/ai, 2));
			
			if (ar > ai)
				return ar * Math.sqrt(1 + Math.pow( ai/ar, 2));
			
			return ar * Math.SQRT2;
		}
		
		public function sqrt():ComplexNum
		{
			var ret:ComplexNum = new ComplexNum();
			
			var theta:Number = Math.atan2(imag, real);
			var sqrtR:Number = dist();
			
			ret.real = sqrtR*Math.cos(theta/2);
			ret.imag = sqrtR*Math.sin(theta/2);
			
			return ret; 
		}
	}
}