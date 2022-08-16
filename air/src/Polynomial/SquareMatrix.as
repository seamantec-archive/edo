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
	 * The square matrix represents a dense square matrix (N x N).  Null values
	 * in the matrix are treated as zeros.  Matrix elements can be null, 
	 * ComplexNum, IPolynomial, or RationalPolynomial.
	 */
	public class SquareMatrix
	{
		private var values:Array;
		private var N:int;
		
		/**
		 * initializes an N x N matrix of all zeros 
		 */
		public function SquareMatrix(N:int)
		{
			values = new Array(N*N);
			this.N = N;
		}
		
		public static function createIdentityMatrix(N:int):SquareMatrix
		{
			var ret:SquareMatrix = new SquareMatrix(N);
			var i:int;
			for (i=0; i<N; i++)
				ret.setValue(i,i, ComplexNum.one);
			return ret;
		}
		
		public function setValue(row:int, column:int, value:Object):void
		{
			values[row*N+column] = value;
		}
		
		public function getValue(row:int, column:int):Object
		{
			return values[row*N+column];
		}
		
		/**
		 * adds two square matrices together.  They both must be of the same 
		 * dimensions; otherwise will return null.
		 */
		public function add(b:SquareMatrix):SquareMatrix
		{
			//can only sub two matrices of the same dimensions
			if (b.N != N)
				return null;
			
			var i:int;
			var ret:SquareMatrix = new SquareMatrix(N);
			for (i=0; i<values.length; i++)
			{
				ret.values[i] = Helper.add(values[i], b.values[i]);
			}
			return ret;
		}
		
		
		/**
		 * Subtracts two square matrices together.  They both must be of the same 
		 * dimensions; otherwise will return null.
		 */
		public function sub(b:SquareMatrix):SquareMatrix
		{
			//can only sub two matrices of the same dimensions
			if (b.N != N)
				return null;
			
			var i:int;
			var ret:SquareMatrix = new SquareMatrix(N);
			for (i=0; i<values.length; i++)
			{
				ret.values[i] = Helper.sub(values[i], b.values[i]);				
			}
			return ret;
		}
		
		public function multiply(b:SquareMatrix):SquareMatrix
		{
			//can only sub two matrices of the same dimensions
			if (b.N != N)
				return null;
			
			var row:int;
			var col:int;
			var i:int;
			var ret:SquareMatrix = new SquareMatrix(N);
			var val1:Object;
			var val2:Object;
			var outer:Object;			
			
			for (row=0; row<N; row++)	
			{
				for (col=0; col<N; col++)
				{
					outer = null;
					for (i=0; i<N; i++)
					{
						val1 = getValue(row, i);
						val2 = getValue(col, i);
						if (val1== null || val2==null)
							continue;
						
						if (outer == null)
							outer = Helper.multiply(val1, val2);
						else
							outer = Helper.add(outer, Helper.multiply(val1, val2));
					}
					ret.setValue(row, col, outer);
				}
			}
			return ret;
		}
		
		/**
		 * Calculates the matrices determinant if it exists
		 */
		public function calcDeterminant():Object
		{
			var i:int;
			var j:int;
			var row:int;
			var col:int;
			var ret:Object = null;
			var result:Object;
			for (i=0; i<N; i++)
			{
				result = ComplexNum.one;
				for (j=0; j<N; j++)
				{
					row = j;
					col = (j+i) % N;
					result = Helper.multiply(result, getValue(row, col));
					
					if (result == null)
						break;
					
				}
				
				if (result != null)
				{
					ret = ret.add(result);
				}
				
				for (j=0; j<N; j++)
				{
					row = j;
					col = (N-1-j+i) % N;
					
					result = Helper.multiply(result, getValue(row, col));
					
					//this can only happen if a non-null zero was placed in
					if (result == null)
						break;
				}
				
				ret = Helper.sub(ret, result);
				
			}
			return ret;
		}
		
		public function clone():SquareMatrix
		{
			var ret:SquareMatrix = new SquareMatrix(N);
			var i:int;
			for (i=0; i<N; i++)
			{
				ret.values[i] = values[i];
			}
			return ret;
		}
		
		/**
		 * Inteprets the matrix as a system of equations.  Treats each element
		 * of the matrix as a constant to a linear formula where each column
		 * and each row represents a new foruma.  So if one wanted to represent
		 * the following three formulas:
		 *    6s*x + 3y      + 2z    = 5
		 *    2x   + y       - s^2*z = 0
		 *    1x   + (3s+2)y - 3z    = 0
		 * in matrix form would look like (remember an integer is a complex 
		 * number with the imaginary term 0):
		 *    | (6,0)s  (3,0)         ( 2,0)    |
		 *    | (2,0)   (1,0)         (-1,0)s^2 |
		 *    | (1,0)   (3,0)s+(2,0)  (-3,0)    |
		 * However, this still leaves the right side of the equation, this part
		 * of the equation is passed in as a variable and would be represented 
		 * as:
		 *   | (5,0)  (0,0)   (0,0) |
		 * Note this will solve in terms of s.
		 * 
		 * rightSide - An Array of size N of complex numbers where index 0 is
		 *             the constant to the first equation.
		 * 
		 * return null if the matrix is over or under determined.
		 */
		public function eval(rightSide:Array):Array
		{
			var ret:Array = new Array(N);
			var answers:Array = rightSide.concat();
			var working:SquareMatrix = clone();
			var row1:int;
			var row2:int;
			var col:int;
			var tmp:Object;
			var tmp1:Object;
			
			//place in triangle form
			for (row1=0; row1<N; row1++)
			{
				//divide the row by the leading coeffienct so we have a 1 in the leading spot
				tmp = working.getValue(row1, row1);
				working.setValue(row1, row1, ComplexNum.one);
				for (col =row1+1 ;col <N; col++)
				{
					tmp1 = Helper.divide(tmp, working.getValue(row1, col));
					tmp1 = Helper.reduce(tmp1);
					working.setValue(row1, col, tmp1);
				}
				answers[row1] = Helper.divide(answers[row1], tmp);
				answers[row1] = Helper.reduce(answers[row1]);
				
				for (row2 = row1+1; row2 < N; row2++)
				{
					tmp = working.getValue(row2, 0);
					for (col =row1; col <N; col++)
					{
						tmp1 = Helper.multiply(tmp, working.getValue(row1, col));
						tmp1 = Helper.sub(working.getValue(row2, col), tmp1);
						tmp1 = Helper.reduce(tmp1);
						working.setValue(row2, col, tmp1);
					}
					tmp1 = Helper.multiply(tmp, answers[row1]);
					tmp1 = Helper.sub(answers[row2], tmp1);
					tmp1 = Helper.reduce(tmp1);
					answers[row2] = tmp1;
				}
			}
			
			//place in row echelon form
			for (row1 = N-1; row1 >0; row1--)
			{				
				if (working.getValue(row1, row1) == null)
					return null;
				
				for (row2 = row1-1; row2 >= 0; row2--)
				{
					tmp = working.getValue(row2, row1);
					working.setValue(row2, row1, null);
					answers[row2] = Helper.sub(answers[row2], Helper.multiply(tmp, answers[row1]));
					Helper.reduce(answers[row2]);
				}
			}
			
			return answers;
		}

        public  function toString():String{
           return values.toString()
        }
	}

}