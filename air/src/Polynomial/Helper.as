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
	 * The helper class looks at the various objects composing the Polynomial and figures out how to add, sub, multiply them
	 */
	public class Helper
	{
		public function Helper()
		{
			
		}
		public static function add(a:Object, b:Object):Object
		{
			
			if (a == null)
				return b;
			else if (b == null)
				return a;
			else
			{
				if (a is ComplexNum)
				{
					if (b is ComplexNum)
						return a.add(b);
					else if (b is IPolynomial)
						return (b as IPolynomial).add(new StandardPolynomial([a]));
					else
						return (b as RationalPolynomial).add(new RationalPolynomial(new StandardPolynomial([a])));
				} else if (a is IPolynomial)
				{
					if (b is ComplexNum)
						return (a as IPolynomial).add(new StandardPolynomial([b]));
					else if (b is IPolynomial)
						return a.add(b);
					else
						return (b as RationalPolynomial).add(new RationalPolynomial(a as IPolynomial));
				} else
				{
					if (b is ComplexNum)
						return (a as RationalPolynomial).add(new RationalPolynomial(new StandardPolynomial([b])));
					else if (b is IPolynomial)
						return (a as RationalPolynomial).add(new RationalPolynomial(b as IPolynomial));
					else
						return a.add(b);							
				}
			}
		}
		
		public static function sub(a:Object, b:Object):Object
		{
			const negOne:IPolynomial = new StandardPolynomial([ComplexNum.negOne]);
			const negOneRp:RationalPolynomial = new RationalPolynomial(negOne);
			if (a == null)
			{
				if (b is ComplexNum)
					return (b as ComplexNum).multiply(ComplexNum.negOne);
				else if (b is IPolynomial)
					return (b as IPolynomial).multiply(negOne);
				else
					return (b as RationalPolynomial).multiply(negOneRp);
			}
			else if (b== null)
			{
				if (a is ComplexNum)
					return (a as ComplexNum).multiply(ComplexNum.negOne);
				else if (a is IPolynomial)
					return (a as IPolynomial).multiply(negOne);
				else
					return (a as RationalPolynomial).multiply(negOneRp);
			}
			else
			{
				if (a is ComplexNum)
				{
					if (b is ComplexNum)
						return a.sub(b);
					else if (b is IPolynomial)
						return (b as IPolynomial).sub(new StandardPolynomial([a]));
					else
						return (b as RationalPolynomial).sub(new RationalPolynomial(new StandardPolynomial([a])));
				} else if (a is IPolynomial)
				{
					if (b is ComplexNum)
						return (a as IPolynomial).sub(new StandardPolynomial([b]));
					else if (b is IPolynomial)
						return a.sub(b);
					else
						return (b as RationalPolynomial).sub(new RationalPolynomial(a as IPolynomial));
				} else
				{
					if (b is ComplexNum)
						return (a as RationalPolynomial).sub(new RationalPolynomial(new StandardPolynomial([b])));
					else if (b is IPolynomial)
						return (a as RationalPolynomial).sub(new RationalPolynomial(b as IPolynomial));
					else
						return a.sub(b);							
				}
			}
		}
		
		public static function multiply(a:Object, b:Object):Object
		{
			//if either of them = 0, then just return null
			if (a == null || b == null)
				return null;
			
			var tStdPoly:StandardPolynomial;
			var tFacPoly:FactoredPolynomial;
			var tRatPoly:RationalPolynomial;
			
			if (b is ComplexNum)
			{
				if (b.equals(ComplexNum.zero))
					return null;	
			}
			else if (b is StandardPolynomial)
			{
				tStdPoly = b as StandardPolynomial;
				if (tStdPoly.coefficients.length == 0)
					return null;
			} else if (b is FactoredPolynomial)
			{
				tFacPoly = b as FactoredPolynomial;
				if (tFacPoly.multiplier.equals(ComplexNum.zero))
					return null;
					
			} else if (b is RationalPolynomial)
			{
				tRatPoly = b as RationalPolynomial;
				if (tRatPoly.numerator.multiplier.equals(ComplexNum.zero))
					return null;
			}
			
			if (a is ComplexNum)
			{
				if (a.equals(ComplexNum.zero))
					return null;
				
				if (b is ComplexNum)
					return a.multiply(b);
				else if (b is IPolynomial)
					return (b as IPolynomial).multiply(new StandardPolynomial([a]));
				else
					return (b as RationalPolynomial).multiply(new RationalPolynomial(new StandardPolynomial([a])));
			} else if (a is IPolynomial)
			{
				if (a is StandardPolynomial)
				{
					tStdPoly = a as StandardPolynomial;
					if (tStdPoly.coefficients.length == 0)
						return null;
				} else if (a is FactoredPolynomial)
				{
					tFacPoly = a as FactoredPolynomial;
					if (tFacPoly.multiplier.equals(ComplexNum.zero))
						return null;
				}
				
				if (b is ComplexNum)
					return (a as IPolynomial).multiply(new StandardPolynomial([b]));
				else if (b is IPolynomial)
					return a.multiply(b);
				else
					return (b as RationalPolynomial).multiply(new RationalPolynomial(a as IPolynomial));
			} else
			{				
				tRatPoly = a as RationalPolynomial;
				if (tRatPoly.numerator.multiplier.equals(ComplexNum.zero))
					return null;
				
				if (b is ComplexNum)
					return (a as RationalPolynomial).multiply(new RationalPolynomial(new StandardPolynomial([b])));
				else if (b is IPolynomial)
					return (a as RationalPolynomial).multiply(new RationalPolynomial(b as IPolynomial));
				else
					return a.multiply(b);							
			}
		}
		
		/**
		 * calculates a/b.  If b is null returns null (really divide by 0 error).
		 */
		public static function divide(a:Object, b:Object):Object
		{
			a = reduce(a);
			b = reduce(b);
			
			if (a==null || b==null)
				return null;
			
			var tIPoly:IPolynomial;
			var tStdPoly:StandardPolynomial;
			var tFacPoly:FactoredPolynomial;
			var tRatPoly:RationalPolynomial;
			
			
			if (a is ComplexNum)
			{				
				if (b is ComplexNum)
					return a.divide(b);
				else if (b is IPolynomial)
				{
					tIPoly = b.clone();
					tIPoly.divideNum(a as ComplexNum);
					return tIPoly;
				}
				else
				{
					tRatPoly = (b as RationalPolynomial).divide(new RationalPolynomial(new FactoredPolynomial(null, a as ComplexNum)));
					tRatPoly.reduce();
					if (tRatPoly.denominator.multiplier.equals(ComplexNum.one) && tRatPoly.denominator.zeros.length ==0)
						return tRatPoly.numerator;
					else
						return tRatPoly;		
				}
			} else if (a is IPolynomial)
			{
				
				if (b is ComplexNum)
				{					
					tIPoly = a.clone();
					tIPoly.divideNum(b as ComplexNum);
					return tIPoly;
				}
				else if (b is IPolynomial)
				{
					tRatPoly = new RationalPolynomial(a as IPolynomial, b as IPolynomial);
					tRatPoly.reduce();
					if (tRatPoly.denominator.multiplier.equals(ComplexNum.one) && tRatPoly.denominator.zeros.length ==0)
						return tRatPoly.numerator;
					else
						return tRatPoly;	
				}
				else
				{
					return (b as RationalPolynomial).divide(new RationalPolynomial(a as IPolynomial));
				}
			} else
			{				
				tRatPoly = a as RationalPolynomial;
				
				if (b is ComplexNum)
					tRatPoly = (a as RationalPolynomial).divide(new RationalPolynomial(new FactoredPolynomial(null, b as ComplexNum)));
				else if (b is IPolynomial)
					tRatPoly =(a as RationalPolynomial).divide(new RationalPolynomial(b as IPolynomial));
				else
					tRatPoly =a.divide(b);
				
				tRatPoly.reduce();
				if (tRatPoly.denominator.multiplier.equals(ComplexNum.one) && tRatPoly.denominator.zeros.length ==0)
					return tRatPoly.numerator;
				else
					return tRatPoly;	
				
			}
		}
		
		public static function equals(a:Object, b:Object):Boolean
		{
			
			a = reduce(a);
			b = reduce(b);
			
			if (a==null && b==null)
				return true;
			if (a==null && b!=null)
				return false;
			if (a!=null && b==null)
				return false;
			
			if (a is ComplexNum)
			{
				
				if (b is ComplexNum)
					return a.equals(b);
				return false;
			} else if (a is IPolynomial)
			{
			
				if (b is IPolynomial)
				{
					return a.equals(b);	
				}
				else
				{
					return false;
				}
			} else
			{				
				if (b is RationalPolynomial)
					return a.equals(b);
				return false;
			}
		}
		
		/**
		 * Given an object which can be a ComplexNum, StandardPolynomial, 
		 * FactoredPolynomial, or RationalPolynomial; see if the object is
		 * really zero or one and replace with the approraite ComplexNum 
		 * constant.  
		 */
		public static function reduce(a:Object):Object
		{
			var num:ComplexNum;
			var std:StandardPolynomial;
			var fac:FactoredPolynomial;
			var rat:RationalPolynomial;
			
			if (a is ComplexNum)
			{
				num = a as ComplexNum;
				if (num.equals(ComplexNum.zero))
					return null;
				if (num.equals(ComplexNum.one))
					return ComplexNum.one;
				return a;
			}
		
			if (a is StandardPolynomial)
			{
				std = a as StandardPolynomial;
				if (std.equals(StandardPolynomial.zero))
					return null;
				if (std.equals(StandardPolynomial.one))
					return ComplexNum.one;
				if (std.coefficients.length == 1)
					return std.coefficients[0];
				return a;
			}
			
			if (a is FactoredPolynomial)
			{
				fac = a as FactoredPolynomial;
				if (fac.equals(FactoredPolynomial.zero))
					return null;
				if (fac.equals(FactoredPolynomial.one))
					return ComplexNum.one;
				if (fac.zeros == null)
					return fac.multiplier;
				return a;
				
			}
			
			if (a is RationalPolynomial)
			{
				rat = a as RationalPolynomial;
				if (rat.equals(RationalPolynomial.zero))
					return null;
				if (rat.equals(RationalPolynomial.one))
					return ComplexNum.one;
				
				if (rat.denominator.equals(FactoredPolynomial.one))
					return reduce(rat.numerator);
				
				return a;
			}
			return a;
		}
		
		
		
	}
}