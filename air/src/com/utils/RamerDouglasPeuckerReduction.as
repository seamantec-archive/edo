package com.utils
{
	public class RamerDouglasPeuckerReduction
	{
		private var _points:Vector.<Object>;
		public function RamerDouglasPeuckerReduction(remotePoints:Vector.<Object>)
		{
			this.points = remotePoints;
		}
		
		
		public function RDPsimplify(Tolerance:Number):Vector.<Object>
		{
			if(points==null||points.length<3||Tolerance==0)
				return points;
			var firstPoint:int=0;
			var lastPoint:int=points.length-1;
			var pointIndexsToKeep:Vector.<int>=new Vector.<int>;
			pointIndexsToKeep[0]=firstPoint
			pointIndexsToKeep[1]=lastPoint
			//p1.x==p2.x && p1.y==p2.y is 4x faster than p1.equals(p2)    
			while(points[firstPoint].x==points[lastPoint].x && points[firstPoint].y==points[lastPoint].y  && lastPoint >0)
			{
				lastPoint--;
			}
			rdpReduction(points, firstPoint, lastPoint, Tolerance, pointIndexsToKeep);
			var newPoints:Vector.<Object>=new Vector.<Object>();
			pointIndexsToKeep.sort(Array.NUMERIC)
			var len:int=pointIndexsToKeep.length-1;
			for(var i:int=0; i<len; i++)
			{
				newPoints[i]=points[pointIndexsToKeep[i]];
			}
			return newPoints;
		}
		
		private function rdpReduction(points:Vector.<Object>, firstPoint:int, lastPoint:int, tolerance:Number, pointIndexsToKeep:Vector.<int>):void
		{
			var maxDistance:Number=0;
			var indexFarthest:int=0;
			for(var index:int=firstPoint; index<lastPoint; index++)
			{
				var distance:Number=perpendicularDistance(points[firstPoint], points[lastPoint], points[index]);
				if(distance>maxDistance)
				{
					maxDistance=distance;
					indexFarthest=index;
				}
			}
			if(maxDistance>tolerance&&indexFarthest!=0)
			{
				pointIndexsToKeep.push(indexFarthest);
				rdpReduction(points, firstPoint, indexFarthest, tolerance, pointIndexsToKeep);
				rdpReduction(points, indexFarthest, lastPoint, tolerance, pointIndexsToKeep);
			}
		}
		
		private function perpendicularDistance(point1:Object, point2:Object, point:Object):Number
		{
			var area:Number=Math.abs((point1.x*point2.y+point2.x*point.y+point.x*point1.y-point2.x*point1.y-point.x*point2.y-point1.x*point.y)/2);
			var bottom:Number=Math.sqrt(((point1.x-point2.x)*(point1.x-point2.x))+((point1.y-point2.y)*(point1.y-point2.y)));
			return (area/bottom)*2;
		}
		public function get points():Vector.<Object>
		{
			return _points;
		}
		
		public function set points(value:Vector.<Object>):void
		{
			_points = value;
		}

	}
}