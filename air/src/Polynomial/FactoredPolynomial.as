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
	 * The factored polynomial is a polynomial which is tracked by its zeros 
	 * instead of its coefficients.  It can be more accurate for certain 
	 * calculations than a standard polynomail but it can't be added or 
	 * subtracted from each.  During these events, a standard polynomial
	 * is returned in its stead
	 */
	public class FactoredPolynomial implements IPolynomial
	{
		public static const zero:FactoredPolynomial = new FactoredPolynomial(null, ComplexNum.zero);
		public static const one:FactoredPolynomial = new FactoredPolynomial(null, ComplexNum.one);
		
		public var zeros:Array;
		public var multiplier:ComplexNum;
		
		public function FactoredPolynomial(zeros:Array = null, multiplier:ComplexNum = null)
		{
			//if multipler is 0; zero out the zeros array
			if (multiplier != null && multiplier.real == 0 && multiplier.imag == 0)
				zeros = null;
			
			if (zeros == null)
				this.zeros = new Array();
			else
				this.zeros = zeros;
			
			if (multiplier == null && zeros == null)
				this.multiplier = new ComplexNum(0);
			else if (multiplier == null) 
				this.multiplier = new ComplexNum(1);
			else
				this.multiplier = multiplier;
		}
		
		static public function factorPolynomial(poly:IPolynomial):FactoredPolynomial
		{
			//if polynomial is already factored just return it
			if (poly is FactoredPolynomial)
			{
				return poly as FactoredPolynomial;
			}
			
			//convert to standar form first
			var tmp:StandardPolynomial = poly.toStandardForm().clone() as StandardPolynomial;
			var multiplier:ComplexNum = tmp.getMultiplier(); 
			tmp.divideNum(multiplier);
			
			return new FactoredPolynomial(tmp.calcZeros(), multiplier);
		}
		
		/**
		 * evaluate teh polynomial at x
		 */
		public function eval(x:ComplexNum):ComplexNum
		{
			var i:int;
			var ret:ComplexNum = multiplier;
			
			for (i=0; i<zeros.length; i++)
			{
				ret = ret.multiply(x.sub(zeros[i]));
			}
			return ret;
		}
		
		public function divideNum(num:ComplexNum):void
		{
			multiplier = multiplier.divide(num);
		}
		
		public function multiplyNum(num:ComplexNum):void
		{
			multiplier = multiplier.multiply(num);
		}
		
		/**
		 * Returns a multiplier that would result in the polynomial in the form
		 */
		public function getMultiplier():ComplexNum
		{
			return multiplier;
		}
		
		/**
		 * computes this + b.  Note this returns a standard polynomial because
		 * factored polynomials are terrible at adding
		 */
		public function add(b:IPolynomial):IPolynomial
		{
			var tmp:StandardPolynomial = toStandardForm();
			return tmp.add(b);
		}
		
		/**
		 * computes this - b.  Note this returns a standard polynomial because
		 * factored polynomials are terrible at multipling
		 */
		public function sub(b:IPolynomial):IPolynomial
		{
			var tmp:StandardPolynomial = toStandardForm();
			return tmp.sub(b);
		}
		
		/**
		 * computes this * b.  
		 */
		public function multiply(b:IPolynomial):IPolynomial
		{
			var bM:FactoredPolynomial = factorPolynomial(b);
			
			return new FactoredPolynomial(zeros.concat(bM.zeros), multiplier.multiply(bM.multiplier));
		}
		
		/**
		 * computes this/b.  The quotiant is returned in index 0 and the 
		 * remaineder is returned in index 1
		 */
		public function divide(b:IPolynomial):Array
		{
			var bM:FactoredPolynomial = factorPolynomial(b);
			var quotient:FactoredPolynomial = FactoredPolynomial.one.clone() as FactoredPolynomial;
			var remainder:FactoredPolynomial;// = FactoredPolynomial.zero.clone();
			var foundNum:Array = new Array(zeros.length);
			var foundDen:Array = new Array(bM.zeros.length);
			var i:int;
			var j:int;
			
			//check for 0/x or x/0 (divide by zero is technically undefined)
			if(bM.multiplier.equals(ComplexNum.zero) || multiplier.equals(ComplexNum.zero))
				return [FactoredPolynomial.zero, FactoredPolynomial.zero];
		
			//check for linear formulas
			quotient.multiplier = multiplier.divide(bM.multiplier);
			
			if (zeros == null && bM.zeros == null)
				return [quotient, FactoredPolynomial.zero];
			if (zeros == null)
				return [quotient, new FactoredPolynomial(bM.zeros)];
			if (bM.zeros ==null)
			{
				quotient.zeros = bM.zeros;
				return [quotient, FactoredPolynomial.zero];
			}
			
			remainder = FactoredPolynomial.one.clone() as FactoredPolynomial;
			
			for (i=0; i<zeros.length; i++)
				foundNum[i] = false;
			for (i=0; i<bM.zeros.length; i++)
				foundDen[i] = false;
		
			for (i=0; i<bM.zeros.length; i++)
			{
				for (j=0; j<zeros.length; j++)
				{
					if (foundNum[j])
						continue;
					
					if (zeros[j].equals(bM.zeros[i]))
					{
						foundDen[i] = true;
						foundNum[j] = true;
						break;
					}
				}
			}
		 
			for (i=0; i<zeros.length; i++)
			{
				if (!foundNum[i])
					quotient.zeros.push(zeros[i]);
			}
			for (i=0; i<bM.zeros.length; i++)
			{
				if (!foundDen[i])
					remainder.zeros.push(bM.zeros[i]);
			}
			
			return [quotient, remainder];
		}
		
		/**
		 * Returns the polynomial in standard form
		 */
		public function toStandardForm():StandardPolynomial
		{
			var ret:IPolynomial = StandardPolynomial.one;
			var tmp:StandardPolynomial = new StandardPolynomial([ComplexNum.zero, ComplexNum.one]);
			var i:int;
			
			if (zeros != null)
			{
				for (i=0; i<zeros.length; i++)
				{
					tmp.coefficients[0] = zeros[i].multiply(ComplexNum.negOne);
					ret = ret.multiply(tmp);
				}
				
				ret.multiplyNum(multiplier);
			} else
			{
				return new StandardPolynomial([multiplier]);
			}
			return ret as StandardPolynomial;
		}
		
		/**
		 * Attempts to find the zeros of the polynomial.
		 * 
		 * assumedPrecision - number of digits the zero is asummed to have.  The
		 *                    implementor can ignore this parameter if its
		 *                    algorithm doesn't need the help.
		 */
		public function calcZeros(assumedPrecision:int=6):Array
		{
			return zeros;
		}
		
		
		/**
		 * Is b equal to this?
		 */
		public function equals(b:IPolynomial):Boolean
		{
			var t:FactoredPolynomial;
			if (b is FactoredPolynomial)
			{
				t = b as FactoredPolynomial;
			} else
			{
				t = factorPolynomial(b);	
			}
			
			if (!t.multiplier.equals(multiplier))
				return false;
			
			if (t.zeros == null && zeros == null)
				return true;
			
			if (t.zeros != null && zeros == null)
				return false;
			
			if (t.zeros == null && zeros != null)
				return false;
			
			if (t.zeros.length != zeros.length)
				return false;
			
			for (var i:int = 0; i<t.zeros.length; i++)
			{
				if (!t.zeros[i].equals(zeros[i]))
					return false;
			}
			
			return true;
		}
		
		/**
		 * returns a string representation of the polynomial
		 */
		public function toString():String
		{
			var ret:String = "";
			var i:int;
			
			if (multiplier.imag == 0)
				ret += multiplier.real;
			else
				ret += "(" + multiplier.real + " + " + multiplier.imag+"i)";
			
			for (i=0; i<zeros.length; i++)
			{
				ret += "(x ";
				if (zeros[i].real < 0)
					ret += "- " + Math.abs(zeros[i].real);
				else if (zeros[i].real > 0)
					ret += "+ " + zeros[i].real;
				
				if (zeros[i].imag < 0)
					ret += "- " + Math.abs(zeros[i].imag) +"i";
				else if (zeros[i].imag > 0)
					ret += "+ " + zeros[i].imag + "i";
				
				ret += ")";
			}
			
			return ret;
		}
		
		/**
		 * returns a clone of the polynomial
		 */
		public function clone():IPolynomial
		{
			var ret:FactoredPolynomial = new FactoredPolynomial();
			ret.multiplier = multiplier.clone();
			ret.zeros = zeros.concat();
			return ret;
		}
	}
}