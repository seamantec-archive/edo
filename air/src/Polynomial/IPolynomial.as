package Polynomial
{
	/**
	 * This represents a polynomial regardless of its form.  There exist only  
	 * two polynomial forms currently.  Factored polynomial which tracks the
	 * polynomial by its zeros and standar polynomial which tracks the 
	 * polynomial in its standard form or by its coeffecients.
	 */
	public interface IPolynomial
	{
		/**
		 * evaluate teh polynomial at x
		 */
		function eval(x:ComplexNum):ComplexNum;
		
		function divideNum(num:ComplexNum):void;
		
		function multiplyNum(num:ComplexNum):void;
		
		/**
		 * Returns a multiplier that would result in the polynomial in the form
		 */
		function getMultiplier():ComplexNum;
		
		/**
		 * computes this + b
		 */
		function add(b:IPolynomial):IPolynomial;
		
		/**
		 * computes this - b
		 */
		function sub(b:IPolynomial):IPolynomial;
		
		/**
		 * computes this * b.  
		 */
		function multiply(b:IPolynomial):IPolynomial;
		
		/**
		 * computes this/b.  The quotiant is returned in index 0 and the 
		 * remaineder is returned in index 1
		 */
		function divide(b:IPolynomial):Array;
		
		/**
		 * Returns the polynomial in standard form
		 */
		function toStandardForm():StandardPolynomial;
		
		/**
		 * Attempts to find the zeros of the polynomial.
		 * 
		 * assumedPrecision - number of digits the zero is asummed to have.  The
		 *                    implementor can ignore this parameter if its
		 *                    algorithm doesn't need the help.
		 */
		function calcZeros(assumedPrecision:int=6):Array;
		
		/**
		 * returns a string representation of the polynomial
		 */
		function toString():String;
		
		/**
		 * returns a clone of the polynomial
		 */
		function clone():IPolynomial;
		
		/**
		 * Is b equal to this?
		 */
		function equals(b:IPolynomial):Boolean;
	}
}