package com.graphs
{
/**
	 * The NumericAxisHelper class is an all-static class with methods for working with NumericAxis subclasses.
	 * Currently NumericAxisHelper supports setting/getting numeric minimum/maximum on LinearAxis and DateTimeAxis.
	 */
	public class NumericAxisHelper
	{
		/**
		 * Get minimum value for a given axis.
		 */
		public static function getMin(axis:IAxis):Number
		{
			if (axis is LinearAxis)
			{
				return LinearAxis(axis).minimum;
			}
			else if (axis is DateTimeAxis)
			{
				return DateTimeAxis(axis).minimum.time;
			}
			return NaN;
		}
		
		/**
		 * Get maxiumu value for a given axis.
		 */
		public static function getMax(axis:IAxis):Number
		{
			if (axis is LinearAxis)
			{
				return LinearAxis(axis).maximum;
			}
			else if (axis is DateTimeAxis)
			{
				return DateTimeAxis(axis).maximum.time;
			}
			return NaN;
		}
		
		/**
		 * Set minimum value for a given axis.
		 */
		public static function setMin(axis:IAxis, value:Number):void
		{
			if (axis is LinearAxis)
			{
				LinearAxis(axis).minimum = value;
			}
			else if (axis is DateTimeAxis)
			{
				DateTimeAxis(axis).minimum = new Date(value);
			}
		}
		
		/**
		 * Set maximum value for a given axis.
		 */
		public static function setMax(axis:IAxis, value:Number):void
		{
			if (axis is LinearAxis)
			{
				LinearAxis(axis).maximum = value;
			}
			else if (axis is DateTimeAxis)
			{
				DateTimeAxis(axis).maximum = new Date(value);
			}
		}
	}
}