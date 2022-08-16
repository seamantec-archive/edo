/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.04.
 * Time: 16:11
 * To change this template use File | Settings | File Templates.
 */
package com.graphs {
public class AreaSeries extends mx.charts.series.AreaSeries {
    public function AreaSeries() {
        super();
    }

    /**
        *  @private
        */
       override public function findDataPoints(x:Number, y:Number,
                                               sensitivity:Number):Array /* of HitData */
       {
           // esg, 8/7/06: if your mouse is over a series when it gets added and displayed for the first time, this can get called
           // before updateData, and before and render data is constructed. The right long term fix is to make sure a stubbed out
           // render data is _always_ present, but that's a little disruptive right now.
           if (interactive == false || !renderData)
               return [];

           var pr:Number = getStyle("radius");
           var minDist2:Number = pr + sensitivity;
           minDist2 *= minDist2;
           var minItem:AreaSeriesItem;
           var minIndex:int;
           var pr2:Number = pr * pr;

   		if(renderData.filteredCache == null){
   			return [];
   		}
   		var n:int = renderData.filteredCache.length;
           if (n == 0)
               return [];
           if (sortOnXField == true)
           {
               var low:Number = 0;
               var high:Number = n;
               var cur:Number = Math.floor((low + high) / 2);

               while (true)
               {
                   var v:AreaSeriesItem = renderData.filteredCache[cur];

                   if (!isNaN(v.yNumber))
                   {
                       var dist:Number = (v.x - x) * (v.x - x) +
                                         (v.y - y) * (v.y - y);
                       if (dist <= minDist2)
                       {
                           minDist2 = dist;
                           minItem = v;
                           minIndex = cur;
                       }
                   }
               	var a:Number;
               	var b:Number;
               	if(dataTransform && dataTransform.getAxis(CartesianTransform.HORIZONTAL_AXIS) is NumericAxis &&
           		(dataTransform.getAxis(CartesianTransform.HORIZONTAL_AXIS) as NumericAxis).direction == "inverted")
           		{
           			a = x;
           			b = v.x;
           		}
           		else
           		{
           			a = v.x;
           			b = x;
           		}
                   if (a < b)
                   {
                       low = cur;
                       cur = Math.floor((low + high) / 2);
                       if (cur == low)
                           break;
                   }
                   else
                   {
                       high = cur;
                       cur = Math.floor((low + high) / 2);
                       if (cur == high)
                           break;
                   }
               }
           }
           else
           {
               var i:uint;
               for (i = 0; i < n; i++)
               {
                  v = renderData.filteredCache[i];
                  if (!isNaN(v.yNumber) && !isNaN(v.xNumber))
                   {
                      dist = (v.x  - x)*(v.x  - x) + (v.y - y)*(v.y -y);
                      if (dist <= minDist2)
                      {
                          minDist2 = dist;
                          minItem = v;
                      }
                   }
              }
           }

           if (minItem)
           {
               var hd:HitData = new HitData(createDataID(minItem.index),
                                            Math.sqrt(minDist2),
                                            minItem.x, minItem.y, minItem);
               hd.contextColor = GraphicsUtilities.colorFromFill(getStyle("areaFill"));

               hd.dataTipFunction = formatDataTip;
               return [ hd ];
           }

           return [];
       }

    /**
         *  @private
         */
        private function formatDataTip(hd:HitData):String
        {
            var dt:String = "";
            var n:String = displayName;
            if (n && n != "")
                dt += "<b>"+ n + "</b><BR/>";

            var xName:String = dataTransform.getAxis(CartesianTransform.HORIZONTAL_AXIS).displayName;
            if (xName == "")
                xName = xField;
            if (xName != "")
                dt += "<i>" + xName + ": </i>";

            var item:AreaSeriesItem = AreaSeriesItem(hd.chartItem);
            var lowItem:AreaSeriesItem = (minField != "") ?
                                         item :
                                         null;
            dt += dataTransform.getAxis(CartesianTransform.HORIZONTAL_AXIS).formatForScreen(item.xValue) + "\n";

            var yName:String = dataTransform.getAxis(CartesianTransform.VERTICAL_AXIS).displayName;

            if (!lowItem)
            {
                if (yName != "")
                    dt += "<i>" + yName + ":</i> ";
                dt += dataTransform.getAxis(CartesianTransform.VERTICAL_AXIS).formatForScreen(item.yValue) + "\n";
            }
            else
            {
                if (yName != "")
                    dt += "<i>" + yName + " (high):</i> ";
                else
                    dt += "<i>high: </i>";
                dt += dataTransform.getAxis(CartesianTransform.VERTICAL_AXIS).formatForScreen(item.yValue) + "\n";

                if (yName != "")
                    dt += "<i>" + yName + " (low):</i> ";
                else
                    dt += "<i>low:</i> ";
                dt += dataTransform.getAxis(CartesianTransform.VERTICAL_AXIS).formatForScreen(lowItem.yValue) + "\n";
            }

            return dt;
        }
}
}
