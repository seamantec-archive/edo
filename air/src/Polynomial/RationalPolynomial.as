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
	 * This class represents a rational polynomial i.e. f(x)/g(x) where both
	 * f(x) and g(x) are polynomials.  
	 */
	public class RationalPolynomial
	{
		public static const zero:RationalPolynomial = new RationalPolynomial();
		public static const one:RationalPolynomial = new RationalPolynomial(FactoredPolynomial.one, FactoredPolynomial.one);
		
		public function RationalPolynomial(numerator:IPolynomial = null, denonimantor:IPolynomial = null)
		{
			if (numerator == null)
				this.numerator = FactoredPolynomial.zero;
			else
				this.numerator = FactoredPolynomial.factorPolynomial(numerator);
			
			if (denonimantor == null)
				this.denominator = FactoredPolynomial.one;
			else
				this.denominator = FactoredPolynomial.factorPolynomial(denonimantor);
		}
		
		public var numerator:FactoredPolynomial;
		public var denominator:FactoredPolynomial;
		
		/**
		 * evaluates the rational polynomial at a point x
		 */
		public function eval(x:ComplexNum):ComplexNum
		{
			return numerator.eval(x).divide(denominator.eval(x));
		}
		
		/**
		 * Reduces the rational polynomial by removing zeros that exist in both
		 * the numerator and denominator.
		 */
		public function reduce():void
		{
			var result:Array;
					
			result = numerator.divide(denominator);
			numerator = result[0];
			denominator = result[1];
		}
		
		/**
		 * Adds two rational polynomials togther.  The formula looks like:
		 *   f/g + h/i = (fi+hg)/(gi)
		 */
		public function add(b:RationalPolynomial):RationalPolynomial
		{
			var ret:RationalPolynomial  = new RationalPolynomial();
			ret.numerator = FactoredPolynomial.factorPolynomial(numerator.multiply(b.denominator).add(b.numerator.multiply(denominator)));
			ret.denominator = denominator.multiply(b.denominator) as FactoredPolynomial;
			ret.reduce();
			return ret;
		}
		
		/**
		 * Subtracts two rational polynomials togther.  The formula looks like:
		 *   f/g - h/i = (fi-hg)/(gi)
		 */
		public function sub(b:RationalPolynomial):RationalPolynomial
		{
			var ret:RationalPolynomial  = new RationalPolynomial();
			ret.numerator = FactoredPolynomial.factorPolynomial(numerator.multiply(b.denominator).sub(b.numerator.multiply(denominator)));
			ret.denominator = denominator.multiply(b.denominator) as FactoredPolynomial;
			ret.reduce();
			return ret;			
		}
		
		/**
		 * Multiplies two rational polynomials togther.  The formula looks like:
		 *   (f/g) * (h/i) = (fh)/(gi)
		 */
		public function multiply(b:RationalPolynomial):RationalPolynomial
		{
			var ret:RationalPolynomial  = new RationalPolynomial();
			ret.numerator = numerator.multiply(b.numerator) as FactoredPolynomial;
			ret.denominator = denominator.multiply(b.denominator) as FactoredPolynomial;
			ret.reduce();
			return ret;			
		}
		
		/**
		 * Multiplies two rational polynomials togther.  The formula looks like:
		 *   (f/g) / (h/i) = (fi)/(gh)
		 */
		public function divide(b:RationalPolynomial):RationalPolynomial
		{
			var ret:RationalPolynomial  = new RationalPolynomial();
			ret.numerator = numerator.multiply(b.denominator) as FactoredPolynomial;
			ret.denominator = denominator.multiply(b.numerator) as FactoredPolynomial;
			ret.reduce();
			return ret;			
		}
		
		/**
		 * This function calculates the zeros of the rational polynomial by
		 * calculating the zeros of the numerator and returning those.
		 * 
		 * assumedPrecision - number digits the zero is assumed to have.  See
		 *                    polynomial calcZeros for more information
		 */
		public function calcZeros(assumedPrecision:int = 6):Array
		{
			return numerator.calcZeros(assumedPrecision);
		}
		
		/**
		 * This function calculates the poles (undefined point surrounded by 
		 * asymoptes) of the rational polynomial by calculating the zeros of 
		 * the denominator and returning those.
		 * 
		 * assumedPrecision - number digits the zero is assumed to have.  See
		 *                    polynomial calcZeros for more information
		 */
		public function calcPoles(assumedPrecision:int = 6):Array
		{
			return denominator.calcZeros(assumedPrecision);
		}
		
		/**
		 * Calculates the derivative of the rational polynomial.  This is
		 * given by the formula: 
		 *    (g(x)*f'(x)*g(x)*g(x) - f(x)*g'(x))/ (g(x)*g(x))
		 * where f(x) is the numerator and g(x) is the denominator
		 */
		public function calcDerviative():RationalPolynomial
		{
			var a:IPolynomial = denominator.multiply(numerator.toStandardForm().calcDerviative());
			var b:IPolynomial = numerator.multiply(denominator.toStandardForm().calcDerviative());
			var c:IPolynomial = denominator.multiply(denominator);
			
			var ret:RationalPolynomial  = new RationalPolynomial();
			ret.numerator = FactoredPolynomial.factorPolynomial(a.multiply(c).sub(b));
			ret.denominator = c as FactoredPolynomial; 
			ret.reduce();
			
			return ret;	
		}
		
		/**
		 * This function calculates the residues of a the rational polynomial
		 * such that f(x) = r1(x) + r2(x) + ... rn(x) and returns those values
		 * in an array.  where each ry(x) is rational polynomail which can be 
		 * represented as the rational polynomials of either g(x)/1 or c/g(x) 
		 * where g(x) is a polynomial and c is a constant.
		 */
		public function calcResidues():Array
		{
			var i:int;
			var j:int;
			var k:int;
			var result:Array;
			var result1:Array;
			var ret:Array = new Array();
			var tmp:RationalPolynomial;
			var tmp1:RationalPolynomial;
			var one:FactoredPolynomial = new FactoredPolynomial(null, ComplexNum.one);
			var zeros:Array;
			var poly:StandardPolynomial = new StandardPolynomial();
			var poly1:StandardPolynomial;
			var twoZeros:Boolean; //are there at least two different pts for zeros?
			var found:Boolean;
			
			poly.coefficients = new Array(2);
			poly.coefficients[1] = new ComplexNum(1);
			
			var numLen:int;
			var denomLen:int;
			numLen = numerator.zeros.length;
			denomLen = (denominator as FactoredPolynomial).zeros.length;
			
			
			
			//improper rational polynomial... need to fix that first
			if (numLen >= denomLen)
			{
				result = numerator.divide(denominator);
				tmp = new RationalPolynomial();
				tmp.numerator = result[0];
				tmp.denominator = one;
				ret.push(tmp);
				
				if (result[1].coefficients.length != 0)
				{
					tmp = new RationalPolynomial();
					tmp.numerator = result[1];
					tmp.denominator = denominator;
					result = tmp.calcResidues();
					ret.concat(result);
				}
				
				return ret;
			}
			
			
			zeros = denominator.calcZeros();
			found = false;
			twoZeros = true;
			for (i=0; i<zeros.length; i++)
			{
				for (j=i+1; j<zeros.length; j++)
				{
					if (!zeros[i].equals(zeros[j]))
					{
						twoZeros = true;
						if (found == true)
							break;
					} else
					{
						k = i;
						found = true;
						if (twoZeros == true)
							break;
					}
				}
			}
			
			//this is nothing but the same zero, so just go ahead and return
			if (twoZeros == false && found)
			{
				ret.push(this);
				return ret;
			}
			
			//we have a multiple zero, divide it out; call recursively, then 
			//multiple it by the results and call recursively on those
			if (found)
			{
				poly.coefficients[0] = zeros[k].multiply(ComplexNum.negOne);
				tmp = new RationalPolynomial(one, poly);
				tmp = this.multiply(tmp);
				result = tmp.calcResidues();
				for (i = 0; i<result.length; i++)
				{
					tmp1 = tmp.multiply(result[i]);
					ret = ret.concat(tmp1.calcResidues());
				}
				return ret;
			}
			
			//ok we are a proper rational function so lets solve!
			tmp = new RationalPolynomial(one, poly);
			for (i = 0; i<zeros.length; i++)			
			{
				poly.coefficients[0] = zeros[i].multiply(ComplexNum.negOne);
				tmp1 = this.multiply(tmp);
				ret.push( new RationalPolynomial(new StandardPolynomial([tmp1.eval(zeros[i])]), poly.clone()) );
			}
			
			for (i =0; i<ret.length; i++)
				ret[i].reduce();
			
			return ret;
			
		}
		
		public function toString():String
		{
			return "(" +numerator.toString() + ") / (" + denominator.toString() + ")";
		}
		public function clone():RationalPolynomial
		{
			var ret:RationalPolynomial = new RationalPolynomial();
			ret.numerator = numerator.clone() as FactoredPolynomial;
			ret.denominator = denominator.clone() as FactoredPolynomial;
			return ret;
		}
		public function equals(b:RationalPolynomial):Boolean
		{
			if (numerator.equals(b.numerator) && denominator.equals(b.denominator))
				return true;
			else
				return false;
		}
	}
}