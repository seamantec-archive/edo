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
	 * This is a generic polynomial class.  It doesn't contain any known 
	 * limitations.  All coefficients are stored as complex numbers and the 
	 * root finding algorithm doesn't make any assumptions about the 
	 * polynomial.  Altough, it has only been tested with real coefficients.
	 * 
	 * The coefficients are an array of complex numbers where the index 
	 * represents the degree so index 0 is x^0 (or 1), index 1 is x^1, 2 is x^2
	 * and so forth.   
	 */
	public class StandardPolynomial implements IPolynomial
	{
		public static const zero:StandardPolynomial = new StandardPolynomial();
		public static const one:StandardPolynomial = new StandardPolynomial([ComplexNum.one]);
		
		private const base:Number = 2;
		private const epsilon:Number = 2.2204460492503131e-016;
		private const infinity:Number = Number.MAX_VALUE;
		//this may look wierd but infinity isn't really infinity... it is just 
		//the largest number we can represent
		private const sqrtInfinity:Number = Math.sqrt(infinity); 
		private const smallNo:Number = Number.MIN_VALUE;
		private const mre:Number = 2 * Math.SQRT2 * epsilon; //constant used in zero calcs
		
		//array of imaginary numbers
		public var coefficients:Array = new Array();
		
		/**
		 * initialize a new polynomial.  Coefficents is an array where the 
		 * index represents the degree of the term.  So the 0th index is x^0, 
		 * the first index is x^1 and so on.  Null initializes to a polynomial
		 * constant of 0.
		 */
		public function StandardPolynomial(coefficients:Array = null)
		{
			if (coefficients == null)
				this.coefficients = new Array();
			else
				this.coefficients = coefficients;
		}
		
		/**
		 * Returns a multiplier that would result in the polynomial in the form
		 */
		public function getMultiplier():ComplexNum
		{
			return coefficients[coefficients.length -1];
		}
		
		/**
		 * Evaluate the polynomial at x using a horner expansion
		 */
		public function eval(x:ComplexNum):ComplexNum
		{
			return hornerEval(x, null);
			
		}
		
		/**
		 * Adds a number to the polynomial.  Performs the addition in place 
		 * (original modified)
		 * b         - number to add
		 * calcZeros - recalc zeros after operation
		 */
		public function addNum(b:ComplexNum):void
		{			
			if (coefficients.length == 0)
			{
				coefficients.push(b);
				return;
			}
			
			var a:ComplexNum = coefficients[0] as ComplexNum;
			
			if (coefficients.length == 0)
			{
				coefficients = [b];
				return;
			}
				
			a.real += b.real;
			a.imag += b.imag;
		}
		
		/**
		 * multiplies a number to the polynomial.  Performs the multiplication 
		 * in place (original modified)
		 * b         - number to add
		 * calcZeros - recalc zeros after operation
		 */
		public function multiplyNum(b:ComplexNum):void
		{			
			if (coefficients.length == 0)
			{
				return;
			}
			
			for (var i:int = 0; i<coefficients.length; i++)
			{
				coefficients[i] = coefficients[i].multiply(b);
			}	
			normailze();
		}
		
		/**
		 * divides a number to the polynomial.  Performs the division in place 
		 * (original modified)
		 * b         - number to add
		 * calcZeros - recalc zeros after operation
		 */
		public function divideNum(b:ComplexNum):void
		{			
			if (coefficients.length == 0)
			{
				return;
			}
			
			for (var i:int = 0; i<coefficients.length; i++)
			{
				coefficients[i] = coefficients[i].divide(b);
			}	
			normailze();			
		}
		
		/**
		 * adds two polynomials together.  The new polynomial is returned
		 * b         - second polynomial
		 * calcZeros - recalc zeros after operation
		 */
		public function add(b:IPolynomial):IPolynomial
		{
			var ret:StandardPolynomial = new StandardPolynomial();
			var bStd:StandardPolynomial = b.toStandardForm();
			var i:int;
			var tmp:ComplexNum;
			
			for (i=0; i<coefficients.length; i++)
			{
				
				if (i < bStd.coefficients.length)
					tmp = coefficients[i].add(bStd.coefficients[i]);
				else
				{
					tmp = new ComplexNum();
					tmp.real = coefficients[i].real;
					tmp.imag = coefficients[i].imag;
				}
				ret.coefficients.push(tmp);
			}
			for (i=coefficients.length; i<bStd.coefficients.length; i++)
			{
				tmp = new ComplexNum();
				tmp.real = bStd.coefficients[i].real;
				tmp.imag = bStd.coefficients[i].imag;
			}	
			ret.normailze();
			return ret;
		}
		
		
		/**
		 * subtracts two polynomials together.  The new polynomial is returned
		 * b         - second polynomial
		 * calcZeros - recalc zeros after operation
		 */
		public function sub(b:IPolynomial):IPolynomial
		{
			var ret:StandardPolynomial = new StandardPolynomial();
			var bStd:StandardPolynomial = b.toStandardForm();
			var i:int;
			var tmp:ComplexNum;
			
			for (i=0; i<coefficients.length; i++)
			{
				
				if (i < bStd.coefficients.length)
					tmp = coefficients[i].sub(bStd.coefficients[i]);
				else
				{
					tmp = new ComplexNum();
					tmp.real = coefficients[i].real;
					tmp.imag = coefficients[i].imag;
				}
				ret.coefficients.push(tmp);
			}
			for (i=coefficients.length; i<bStd.coefficients.length; i++)
			{
				tmp = new ComplexNum();
				tmp.real = bStd.coefficients[i].real;
				tmp.imag = bStd.coefficients[i].imag;
			}	
			ret.normailze();
			return ret;
		}
		
		/**
		 * multiplies two polynomials together.  The new polynomial is returned
		 * b         - second polynomial
		 * calcZeros - recalc zeros after operation
		 */
		public function multiply(b:IPolynomial):IPolynomial
		{
			var ret:StandardPolynomial = new StandardPolynomial();
			var i:int;
			var j:int;
			var tmp:ComplexNum;
			
			if (coefficients.length == 1 && coefficients[0].real == 0 && coefficients[0].imag == 0)
				return ret;
			
			var bStd:StandardPolynomial = b.toStandardForm();
			//check to see if either of them are 0 and cancel out quickly
			if (coefficients.length == 0 || bStd.coefficients.length == 0)
				return ret;
			if (bStd.coefficients.length == 1 && bStd.coefficients[0].real == 0 && bStd.coefficients[0].imag == 0)
				return ret;
			
			ret.coefficients = new Array(coefficients.length + bStd.coefficients.length);
			for (i=0; i<ret.coefficients.length; i++)
				ret.coefficients[i] = new ComplexNum();
			
			for (i=0; i<coefficients.length; i++)
			{
				for (j=0; j<bStd.coefficients.length; j++)
				{
					ret.coefficients[i+j] = ret.coefficients[i+j].add(coefficients[i].multiply(bStd.coefficients[j]));
				}
			}
						
			ret.normailze();
			return ret;
		}
		
		/**
		 * This method performs this/b.  The first element of the returned  
		 * array is the quotient and the second element is the remainder.  Both
		 * objects are polynomials
		 * b         - second polynomial
		 * calcZeros - recalc zeros after operation
		 */
		public function divide(b:IPolynomial):Array
		{
			var bStd:StandardPolynomial = b.toStandardForm();
			normailze();
			bStd.normailze();
			if (coefficients.length < bStd.coefficients.length)
				return [new StandardPolynomial(), this];
			
			var zero:ComplexNum = new ComplexNum();
			var q:StandardPolynomial = new StandardPolynomial(); //quotient
			var r:StandardPolynomial = this; //remainder
			
			var i:int;
			var tmp:StandardPolynomial = new StandardPolynomial();
			var leading:ComplexNum = bStd.coefficients[bStd.coefficients.length-1];  
			
			q.coefficients = new Array(coefficients.length - bStd.coefficients.length+1);
			
			//initialize tmp to be the same size as the quotient but all 0s.  
			//we will be setting the leading term in the multiplier loops
			tmp.coefficients = new Array(q.coefficients.length);
			tmp.coefficients[0] = new ComplexNum();
			for (i = 1; i<tmp.coefficients.length; i++)
				tmp.coefficients[i] = tmp.coefficients[0];
			
			//we are multiplying the term by b and subtracting that from the remainder
			for (i = q.coefficients.length-1; i>=0; i--)
			{
				q.coefficients[i] = r.coefficients[i+bStd.coefficients.length-1].divide(leading);
				tmp.coefficients[i] = q.coefficients[i]; 
				r = r.sub(tmp.multiply(bStd)) as StandardPolynomial;
				tmp.coefficients.pop();
				
			}
			
			q.normailze();			
			r.normailze();
			return [q, r];
		}
		
		/**
		 * Remove leading zeros from the polynomial.  This is done in place.
		 * Functions which assume no leading zeros will automatically normalize
		 */
		public function normailze():void
		{
			if (coefficients.length == 0)
				return;
			
			while (coefficients[coefficients.length-1].real == 0 &&
				   coefficients[coefficients.length-1].imag == 0)
			{
				coefficients.pop();
				if (coefficients.length == 0)
					return;
			}
		}
		
		/**
		 * Calculates the derviative of the polynomial and returns it as a new 
		 * polynomial
		 * calcZeros - calculate the zeros of the derviative before returning?
		 */
		public function calcDerviative():StandardPolynomial
		{
			var ret:StandardPolynomial = new StandardPolynomial();
			var i:int;
			ret.coefficients = new Array(coefficients.length-1);
			
			for (i=1; i<coefficients.length; i++)
			{
				ret.coefficients[i-1] = coefficients[i].multiply(new ComplexNum(i));
			}
			
			return ret;
		}
		
		public function toStandardForm():StandardPolynomial
		{
			return this;
		}
		
		
		/**
		 * Is b equal to this?
		 */
		public function equals(b:IPolynomial):Boolean
		{
			var t:StandardPolynomial = b.toStandardForm();
			normailze();
			t.normailze();
						
			if (t.coefficients.length != coefficients.length)
				return false;
			
			for (var i:int = 0; i<t.coefficients.length; i++)
			{
				if (!t.coefficients[i].equals(coefficients[i]))
					return false;
			}
			
			return true;
		}
		
		/**
		 * Calculate the zeros of this polynomial.  
		 * 
		 * Current calls calcZerosTom493 then tries to clean up any real 
		 * polynomials found by comparing them to the original formula
		 * 
		 * assumedPrecision - number of digits the zeros are assumed to be
		 *                    within.  This only affects the 'cleaning' part
		 *                    of the algorithm where we step through each
		 *                    zero and test the assumed precision prediction.
		 *                    If when dividing the resulting array by cleaned
		 *                    root has less error; then the new root is taken
		 *                    as real.  Otherwise, the original root is left
		 *                    in tact.
		 * 
		 */
		public function calcZeros(assumedPrecision:int = 6):Array
		{
			//simple case, constant so just return
			if (coefficients.length == 1)
				return new Array();
			
			//simple case, straight line, so just calculate intercept
			if (coefficients.length == 2)
				return coefficients[0].multiply(ComplexNum.negOne).divide(coefficients[1]);
			
			//simple case, quadradic formula, so just use it
			if (coefficients.length == 3)
				return calcZerosQuadradic();
				
			//general case.  arbritary degree approximation function followed 
			//0by a cleaning function
			return calcZerosClean(calcZerosTom493(),assumedPrecision);
			
		}
		
		
		/**
		 * Creates a string from the polynomial of the form 
		 *      a1x^n + a2x^(n-1) + ... an-1x + an
		 */
		public function toString():String
		{
			var ret:String = "";
			var i:int;
			var first:Boolean = true;
			
			for (i=coefficients.length-1; i>=0; i--)
			{
				if (coefficients[i].imag == 0 && coefficients[i].real == 0)
					continue;
				
				if (!first)
				{
					ret += " + ";
				} else
					first = false;
				
				if (i > 0)
				{
					if (coefficients[i].imag == 0)
						ret += coefficients[i].real + "x^"+i;
					else
						ret += "(" + coefficients[i].real + " + " + coefficients[i].imag+"i)x^"+i+" ";
				}
				else
				{
					if (coefficients[i].imag == 0)
						ret += coefficients[i].real;
					else
						ret += coefficients[i].real + " + " + coefficients[i].imag+"i";
				}
			}
			return ret;
		}
		
		/**
		 * clones the polynomial so work on the new polynomial doesn't affect 
		 * the original
		 */
		public function clone():IPolynomial
		{
			var ret:StandardPolynomial = new StandardPolynomial();
			ret.coefficients = coefficients.slice();
			return ret;
		}
		
		/**
		 * only works with a degree two polynomial.  Uses the quadradic formula
		 * to calculate zeros
		 */
		private function calcZerosQuadradic():Array
		{
			if (coefficients.length != 3)
				return null;
			
			var ret:Array
			var a:ComplexNum = coefficients[2];
			var b:ComplexNum = coefficients[1];
			var c:ComplexNum = coefficients[0];
			
			var determ:ComplexNum = b.multiply(b).sub(new ComplexNum(4).multiply(a).multiply(c)).sqrt();
			ret.push(b.multiply(new ComplexNum(-1)).divide(new ComplexNum(2)).add(determ));
			ret.push(b.multiply(new ComplexNum(-1)).divide(new ComplexNum(2)).sub(determ));
			return ret;
		}
		
		/**
		 * This function attempts to clean the pts where the zeros are located 
		 * by assuming the pts have 'too many digits' for the actual point. 
		 * Based on that, it will first iterate through each pt and round it to
		 * contain only the number of pts in precisionGuess.  If that results
		 * in a clean polynomial it will be accepted over the original.  Next
		 * it will attempt multiplying two of the found zero polynomials together
		 * and ronding the new found polynomials coeffecients and dividing that.
		 * If that works, the new zeros are calculated using the quadradic formula.
		 * Lastly if some zeros were cleaned but not all of them, it will take the
		 * reduced polynomial from the cleaned zeros and try recalculating the zeros.
		 */
		private function calcZerosClean(zeros:Array, precisionGuess:int = 6):Array
		{
			var i:int;
			var j:int;
			var k:int;
			var tmp:StandardPolynomial;
			var markedZeros:Array = new Array(zeros.length); //zeros which have been pulled out already
			var cleanedZeros:Array = new Array(); //zeros we have found
			var result:Array;        //results of division
			var testNum:ComplexNum;  //the number being tested
			var testNum1:ComplexNum;  //the number being tested
			var testPoly:StandardPolynomial = new StandardPolynomial(); //used for dividing a zero out
			var testPoly1:StandardPolynomial = new StandardPolynomial(); //used for dividing a zero out
			var testPoly2:StandardPolynomial = new StandardPolynomial(); //used for dividing a zero out
			var rdigits:Number;      //
			var idigits:Number;
			var multipiler:Number;
			var oneNotMarked:Boolean;
			
			for (i = 0; i<zeros.length; i++)
			{
				markedZeros[i] = false;
			}
			
			
			//phase 1 check for significant digits
			testPoly.coefficients = new Array(2);
			testPoly.coefficients[1] = ComplexNum.one;
			testPoly1.coefficients = new Array(2);
			testPoly1.coefficients[1] = ComplexNum.one;
			tmp = this;
			
			oneNotMarked = false;
			for (i = 0; i<zeros.length; i++)
			{
				testNum = testPoly.coefficients[0] = zeros[i].multiply(ComplexNum.negOne);
				if (testNum.real != 0)
					rdigits = Math.floor(Math.log(Math.abs(testNum.real))*Math.LOG10E);
				if (testNum.imag != 0)
					idigits = Math.floor(Math.log(Math.abs(testNum.imag))*Math.LOG10E);
				
				//step 1, try just shorting it to 5 digits
				multipiler = Math.pow(10,rdigits-precisionGuess);
				if (testNum.real != 0)
					testNum.real = Math.round( testNum.real / multipiler) * multipiler;
				
				multipiler = Math.pow(10, idigits-precisionGuess);
				if (testNum.imag != 0)
					testNum.imag = Math.round( testNum.imag / multipiler ) * multipiler ;
				
				//check for significant digits difference
				if (idigits + precisionGuess+2 < rdigits)
				{
					
					testNum.imag = 0;
				} else if (rdigits + precisionGuess+2 < idigits)
				{
					testNum.real = 0;
				}
				
				result = tmp.divide(testPoly);
				//we have a winner
				if (result[1].coefficients.length == 0)
				{
					cleanedZeros.push(testNum.multiply(ComplexNum.negOne));
					markedZeros[i] = true;
					tmp = result[0];
					continue;
				}
				
				testNum = testPoly.coefficients[0] = zeros[i].multiply(ComplexNum.negOne);
				
				//check for significant digits difference
				if (idigits + precisionGuess+2 < rdigits)
				{
					
					testNum.imag = 0;
				} else if (rdigits + precisionGuess+2 < idigits)
				{
					testNum.real = 0;
				}
				
				result = tmp.divide(testPoly);
				//we have a winner
				if (result[1].coefficients.length == 0)
				{
					cleanedZeros.push(testNum.multiply(ComplexNum.negOne));
					markedZeros[i] = true;
					tmp = result[0];
					continue;
				}
				
				
				
				oneNotMarked = true;
			}
			
			//we have good enough results
			if (!oneNotMarked)
			{
				return cleanedZeros;
			}
			
			for (i=0; i<zeros.length; i++)
			{
				if (markedZeros[i])
					continue;
				testNum = testPoly.coefficients[0] = zeros[i].multiply(ComplexNum.negOne);
				
				for (j=i+1; j<zeros.length; j++)
				{
					var a:ComplexNum;
					var b:ComplexNum;
					var c:ComplexNum;
					var determ:ComplexNum;
					
					if (markedZeros[j])
						continue;
					
					testNum1 = testPoly1.coefficients[0] = zeros[j].multiply(ComplexNum.negOne);
				
					testPoly2 = testPoly1.multiply(testPoly) as StandardPolynomial;
					for (k=0; k<testPoly2.coefficients.length-1; k++)
					{
						
						testNum = testPoly2.coefficients[k];
						if (testNum.real != 0)
							rdigits = Math.floor(Math.log(Math.abs(testNum.real))*Math.LOG10E);
						if (testNum.imag != 0)
							idigits = Math.floor(Math.log(Math.abs(testNum.imag))*Math.LOG10E);
						
						//step 1, try just shorting it to 5 digits
						multipiler = Math.pow(10,rdigits-precisionGuess);
						if (testNum.real != 0)
							testNum.real = Math.round( testNum.real / multipiler) * multipiler;
						
						multipiler = Math.pow(10,idigits-precisionGuess);
						if (testNum.imag != 0)
							testNum.imag = Math.round( testNum.imag / multipiler ) * multipiler ;
						
						//check for significant digits difference
						if (idigits + precisionGuess+2 < rdigits)
						{
							
							testNum.imag = 0;
						} else if (rdigits + precisionGuess+2 < idigits)
						{
							testNum.real = 0;
						}
					}
					
					result = tmp.divide(testPoly2);
					//we have a winner
					if (result[1].coefficients.length == 0)
					{
						a = testPoly2.coefficients[2];
						b = testPoly2.coefficients[1];
						c = testPoly2.coefficients[0];
						
						determ = b.multiply(b).sub(new ComplexNum(4).multiply(a).multiply(c)).sqrt();
						cleanedZeros.push(b.multiply(new ComplexNum(-1)).divide(new ComplexNum(2)).add(determ));
						cleanedZeros.push(b.multiply(new ComplexNum(-1)).divide(new ComplexNum(2)).sub(determ));
						
						//cleanedZeros.push(testNum);
						markedZeros[i] = true;
						markedZeros[j] = true;
						tmp = result[0];
						continue;
					}
					
					
					testPoly2 = testPoly1.multiply(testPoly) as StandardPolynomial;
					for (k=0; k<testPoly2.coefficients.length-1; k++)
					{
						testNum = testPoly2.coefficients[k];
						if (testNum.real != 0)
							rdigits = Math.floor(Math.log(Math.abs(testNum.real))*Math.LOG10E);
						if (testNum.imag != 0)
							idigits = Math.floor(Math.log(Math.abs(testNum.imag))*Math.LOG10E);
						
						
						//check for significant digits difference
						if (idigits + precisionGuess+2 < rdigits)
						{
							
							testNum.imag = 0;
						} else if (rdigits + precisionGuess+2 < idigits)
						{
							testNum.real = 0;
						}
					}
					
					
					result = tmp.divide(testPoly2);
					//we have a winner
					if (result[1].coefficients.length == 0)
					{
						a = testPoly2.coefficients[2];
						b = testPoly2.coefficients[1];
						c = testPoly2.coefficients[0];
						
						determ = b.multiply(b).sub(new ComplexNum(4).multiply(a).multiply(c)).sqrt();
						cleanedZeros.push(b.multiply(new ComplexNum(-1)).divide(new ComplexNum(2)).add(determ));
						cleanedZeros.push(b.multiply(new ComplexNum(-1)).divide(new ComplexNum(2)).sub(determ));
						
						//cleanedZeros.push(testNum);
						markedZeros[i] = true;
						markedZeros[j] = true;
						tmp = result[0];
						continue;
					}
					
				}
			}			
			
			if (cleanedZeros.length == 0)
				return zeros;
			
			//time to see if rounding errors in earlier zeros, contributed to larger error in succeeding zeros
			if (cleanedZeros.length != zeros.length)
			{
				tmp = this;
				for (i=0; i<cleanedZeros.length; i++)
				{
					testNum1 = testPoly1.coefficients[0] = cleanedZeros[i].multiply(ComplexNum.negOne);
					tmp = tmp.divide(testPoly1)[0];
				}
				return cleanedZeros.concat(tmp.calcZeros(precisionGuess));
				
			} else
			{	
				return cleanedZeros;
			}
			
		}
		
		
		/**
		 * Calculate the zeros of this polynomial.  
		 * 
		 * This is a recursive algorithm which will attempt to find multiple
		 * roots at the same point by dividing each root found and calling
		 * itself with the smaller polynomial.
		 * 
		 * This method is based on Henrik Vestermark's translation of TOMS493
		 * Fortran to C source.  It was heavily modified for the environment.
		 * 
		 * Limitations: 
		 * - Not tested with polynomials with complex coeffecients.  Should in
		 * theory work... just check a couple by hand first
		 *   
		 */
		private function calcZerosTom493( precisionGuess:int = 6):Array
		{
			normailze();
			var tmp:StandardPolynomial = clone() as StandardPolynomial;
			var i:int;
			var scaling:Number;
			var shr:Array;
			var shi:Array;
			var zero:ComplexNum = new ComplexNum();
			var cnt1:int;
			var cnt2:int;
			var q:Array;
			var ret:Array;
			
			
			const cosr:Number = -0.060756474;
			const sinr:Number = -0.99756405;
			
			var xx:Number = 0.70710678;
			var yy:Number = -xx;
			var x:ComplexNum = new ComplexNum();
			var z:ComplexNum = new ComplexNum();
			
			if (coefficients.length <= 1)
			{
				ret = new Array();
				return ret;
			}
			
			//zeros = new Array(coefficients.length -1);
			
			
			ret = new Array();
			var modified:Boolean = false;
			
			//remove all extra x terms.  This will help save the next algorithm
			while (tmp.coefficients[0].real == 0 && tmp.coefficients.imag == 0)
			{
				ret.push(zero);
				for (i =1; i<tmp.coefficients.length; i++)
					tmp.coefficients[i-1] = tmp.coefficients[i];
				tmp.coefficients.pop();
				modified = true;
			}
			
			//check for a linear formula
			if (tmp.coefficients.length == 2)
			{
				ret.push(tmp.coefficients[0].multiply(new ComplexNum(-1)).divide(tmp.coefficients[1]));
				return ret;
			}
			
			
			shr = new Array(tmp.coefficients.length);
			shi = new Array(tmp.coefficients.length);
			q = new Array(tmp.coefficients.length);
			
			for (i=0; i<tmp.coefficients.length; i++)
				shr[i] = tmp.coefficients[i].dist();
			
			scaling = scaleForZero(shr);
			if (scaling != 1)
			{
				tmp.divideNum(new ComplexNum(scaling, scaling));
				modified = true;
			}
			
			scaling = cauchy(shr, shi);
			var h:StandardPolynomial = tmp.calcDerviative();
			var qh:Array = new Array(h.coefficients.length);
			for (cnt1 = 0; cnt1<2; cnt1++)
			{
				if (cnt1 != 0)
					h = tmp.calcDerviative();
				h.divideNum(new ComplexNum(coefficients.length-1));
				tmp.noshift(5,h);
				
				for (cnt2 = 0; cnt2 < 9; cnt2++)
				{
					var xxx:Number = cosr * xx - sinr*yy;
					yy = sinr*xx + cosr*yy;
					xx = xxx;
					x.real = scaling * xx;
					x.imag = scaling * yy;
					
					if (tmp.fxshift(10 * cnt2, x, z, q, h, qh))
					{
						var testPoly:StandardPolynomial = new StandardPolynomial([z.multiply(ComplexNum.negOne), ComplexNum.one]);
						var result1:Array = tmp.divide(testPoly);
						if (result1[1].coefficients.length != 0)
						{
							var testNum:ComplexNum = testPoly.coefficients[0];
							var rdigits:int;
							var idigits:int;
							
							if (testNum.real != 0)
								rdigits = Math.floor(Math.log(Math.abs(testNum.real))*Math.LOG10E);
							if (testNum.imag != 0)
								idigits = Math.floor(Math.log(Math.abs(testNum.imag))*Math.LOG10E);
							
							var multipiler:Number = Math.pow(10,rdigits-precisionGuess);
							if (testNum.real != 0)
								testNum.real = Math.round( testNum.real / multipiler) * multipiler;
							
							multipiler = Math.pow(10, idigits-precisionGuess);
							if (testNum.imag != 0)
								testNum.imag = Math.round( testNum.imag / multipiler ) * multipiler ;
														
							//check for significant digits difference
							if (idigits + precisionGuess+2 < rdigits)
							{
								
								testNum.imag = 0;
							} else if (rdigits + precisionGuess+2 < idigits)
							{
								testNum.real = 0;
							}
							
							var sTest2:ComplexNum = testPoly.coefficients[0].clone();
							var result2:Array = tmp.divide(testPoly);
							if (result2[1].coefficients.length == 0)
							{
								ret.push(testNum.multiply(ComplexNum.negOne));
								tmp = result2[0];
								ret = ret.concat(tmp.calcZerosTom493());
								return ret;								
							}
							
							testNum.real = z.real * -1;
							testNum.imag = z.imag * -1;			
							//check for significant digits difference
							if (idigits + precisionGuess+2 < rdigits)
							{
								
								testNum.imag = 0;
							} else if (rdigits + precisionGuess+2 < idigits)
							{
								testNum.real = 0;
							}
							
							var result3:Array = tmp.divide(testPoly);
							if (result3[1].coefficients.length == 0)
							{
								ret.push(testNum.multiply(ComplexNum.negOne));
								tmp = result3[0];
								ret = ret.concat(tmp.calcZerosTom493());
								return ret;								
							}
							
							//no clear winner lets look for best of the three
							
							//lets start by seeing if the coefficients in the remainder are smaller for one of them
							if (result2[1].coefficients.length < result1[1].coefficients.length && result2[1].coefficients.length < result3[1].coefficients.length)
							{
								ret.push(sTest2.multiply(ComplexNum.negOne));
								tmp = result2[0];
								ret = ret.concat(tmp.calcZerosTom493());
								return ret;											
							}
							
							if (result3[1].coefficients.length < result1[1].coefficients.length)
							{
								ret.push(sTest2.multiply(ComplexNum.negOne));
								ret.push(testNum.multiply(ComplexNum.negOne));
								tmp = result3[0];
								ret = ret.concat(tmp.calcZerosTom493());
								return ret;		
							}
							
							if (result1[1].coefficients.length < result2[1].coefficients.length && result1[1].coefficients.length < result3[1].coefficients.length)
							{
								ret.push(z);
								tmp.coefficients = q;
								tmp.coefficients.shift();
								ret = ret.concat(tmp.calcZerosTom493());
								return ret;								
							}
							
							var distSq1:Number=0;
							var distSq2:Number=0;
							var distSq3:Number=0;
							var iter:int;
							for (iter=0; iter < result1[0].coefficients.length; iter++)
							{
								distSq1 += (iter +1) * (result1[0].coefficients[iter].real + result1[0].coefficients[iter].imag);
							}
							for (iter=0; iter < result2[0].coefficients.length; iter++)
							{
								distSq2 += (iter +1) * (result2[0].coefficients[iter].real + result2[0].coefficients[iter].imag);
							}
							for (iter=0; iter < result3[0].coefficients.length; iter++)
							{
								distSq3 += (iter +1) * (result3[0].coefficients[iter].real + result3[0].coefficients[iter].imag);
							}
							if (distSq1 < distSq2 && distSq1 < distSq3)
							{
								ret.push(z);
								tmp.coefficients = q;
								tmp.coefficients.shift();
								ret = ret.concat(tmp.calcZerosTom493());
								return ret;									
							}
							if (distSq2 < distSq3)
							{
								ret.push(sTest2.multiply(ComplexNum.negOne));
								tmp = result2[0];
								ret = ret.concat(tmp.calcZerosTom493());
								return ret;									
							} else
							{
								ret.push(sTest2.multiply(ComplexNum.negOne));
								ret.push(testNum.multiply(ComplexNum.negOne));
								tmp = result3[0];
								ret = ret.concat(tmp.calcZerosTom493());
								return ret;										
							}
							
						} else
						{
							ret.push(z);
							tmp.coefficients = q;
							tmp.coefficients.shift();
							ret = ret.concat(tmp.calcZerosTom493());
							return ret;
						}
					}
				}
			}
			
			return new Array();
		}
		
		/**
		 * Part of findZeros algorithm.
		 * 
		 * This method is based on Henrik Vestermark's translation of TOMS493
		 * Fortran to C source.  It was heavily modified for the environment.
		 */
		private function noshift(limit:int, h:StandardPolynomial):void
		{
			var i:int;
			var j:int;
			var jj:int;
			var nm1:int;
			var xni:Number;
			var t:ComplexNum;
			var t1:Number;
			var t2:Number;
			
			
			for (jj=limit; jj>0; jj--)
			{
				if (h.coefficients[0].dist() > epsilon * 10 * coefficients[1].dist())
				{
					var temp:ComplexNum = new ComplexNum();
					temp.real = -coefficients[0].real;
					temp.imag = coefficients[0].imag;
					t = temp.divide(h.coefficients[0]);
					for (i=0; i<coefficients.length-2; i++)
					{
						j = i + 2;
						t1 = h.coefficients[i+1].real;
						t2 = h.coefficients[i+1].imag;
						h.coefficients[i].real = t.real * t1 - t.imag * t2 + coefficients[i+1].real;
						h.coefficients[i].imag = t.real * t2 + t.imag * t1 + coefficients[i+1].imag;
					}
					h.coefficients[h.coefficients.length-1] = coefficients[coefficients.length-1];
				} else
				{
					h.coefficients.shift();
				}
			}
		}
		
		/**
		 * Computes L2 Fixed-shift H polynomial and tests for convergence.
		 * Initiates a variable-shift iteration and returns the aproximate 
		 * zero if successful.
		 * 
		 * limit - limit of steps in stage 2
		 * x     - initial guess for zero
		 * z     - if returns true, approximate zero
		 * h     - deriviative of polynomial
		 * qh    - array of partial solutions for h
		 * returns if iteration converges
		 * 
		 * This method is based on Henrik Vestermark's translation of TOMS493
		 * Fortran to C source.  It was heavily modified for the environment.
		 */
		private function fxshift(limit:int, x:ComplexNum, z:ComplexNum, q:Array, h:StandardPolynomial, qh:Array):Boolean
		{
			var i:int;
			var j:int;
			var n:int;
			var test:Boolean = true;
			var pasd:Boolean = false;
			var bol:Boolean;
			var ot:ComplexNum = new ComplexNum();
			var sx:ComplexNum;
			var p:ComplexNum;
			var t:ComplexNum;
			var sh:StandardPolynomial = new StandardPolynomial();
			
			p = hornerEval(x, q);
			t = calct(x, p, h, qh);
			
			for (j=1; j<=12; j++)
			{
				if (t!=null)
				{
					ot.real = t.real;
					ot.imag = t.imag;
				}
				
				nexth(t, h, q, qh);
				t = calct(x, p, h, qh);
				z.real = x.real + t.real;
				z.imag = x.imag + t.imag;
				
				if (!(t!=null || !test || j==12))
					continue;
				
				if (t.sub(ot).dist() < .5 * z.dist())
				{
					if (pasd)
					{
						sh = h.clone() as StandardPolynomial;
						sx = x.clone();
						if (vrshft(10, z, h, q, qh))
							return true;
						
						test = false;
						h = sh;
						x = sx;
						p = hornerEval(x, q);
						t = calct(x, p, h, qh);
					}
					pasd = true;
				} else
					pasd = false;
			}
			
			return vrshft(10, z, h, q, qh);
		}
		
		/**
		 * Carries out the third stage iteration
		 * 
		 * limit - limit of steps in stage 3
		 * z     - on entry contains the initial iterate.  if the iteration
		 *         converges it contains the final iterate on exit
		 * h     - starts as the derviative of poly, but then changes...
		 * q     - partial solutions to poly
		 * qh    - partial solutions to h
		 * returns if iteration converges
		 * 
		 * This method is based on Henrik Vestermark's translation of TOMS493
		 * Fortran to C source.  It was heavily modified for the environment.
		 */
		private function vrshft(limit:int, z:ComplexNum, h:StandardPolynomial,q:Array, qh:Array):Boolean
		{
			var b:Boolean;
			var bol:Boolean;
			var i:int;
			var j:int;
			var mp:Number, ms:Number, omp:Number; 
			var relstp:Number; 
			var rl:Number;
			var r2:Number;
			var tp:Number;
			var t:ComplexNum;
			
			var x:ComplexNum = new ComplexNum();
			x.real = z.real;
			x.imag = z.imag;
			
			var p:ComplexNum;
			
			b = false;
			//main loop for strage three
			for (i = 0; i<limit; i++)
			{
				//evaluate p at x and test for convergence
				p = hornerEval(x, q);
				mp = p.dist();
				ms = x.dist();
				if (mp <= 20 * errev(q, ms, mp) )
				{
					z.real = x.real;
					z.imag = x.imag;
					return true;
				}
				if (i != 0)
				{
					if (! (b || mp < omp || relstp >= .05) )
					{
						tp = relstp;
						b = true;
						if (relstp < epsilon)
							tp = epsilon;
						rl = Math.sqrt(tp);
						r2 = x.real * (1 + rl) - x.imag * rl;
						x.imag = x.real * rl + x.imag * (1+rl);
						x.real = r2;
						p = hornerEval(x, q);
						for (j = 0; j <5; j++)
						{
							t = calct(x, p, h, qh);
							nexth(t, h, q, qh);
						}
					} else if (mp * .1 > omp)
						return false;
				}
				
				t = calct(x, p, h, qh);
				nexth(t, h, q, qh);
				t = calct(x, p, h, qh);
				if (t != null)
				{
					relstp = t.dist() / x.dist();
					x = t
				}
			}
			return false;
		}
		
		/**
		 * Computes T = -P(s)/H(s)
		 * Returns if H(s) is essentially zero
		 *  
		 * x  - is the value to evaluate at
		 * p  - is some value i am not sure what it is yet
		 * h  - starts off as derviative then it changes...
		 * qh - partials of h when solved.  needs to be preallocated same size as h
		 * 
		 * This method is based on Henrik Vestermark's translation of TOMS493
		 * Fortran to C source.  It was heavily modified for the environment.
		 */
		private function calct(x:ComplexNum, p:ComplexNum, h:StandardPolynomial, qh:Array):ComplexNum
		{
			var ans:ComplexNum =  h.hornerEval(x, qh);
			var bol:Boolean = ans.dist() < epsilon * 10 * h.coefficients[0].dist() ? true:false;
			var tmp:ComplexNum = new ComplexNum(-p.real, -p.imag);
			if (!bol)
			{
				return tmp.divide(ans);		
			}
			return null;
		}
		
		/**
		 * Calculates the next shifted H polynomial
		 * 
		 * t  - is some number that is used.  if null bol from original is false
		 * h  - starts as a derviative and is shifted via this routine
		 * q  - is the partial solutions to the polynomial for a given point
		 * qh - is the partial solutions to h given for a given point
		 * 
		 * This method is based on Henrik Vestermark's translation of TOMS493
		 * Fortran to C source.  It was heavily modified for the environment.
		 */
		private function nexth(t:ComplexNum, h:StandardPolynomial, q:Array, qh:Array):void
		{
			var j:int;
			var n:int;
			var t1:ComplexNum;
			
			if (t != null)
			{
				for (j=q.length-2; j>0; j--)
				{
					t1 = qh[j];
					h.coefficients[j-1].real = t.real * t1.real - t.imag * t1.imag + q[j].real;
					h.coefficients[j-1].imag = t.real * t1.imag + t.imag * t1.real + q[j].imag;
				}
				h.coefficients[h.coefficients.length-1] = q[q.length-1];
			} else
			{
				for (j=q.length-2; j>=0; j--)
				{
					h.coefficients[j] = q[j+1];
				}
				h.coefficients[h.coefficients.length-1] = q[h.coefficients.length-1];
			}			
		}
		
		/**
		 * Evaluates the polynomial at x by the horner recurrence and places
		 * the partial sums in q.
		 * 
		 * x - value to evaluate
		 * q - array of partial solutions (if desired).  Passing null will 
		 *     cause this function to ignore it.  Otherwise should be allocated
		 *     to the same size as the coefficients
		 */
		private function hornerEval(x:ComplexNum, q:Array):ComplexNum
		{
			var ret:ComplexNum = new ComplexNum();
			var i:int;
			var t:Number;
			ret.real = coefficients[coefficients.length-1].real;
			ret.imag = coefficients[coefficients.length-1].imag;
			
			if (q!=null)			
				q[coefficients.length-1] = ret.clone();
			
			for (i=coefficients.length-2; i>=0; i--)
			{
				t = ret.real * x.real - ret.imag * x.imag + coefficients[i].real;
				ret.imag = ret.real * x.imag + ret.imag * x.real + coefficients[i].imag;
				ret.real = t;
				if (q!=null)
					q[i] = ret.clone();
			}
			
			return ret;
		}
		
		/**
		 * Bounds the error in evaluating the polynomial by the horner recurrence
		 * q  - array of complex.  partial sums
		 * ms - modulus of the point
		 * mp - modulus of the polynomial value
		 * are, mre - error bounds of complex addition and multication
		 * 
		 * This method is based on Henrik Vestermark's translation of TOMS493
		 * Fortran to C source.  It was heavily modified for the environment.
		 */
		private function errev(q:Array, ms:Number, mp:Number):Number
		{
			var i:int;
			var e:Number;
			
			e = q[q.length-1].dist() * mre / (epsilon+mre);
			for (i=q.length-1; i>=0; i--) //should 0 be counted twice? TODO investigate
				e = e * ms + q[i].dist();
			
			return e * (epsilon+ mre) - mp*mre;
		}
		
		/**
		 * computes a lower bound on the moduli of the zeros of a polynomial.
		 * pt is the modulus of the coeffecients.
		 * 
		 * pt and q are arrays of Numbers
		 * 
		 * This method is based on Henrik Vestermark's translation of TOMS493
		 * Fortran to C source.  It was heavily modified for the environment.
		 */
		private function cauchy(pt:Array, q:Array):Number
		{
			var i:int;
			var n:int;
			var x:Number;
			var xm:Number;
			var f:Number;
			var dx:Number;
			var df:Number;
			
			//compute upper estimate bound
			n = pt.length-1;
			pt[0] = -pt[0];
			x = Math.exp( Math.log(-pt[0]) - Math.log(pt[n])) / n;
			if ( pt [1] != 0)
			{
				xm = -pt[0] / pt[1];
				if (xm < x)
					x = xm;
			}
			
			//chop the interval (x, x) until f < 0
			while (true)
			{
				xm = x*.1;
				f = pt[n];
				for (i=n-1; i>=0; i--)
					f = f*xm + pt[i];
				if (f <=0)
					break;
				x = xm;
			}
			dx = x;
			
			//do newton iteration until x converges to two decimal places
			while (Math.abs(dx/ x) > .005)
			{
				q[n] = pt[n];
				for (i = n-1; i>=0; i--)
				{
					q[i] = q[i+1] *x + pt[i];
				}
				f = q[0];
				df = q[n];
				for (i=n-1; i>0; i--)
					df = df * x + q[i];
				dx = f / df;
				x -= dx;
			}
			
			return x;
		}
		
		/**
		 * Retuns a scaled Factor to multiply the coefficients of the 
		 * polynomial.  The scaling is done to avoid overflow and to avoid
		 * undetected underflow interfering with the convergence criterion. 
		 * The factor is a power of the base.  
		 * 
		 * pt - an array of doubles to check for scaling issues
		 * 
		 * This method is based on Henrik Vestermark's translation of TOMS493
		 * Fortran to C source.  It was heavily modified for the environment.
		 */
		private function scaleForZero(pt:Array):Number
		{
			var hi:Number = sqrtInfinity;
			var lo:Number = smallNo / epsilon;
			var max:Number = 0;
			var min:Number = infinity;
			var i:int;
			var ret:Number;
			var x:Number;
			var sc:Number;
			var l:int;
			
			for (i=0; i<coefficients.length; i++)
			{				
				if (pt[i] > max)
					max = pt[i];
				if (pt[i]!=0 && pt[i]<min)
					min =pt[i];
			}
			
			if (min >= lo && max <= hi)
			{
				return 1;
			}
			else
			{
				x = lo/min;
				if (x<=1)
				{
					sc = 1 / (Math.sqrt(max) * Math.sqrt(min));	
				} else
				{
					sc = x;
					if (infinity / sc > max)
						sc = 1;
				}
				l = Math.round(Math.log(sc)*Math.LOG2E);
				
				return Math.pow(base, l);
			}
		}
		
	}
}