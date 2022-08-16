/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.10.28.
 * Time: 10:15
 * To change this template use File | Settings | File Templates.
 */
package com.polar {
import flash.geom.Point;
import flash.utils.getTimer;

import shapes2d.curves.Cardinal;

public class PolarTable {

    public static const MAX_WINDSPEED:uint = 30;
    public static const RES:uint = 1;

    public static const WIND_ROUND:uint = 1;
    public static const MIRROR_ENABLED:Boolean = true;
    public static const MAX_INTERPOLATIONW:uint = 30;

    /**
     * table holds data in two dimensional vector
     * outside vector is wind speed, inside is wind direction and boat speeds(measured and calculated);
     * Wind speed is from 0-70 knots.
     * Wind direction is 0-360 degree;
     * */
    private var _table:Vector.<Vector.<PolarBoatSpeed>> = new Vector.<Vector.<PolarBoatSpeed>>(MAX_WINDSPEED, true);
    //each wind has 4 best vmg
    private var _bestVmg:Vector.<Vector.<BestVmg>> = new Vector.<Vector.<BestVmg>>(MAX_WINDSPEED, true);
    private var wind5Avg:Vector.<PolarData> = new Vector.<PolarData>()
    private var wind3Avg:Vector.<PolarData> = new Vector.<PolarData>()
    private var wind120Avg:Vector.<PolarData> = new Vector.<PolarData>()
    private var numberOfFailFlags:Vector.<Boolean> = new <Boolean>[];
    public static var measuredMaxWeight:Number = 1.3;
    public static var vInterpolatedWeight:Number = 20;
    public static var hInterpolatedWeight:Number = 10;
    public static var mInterpolatedWeight:Number = 20;
    public static var angleAvg:uint = 4;


    public static var bypass1:Boolean = false;
    public static var bypass2:Boolean = false;
    public static var bypass3:Boolean = false;
    public static var bypass4:Boolean = false;
    public static var bypass5:Boolean = false;
    public static var bypass6:Boolean = false;

    public static var horizontalInterpolationEnabled:Boolean = true;
    public static var verticalInterpolationEnabled:Boolean = true;
    public static var showForceFields:Boolean = false;
    public static var tension:Number = 0.4;

    private var _minPolarSpeed:Number;
    private var _maxPolarSpeed:Number;

    private var _hasPolarForWind:Vector.<Boolean>;


    public static function turnBypassesOff():void {
        bypass1 = false;
        bypass2 = false;
        bypass3 = false;
        bypass4 = false;
        bypass5 = false;
        bypass6 = false;
    }

    public function PolarTable() {
        initTableByWind();

        _minPolarSpeed = NaN;
        _maxPolarSpeed = NaN;

        _hasPolarForWind = new Vector.<Boolean>(MAX_WINDSPEED);
    }

    public function mergeOther(otherTable:PolarTable):void {
        for (var wind:int = 0; wind < MAX_WINDSPEED; wind++) {
            for (var angle:int = 0; angle < 360; angle++) {
                _table[wind][angle].setMaxFromOtherPolar(otherTable.table[wind][angle].cardinalHardCalculated);
            }
        }
    }

    private function initTableByWind():void {
        for (var i:int = 0; i < MAX_WINDSPEED; i++) {
            _table[i] = new Vector.<PolarBoatSpeed>(360, true);
            for (var j:int = 0; j < 360; j++) {
                _table[i][j] = new PolarBoatSpeed(i);
            }
        }
    }

    public function get table():Vector.<Vector.<PolarBoatSpeed>> {
        return _table;
    }


    public function set table(value:Vector.<Vector.<PolarBoatSpeed>>):void {
        _table = value;
    }

    public function addFileData(polarData:PolarData):void {
        if (!polarData.isValid() || polarData.windSpeed >= MAX_WINDSPEED || polarData.windSpeed === 0) {
            return;
        }
        var container:Vector.<PolarBoatSpeed> = _table[polarData.windSpeed];
        if (container[0] === null) {
            for (var i:int = 0; i < 360; i++) {
                container[i] = new PolarBoatSpeed(polarData.windSpeed);
            }
        }

        container[polarData.windDir].baseCalculated = polarData.boatSpeed;
        container[polarData.windDir].isFromFile = true;
        container[polarData.windDir].calculateRatio();
    }

    public function addData(polarData:PolarData):void {
        var windSpeed:int = Math.round(polarData.windSpeed / WIND_ROUND) * WIND_ROUND;
        if (windSpeed >= MAX_WINDSPEED) {
            return;
        }
        var windDirection:int = Math.floor(polarData.windDir);
        if (windDirection < 0) {
            windDirection = 360 + windDirection;
        }
        var container:Vector.<PolarBoatSpeed> = _table[windSpeed];
        if (container[0] === null) {
            for (var i:int = 0; i < 360; i++) {
                container[i] = new PolarBoatSpeed(windSpeed);
            }
        }

        if (addToAvgs(polarData)) {
            var isValid:Boolean = validateData();
            if (numberOfFailFlags.length > 24) {
                numberOfFailFlags.shift();
            }
            numberOfFailFlags.push(isValid)
            if (isValid) {
                PolarContainer.instance.addData(polarData);
                container[windDirection].setMax(polarData.boatSpeed);
            }
        }
    }


    public function getValueForWSpeedAndDirection(windSpeed:int, windAngle:int):PolarBoatSpeed {
        if (windSpeed < MAX_WINDSPEED) {
            var pbs:PolarBoatSpeed = _table[windSpeed][windAngle];
            if (pbs != null) {
                return pbs;
            }
        }
        return null;
    }

    public function hasPolarForWind(wind:Number):Boolean {
        wind = Math.round(wind);
        if (wind < 0 || wind >= MAX_WINDSPEED) {
            return false;
        }
        return _hasPolarForWind[wind];
    }

    public static function setWindFilterLow():void {
        turnBypassesOff();
        w120AvgN = 80;
        w5AvgN = 4;
        w3AvgN = 3;

    }

    public static function setWindFilterMed():void {
        turnBypassesOff();
        w120AvgN = 40;
        w5AvgN = 3;
        w3AvgN = 2;
    }

    public static function setWindFilterHigh():void {
        turnBypassesOff();
        w120AvgN = 120;
        w5AvgN = 5;
        w3AvgN = 3;
    }

    private static var w3AvgN:int = 3;
    private static var w5AvgN:int = 5;
    private static var w120AvgN:int = 120;

    private function addToAvgs(polarData:PolarData):Boolean {
        if (polarData.boatSpeed > polarData.windSpeed * 1.3) {
            return false;
        }
        if (wind3Avg.length >= w3AvgN) {
            wind3Avg.shift();
        }

        if (wind5Avg.length >= w5AvgN) {
            wind5Avg.shift();
        }

        if (wind120Avg.length >= w120AvgN) {
            wind120Avg.shift();
        }
        wind120Avg.push(polarData);
        wind3Avg.push(polarData);
        wind5Avg.push(polarData);
        return true;
    }


    /**
     * This method is validating wind datas, with Wind Quality Algorithm.
     *
     * */
    private function validateData():Boolean {
        var ws5Avg:Number = 0;  //wind speed
        var wd5Avg:Number = 0; //wind direction

        var ws3Avg:Number = 0;
        var wd3Avg:Number = 0;

        var ws120Avg:Number = 0;
        var wd120Avg:Number = 0;

        var numberOfFail:int = 0;

        for (var i:int = 0; i < numberOfFailFlags.length; i++) {
            if (!numberOfFailFlags[i]) numberOfFail++;
        }

        if (wind3Avg.length < w3AvgN || wind5Avg.length < w5AvgN) {
            return false;
        }

        for (var i:int = 0; i < wind120Avg.length; i++) {
            if (i < w3AvgN) {
                ws3Avg += wind3Avg[i].windSpeed;
                wd3Avg += wind3Avg[i].windDir;
            }
            if (i < w5AvgN) {
                ws5Avg += wind5Avg[i].windSpeed;
                wd5Avg += wind5Avg[i].windDir;
            }
            ws120Avg += wind120Avg[i].windSpeed;
            wd120Avg += wind120Avg[i].windDir;
        }
        ws3Avg /= w3AvgN;
        ws5Avg /= w5AvgN;
        ws120Avg /= wind120Avg.length;
        wd3Avg /= w3AvgN;
        wd5Avg /= w5AvgN;
        wd120Avg /= wind120Avg.length;

        var criteriaTrue1:Boolean = bypass1 ? true : (ws3Avg >= 0 || ws3Avg < 165) && (ws3Avg >= 0 || ws3Avg < 165)
        var criteriaTrue2:Boolean = bypass2 ? true : (ws3Avg - ws5Avg) > -1;
        var criteriaTrue3:Boolean = bypass3 ? true : !(ws5Avg < 12 && ws3Avg > 15);
        var criteriaTrue4:Boolean = bypass4 ? true : !(ws5Avg > 12 && Math.abs(wd5Avg - wd3Avg) > 30);
        var criteriaTrue5:Boolean = bypass5 ? true : !(ws5Avg >= 12 && ws3Avg > (2.5 * ws120Avg));
        var criteriaTrue6:Boolean = bypass6 ? true : !(ws120Avg <= 6 && ws3Avg > 6 && ws3Avg > (2.5 * ws120Avg));

        if (numberOfFail < 7 && criteriaTrue1 &&
                criteriaTrue2 && criteriaTrue3 &&
                criteriaTrue4 && criteriaTrue5 && criteriaTrue6) {
            return true;
        }

        return false;
    }

    public function polarLoadReadyForFile() {
        resetInterpolations();
        interpolateHorizontalForFile();
        interpolateVerticalForFile();
        combineInterpolationsForFile();
        fillBestVmgs();
        calculatePolarSpeedMinMax();
    }

    private function interpolateHorizontalForFile():void {
        var points:Vector.<Point> = new <Point>[];

        for (var w:int = 0; w < _table.length; w++) {
            for (var i:int = 181; i < 360; i++) {
                if (_table[w][i] != null && _table[w][i].baseCalculated != 0) {
                    _table[w][i].baseCalculated = 0;
                }

            }
        }
        var windsWithBaseData:Vector.<Number> = getWindsWhereHasBaseCalculated();
        for (var i:int = 0; i < windsWithBaseData.length; i++) {
            points.length = 0;
            var wind:Number = windsWithBaseData[i];
            for (var angle:int = 0; angle <= 180; angle++) {
                if (angle === 0) {
                    points.push(new Point(0, 0));
                } else {
                    if (_table[wind][angle] != null && _table[wind][angle].baseCalculated != 0) {
                        points.push(new Point(angle, _table[wind][angle].baseCalculated))
                        if (_table[wind][angle] != null && 360 - angle < 360 && 360 - angle >= 0 && angle != 180 && _table[wind][360 - angle] != null) {
                            _table[wind][360 - angle].baseCalculated = _table[wind][angle].baseCalculated
                            _table[wind][360 - angle].isFromFile = true;
                            if (_table[wind][360 - angle].baseCalculated != 0) {
                                points.push(new Point(360 - angle, _table[wind][360 - angle].baseCalculated));
                            }
                        }
                    }
                }
            }
            points.push(new Point(360, 0));
            if (points.length > 2) {
                points.sort(sortByX)
                var v:Vector.<Point> = new Vector.<Point>();
                var interpolatedPoints:Vector.<Point> = Cardinal.compute(points, .1, tension);
                interpolatePointsToVector(interpolatedPoints, v, 1)
                for (var j:int = 0; j < v.length; j++) {
                    if (v[j].x < 0 || v[j].x >= 360) {
                        //                        trace("vjx", v[j].x)
                        continue;
                    }
                    _table[wind][v[j].x].combinedMeasured = v[j].y
                }
            }

        }
    }

    private function interpolateVerticalForFile() {
        var points:Vector.<Point> = new <Point>[];
        for (var angle:int = 0; angle < 360; angle++) {
            points.length = 0;
            for (var wind:int = 0; wind < _table.length; wind++) {
                if (wind === 0) {
                    points.push(new Point(0, 0));
                } else {
                    if (_table[wind][angle] != null && _table[wind][angle].combinedMeasured != 0) {
                        points.push(new Point(wind, _table[wind][angle].combinedMeasured))
                    }
                }
            }
            if (points.length >= 2) {
                var v:Vector.<Point> = new Vector.<Point>();
                points.sort(sortByX);
                var interpolatedPoints:Vector.<Point> = Cardinal.compute(points, .1, tension);
                interpolatedPoints.sort(sortByX);
                interpolatePointsToVector(interpolatedPoints, v, 1)
                for (var j:int = 0; j < v.length; j++) {
                    if (v[j].x % 1 == 0 && v[j].x >= 0 && v[j].x < MAX_WINDSPEED && _table[v[j].x][angle] != null) {
                        _table[v[j].x][angle].verticalInterpolated = v[j].y
                    }
                }
            }
        }
    }


    private function combineInterpolationsForFile():void {
        for (var wind:int = 0; wind < _table.length; wind++) {
            var needVertical:Boolean = true;
            for (var angle1:int = 0; angle1 < 360; angle1++) {
                var pbs:PolarBoatSpeed = _table[wind][angle1];
                if (pbs === null) {
                    break;
                }
                if (pbs.baseCalculated != 0) {
                    needVertical = false;
                    break;
                }

            }
            for (var i:int = 0; i < 360; i++) {
                var pbs:PolarBoatSpeed = _table[wind][i];
                if (pbs === null) {
                    break;
                }
                var sums:Number = 0;
                var weight:Number = 0;
                if (pbs.verticalInterpolated != 0 && needVertical) {
                    sums += pbs.verticalInterpolated * vInterpolatedWeight;
                    weight += vInterpolatedWeight;
                }

                if (pbs.combinedMeasured != 0) {
                    sums += pbs.combinedMeasured * mInterpolatedWeight;
                    weight += mInterpolatedWeight;
                }
                if (weight > 0) {
                    pbs.combinedInterpolated = sums / weight;
                    pbs.cardinalHardCalculated = pbs.combinedInterpolated >= 0 ? pbs.combinedInterpolated : 0;
                    _hasPolarForWind[wind] = true;
                }
            }
        }

    }

    public function polarLoadReady(isFileLoading:Boolean = false):void {

        var t:Number = getTimer();
        resetInterpolations();
        if (isFileLoading) {
            calculateAvgDatasForFile()
        } else {
            calculateAvgDatas();
        }
        if (verticalInterpolationEnabled) {
            interpolateVertical();
        }
        if (horizontalInterpolationEnabled) {
            interpolateHorizontal();
        }
        combineInterpolations();
        calcCardinal();
        fillBestVmgs();

        calculatePolarSpeedMinMax();

//        trace("-------------NUMBER OF MAXES----------")
//        for (var wind:int = 0; wind < _table.length; wind++) {
//            var maxCounter:int = 0;
//            for (var angle:int = 0; angle < 360; angle++) {
//                if (_table[wind][angle].measured != 0) {
//                    maxCounter++;
//                }
//
//            }
//            trace("max for wind:", wind, "=>", maxCounter);
//
//        }
//        trace("----------------------------------------")
//        trace("timespent for polar", getTimer() - t);
    }


    private function combineInterpolations():void {
        for (var wind:int = 0; wind < _table.length; wind++) {
            for (var i:int = 0; i < 360; i += angleAvg) {
                var pbs:PolarBoatSpeed = _table[wind][i];
                if (pbs === null) {
                    break;
                }
                var sums:Number = 0;
                var weight:Number = 0;
                if (pbs.verticalInterpolated != 0) {
                    sums += pbs.verticalInterpolated * vInterpolatedWeight;
                    weight += vInterpolatedWeight;
                }
                if (pbs.horizontalInterpolated != 0) {
                    sums += pbs.horizontalInterpolated * hInterpolatedWeight;
                    weight += hInterpolatedWeight;
                }
                if (pbs.combinedMeasured != 0) {
                    sums += pbs.combinedMeasured * mInterpolatedWeight;
                    weight += mInterpolatedWeight;
                }
                if (weight > 0) {
                    pbs.combinedInterpolated = sums / weight;
                }
            }
        }

    }

    private function calcCardinal():void {
        for (var i:int = 0; i < MAX_WINDSPEED; i++) {
            //createTableForWind(i);
            var points:Vector.<Point> = new <Point>[];
            for (var j:int = 0; j <= 360; j += RES) {
                if (j === 360) {
                    points.push(new Point(359, 0));
                    continue;
                }
                var pbs:PolarBoatSpeed = _table[i][j];
                if (pbs === null) {
                    break;
                }
                if (j === 0) {
                    points.push(new Point(0, 0))
                } else if (pbs.combinedInterpolated != 0) {  //
                    points.push(new Point(j, pbs.combinedInterpolated))
                }
            }

            if (points.length > 0) {
//                interpolateCategory(Cardinal.compute(points, .1, .9), i, "cardinalCalculated");  //pink FF00FF
                //interpolateCategory(Cardinal.compute(points, .1, .5), i, "cardinalMediumCalculated");// skyblue3399FF
                interpolateCategory(Cardinal.compute(points, .1, .15), i, "cardinalHardCalculated"); // light green 00FF99
                //interpolateCategory(CatmullRom.compute(points), i, "catmullRomCalculated"); //yellow FFFF00
//                interpolateCategory(Cubic.compute(points), i, "cubicCalculated");
//                interpolateCategory(Hermite.compute(points), i, "hermiteCalculated");
            }
        }
    }

    private function interpolateCategory(points2:Vector.<Point>, wind:int, parameterName:String):void {

        points2.sort(sortByX)
        for (var j:int = 0; j < points2.length; j++) {
            if (j + 1 < points2.length) {
                interpolateBetweenPoints(points2[j], points2[j + 1], wind, parameterName)
            }
        }

    }

    private function resetInterpolations():void {
        for (var wind:int = 0; wind < _table.length; wind++) {
            for (var angle:int = 0; angle < 360; angle++) {
                _table[wind][angle].verticalInterpolated = 0;
                _table[wind][angle].horizontalInterpolated = 0;
                _table[wind][angle].combinedMeasured = 0;
                _table[wind][angle].combinedInterpolated = 0;
                _table[wind][angle].cardinalHardCalculated = 0;
            }
            _hasPolarForWind[wind] = false;
        }
    }

    private function interpolateVertical():void {
        var points:Vector.<Point> = new <Point>[];
        for (var angle:int = 0; angle < 360; angle += angleAvg) {
            points.length = 0;
            for (var wind:int = 0; wind < _table.length; wind++) {
                if (wind === 0) {
                    points.push(new Point(0, 0));
                } else {
                    if (_table[wind][angle] != null && _table[wind][angle].combinedMeasured != 0) {
                        points.push(new Point(wind, _table[wind][angle].combinedMeasured))
                    } else if (MIRROR_ENABLED && 360 - angle < 360 && 360 - angle >= 0 && _table[wind][360 - angle] != null && _table[wind][360 - angle].combinedMeasured != 0) {
                        if (angle - angleAvg >= 0 && _table[wind][angle - angleAvg].combinedMeasured === 0 && angle + angleAvg < 360 && _table[wind][angle + angleAvg].combinedMeasured === 0) {

                            points.push(new Point(wind, _table[wind][360 - angle].combinedMeasured))
                        }
                    }
                }
            }
            if (points.length > 2) {
                var v:Vector.<Point> = new Vector.<Point>();
                var prevBs:Number = 0;
                for (var i:int = 0; i < points.length; i++) {
                    if (prevBs > points[i].y * 1.2) {
                        _table[points[i].x][angle].combinedMeasured = 0;
                        prevBs = points[i].y;
                        points.splice(i, 1);
                    } else {
                        prevBs = points[i].y;
                    }
                }
                var interpolatedPoints:Vector.<Point> = Cardinal.compute(points, .1, .4);
                interpolatedPoints.sort(sortByX);

                interpolatePointsToVector(interpolatedPoints, v, 1)
                for (var j:int = 0; j < v.length; j++) {
                    if (v[j].x % 1 == 0 && v[j].x >= 0 && v[j].x < MAX_WINDSPEED && _table[v[j].x][angle] != null) {
                        _table[v[j].x][angle].verticalInterpolated = v[j].y
                    }
                }
            }
        }

    }


    private function interpolateHorizontal():void {
        var points:Vector.<Point> = new <Point>[];
        for (var wind:int = 0; wind < _table.length; wind++) {
            points.length = 0;
            for (var angle:int = 0; angle < 360; angle += angleAvg) {
                if (angle === 0) {
                    points.push(new Point(0, 0));
                } else {
                    if (_table[wind][angle] != null && _table[wind][angle].combinedMeasured != 0) {
                        points.push(new Point(angle, _table[wind][angle].combinedMeasured))
                    } else if (MIRROR_ENABLED &&
                            360 - angle < 360 &&
                            360 - angle >= 0 &&
                            _table[wind][360 - angle] != null &&
                            _table[wind][360 - angle].combinedMeasured != 0) {
                        if (angle - angleAvg >= 0 && _table[wind][angle - angleAvg].combinedMeasured === 0 && angle + angleAvg < 360 && _table[wind][angle + angleAvg].combinedMeasured === 0) {
                            points.push(new Point(angle, _table[wind][360 - angle].combinedMeasured))
                        }
                    }
                }
            }
            if (points.length > 2) {
                var v:Vector.<Point> = new Vector.<Point>();
                var interpolatedPoints:Vector.<Point> = Cardinal.compute(points, .1, .4);
                interpolatePointsToVector(interpolatedPoints, v, angleAvg)
                for (var j:int = 0; j < v.length; j++) {
                    if (v[j].x < 0 || v[j].x >= 360) {
//                        trace("vjx(horizontal)", v[j].x)
                        continue;
                    }
                    _table[wind][v[j].x].horizontalInterpolated = v[j].y
                }
            }

        }
    }

    private function getCombineMeasured(wind:int, angle:int, points:Vector.<Point>):void {
        if (_table[wind][angle] != null && _table[wind][angle].combinedMeasured != 0) {
            points.push(new Point(angle, _table[wind][angle].combinedMeasured))
        } else if (MIRROR_ENABLED &&
                360 - angle < 360 &&
                360 - angle >= 0 &&
                _table[wind][360 - angle] != null &&
                _table[wind][360 - angle].combinedMeasured != 0) {
//            if (angle - ANGLE_AVG >= 0 && _table[wind][angle - ANGLE_AVG].combinedMeasured === 0 && angle + ANGLE_AVG < 360 && _table[wind][angle + ANGLE_AVG].combinedMeasured === 0) {
            points.push(new Point(angle, _table[wind][360 - angle].combinedMeasured))
//            }
        }
    }

    private function sortByX(a:Point, b:Point):int {
        if (a.x < b.x) {
            return -1
        } else if (a.x > b.x) {
            return 1
        } else {
            return 0;
        }
    }

    internal function interpolateBetweenPoints(point1:Point, point2:Point, wind:int, parameterName:String, distance:int = 1):void {
//        if(point1.x>point2.x){
//            return;
//        }
        var distX:Number = point2.x - point1.x;
        var start:int = Math.floor(point1.x);
        var rDist:Number = Math.floor(point2.x) - start;
        if (rDist < distance) {
            return;
        }
        var distY:Number = Math.abs(point2.y - point1.y);
        var alfa:Number = Math.atan2(distY, distX);
        var nSegments:int = rDist / distance;

        for (var i:int = 1; i <= nSegments; i++) {
            if (i + start < 360 && i + start > 0) {
                _table[wind][i + start] ||= new PolarBoatSpeed(wind);
                if (alfa === 0) {
                    _table[wind][i + start][parameterName] = point1.y
                    continue;
                }
                if (point1.y < point2.y) {
                    _table[wind][i + start][parameterName] = point1.y + (i + start - point1.x) * Math.tan(alfa);
                } else {
                    _table[wind][i + start][parameterName] = point1.y - (i + start - point1.x) * Math.tan(alfa);

                }
            }
        }
    }

    internal function interpolatePointsToVector(points:Vector.<Point>, target:Vector.<Point>, distance:int = 1):void {
        points.sort(sortByX)
        for (var i:int = 0; i < points.length; i++) {
            if (i === 0) {
                target.push(points[i])
            }
            if (i + 1 < points.length) {
                interpolateBetweenPointsToVector(points[i], points[i + 1], target, distance);
            }
        }
    }

    internal function interpolateBetweenPointsToVector(point1:Point, point2:Point, target:Vector.<Point>, distance:int = 1):void {
        if (point1.x > point2.x) {
            return;
        }
        var distX:Number = point2.x - point1.x;
        var start:int = Math.floor(Math.floor(point1.x) / distance) * distance;
        var rDist:Number = Math.floor(point2.x) - start;
        if (rDist < distance) {
            return;
        }
        var distY:Number = Math.abs(point2.y - point1.y);
        var alfa:Number = Math.atan2(distY, distX);
        var nSegments:int = rDist / distance;

        for (var i:int = 1; i <= nSegments; i++) {
            var x:int = i * distance
            if (alfa === 0) {
                target.push(new Point(x + start, point1.y))
            }
            if (point1.y < point2.y) {
                target.push(new Point(x + start, point1.y + (x + start - point1.x) * Math.tan(alfa)))
            } else {
                target.push(new Point(x + start, point1.y - (x + start - point1.x) * Math.tan(alfa)))
            }
        }
    }

    internal function calculateAvgDatasForFile():void {
        var points:Vector.<Point> = new <Point>[];
        for (var wind:int = 0; wind < _table.length; wind++) {
            points.length = 0;
            for (var angle:int = 0; angle < 360; angle++) {
                if (angle === 0) {
                    points.push(new Point(0, 0));
                } else {
                    if (_table[wind][angle] != null && _table[wind][angle].measured != 0) {
                        points.push(new Point(angle, _table[wind][angle].measured))
                    }
                }
            }
            if (points.length > 2) {
                var v:Vector.<Point> = new Vector.<Point>();
                var interpolatedPoints:Vector.<Point> = Cardinal.compute(points, .1, .4);
                interpolatePointsToVector(interpolatedPoints, v, 1)

                for (var j:int = 0; j < v.length; j++) {
                    if (v[j].x < 0 || v[j].x >= 360) {
//                        trace("vjx", v[j].x)
                        continue;
                    }
                    _table[wind][v[j].x].combinedMeasured = v[j].y
                }
            }
        }

    }

    internal function calculateAvgDatas():void {
        for (var i:int = 0; i < 360; i += angleAvg) {
            setMeasuredDatasForAngle(i)
        }
    }

    internal function setMeasuredDatasForAngle(angle:int):void {
        for (var i:int = 0; i < _table.length; i++) {
            if (_table[i][angle] != null) {
                _table[i][angle].combinedMeasured = getAvgMeasuerd(angle, i);
            }
        }
    }

    internal function getAvgMeasuerd(angle:int, wind:int):Number {
        var sums:Number = 0;
        var counter:int = 0;
        var max:Number = 0;
        var sumsContainer:Vector.<Number> = new <Number>[];
        for (var j:int = 0; j <= Math.round(angleAvg / 2); j++) {
            var a:Number = 0
            if (angle + j < 360 && _table[wind][angle + j] != null && _table[wind][angle + j].measured != 0) {
                a = _table[wind][angle + j].measured;
                counter++;
                sums += a;
                sumsContainer.push(a);
            }
            if (angle - j >= 0 && _table[wind][angle - j] != null && _table[wind][angle - j].measured != 0) {
                a = _table[wind][angle - j].measured;
                counter++;
                sums += a;
                sumsContainer.push(a);
            }
            if (a > max) {
                max = a;
            }
        }
        sumsContainer = sumsContainer.sort(Array.CASEINSENSITIVE);
        var avg:Number = getCustomWeightedAvg(sumsContainer) //sums / counter;
        var rNumber:Number = 0;
        //8,9 diff 1
//        if (Math.abs(1 - avg / max) < 0.6) {
//            rNumber = max;
//        } else {
        //trace(angle, "|", wind, ":", avg, getCustomWeightedAvg(sumsContainer));

        rNumber = avg;
//        }
        if (isNaN(rNumber)) {
            rNumber = 0;
        }
        return rNumber
    }

    internal function getCustomWeightedAvg(numbers:Vector.<Number>):Number {
        var startNumber:Number = 0;
        var numberOfItems:int = numbers.length;
        var delta:Number = 1 / numberOfItems;
        var sum:Number = 0;
        var weights:Number = 0;
        var tempSum:Number = 0;
        var indexSums:Number = 0;
        var indexCounter:Number = 0;
        var weight:Number = 0;
        for (var i:int = 0; i < numbers.length; i++) {
            var item:Number = numbers[i];
            if (Math.round((item - startNumber) * 100) / 100 > 0.1) {
                if (tempSum != 0) {
                    weight = indexCounter * delta * (indexSums / indexCounter);
                    sum += (tempSum / indexCounter) * weight;
                    weights += weight;
                }
                //start new group
                tempSum = 0;
                indexSums = 0;
                indexCounter = 0;
                startNumber = item;
            }
            tempSum += item;
            indexSums += Math.pow(measuredMaxWeight, i + 1); //(i + 1)*
            indexCounter++;
        }
        weight = indexCounter * delta * (indexSums / indexCounter);
        sum += (tempSum / indexCounter) * weight;
        weights += weight;
        return sum / weights;
    }


    internal function getContentForExport():String {
        var str:String = "";
        //create header
        str += "angle;";
        for (var wind:int = 6; wind < MAX_WINDSPEED; wind++) {
            str += wind + ";";
        }
        str += "\n";
        for (var deg:int = 15; deg < 360; deg += 15) {
            str += deg + ";";
            for (var wind:int = 6; wind < MAX_WINDSPEED; wind++) {
                str += Math.round(_table[wind][deg].cardinalHardCalculated * 10) / 10 + ";"
                if (wind === MAX_WINDSPEED - 1) {
                    str += "\n";
                }
            }

        }
        return str;
    }

    internal function getContentForExportJustBaseDatas():String {
        var str:String = "";
        //create header
        str += "angle;";
        var winds = getWindsWhereHasBaseCalculated();
        for (var i:int = 0; i < winds.length; i++) {
            str += winds[i] + ";";
        }
        str += "\n";
        for (var deg:int = 0; deg <= 180; deg++) {
            str += deg + ";";
            for (var i:int = 0; i < winds.length; i++) {
                str += (_table[winds[i]][deg].baseCalculated == 0 ? " " : Math.round(_table[winds[i]][deg].baseCalculated * 10) / 10) + ";"
                if (i === winds.length - 1) {
                    str += "\n";
                }
            }
        }
//        str = str.replace(/([0-9]+;(\s;){3}\n)/img, "");
        str = str.replace(/(^[0-9]+;(\s;)*\n)/img, "");
        return str;
    }

    public function get content():String {
        return getContentForExportJustBaseDatas();
    }

    private function getWindsWhereHasBaseCalculated():Vector.<Number> {
        var winds:Vector.<Number> = new <Number>[]
        for (var wind:int = 0; wind < _table.length; wind++) {
            for (var i:int = 0; i < 360; i++) {
                if (_table[wind][i].baseCalculated != 0) {
                    winds.push(wind);
                    break;
                }
            }
        }

        return winds;
    }

    /*
     * return best vmg;
     *
     * */
    public function getBestVmg(windSpeed:Number, windDirection:Number):BestVmg {
        windSpeed = Math.round(windSpeed);
        windDirection = Math.floor(windDirection);
        if (windSpeed < MAX_WINDSPEED && _bestVmg[windSpeed] != null) {
            var dir:int = Math.floor(windDirection / 90);
            return _bestVmg[windSpeed][dir];
        }
        return null;
    }

    public function getPerformanceForAngle(windSpeed:Number, windDirection:Number, boatSpeed:Number):Number {
        var resolution:uint = 10;
        var downWind:int = int(windSpeed);
        var upWind:int = downWind+1;
        var decimal:int =Math.round((windSpeed - downWind)*resolution);
        var upWindSpeed:Number = 0;
        var downWindSpeed:Number = 0;
        windDirection = Math.floor(windDirection);
        if (upWind >= MAX_WINDSPEED) {
            return -1;
        }

        if (_table[downWind] != null && _table[downWind][windDirection] != null && _table[downWind][windDirection].cardinalHardCalculated != 0) {
            downWindSpeed = _table[downWind][windDirection].cardinalHardCalculated;
        }

        if (_table[upWind] != null && _table[upWind][windDirection] != null && _table[upWind][windDirection].cardinalHardCalculated != 0) {
            upWindSpeed = _table[upWind][windDirection].cardinalHardCalculated;
        }
        if(downWindSpeed != 0 && upWindSpeed != 0){
            trace("old: ", windSpeed, "|", windDirection, "|", boatSpeed, "|",  boatSpeed / _table[Math.round(windSpeed)][windDirection].cardinalHardCalculated, "|",_table[Math.round(windSpeed)][windDirection].cardinalHardCalculated, "new: ", boatSpeed / (downWindSpeed + ((upWindSpeed-downWindSpeed)/resolution)*decimal), "|",(downWindSpeed + ((upWindSpeed-downWindSpeed)/resolution)*decimal), " | ", downWind, "|", upWind, "|", decimal, "|", downWindSpeed, "|", upWindSpeed);
            return boatSpeed / (downWindSpeed + ((upWindSpeed-downWindSpeed)/resolution)*decimal);
        }

        return -1;
    }

    public function getPerformance(windSpeed:Number, boatSpeed:Number):Number {
        windSpeed = Math.round(windSpeed);
        var maxDatas:Object = findMaxForWind(windSpeed);
        if (maxDatas === null) {
            return -1
        }
        return boatSpeed / maxDatas.maxSpeed;
    }

    public function findMaxForWind(windSpeed:Number):Object {
        windSpeed = Math.round(windSpeed);
        if (windSpeed >= MAX_WINDSPEED) {
            return null;
        }
        if (_table[windSpeed] != null) {
            var maxSpeed:Number = 0;
            var maxAngle:int = 0;
            for (var i:int = 0; i < 360; i++) {
                var pbs:PolarBoatSpeed = _table[windSpeed][i];
                if (pbs === null) {
                    return null;
                }
                if (pbs.cardinalHardCalculated > maxSpeed) {
                    maxSpeed = pbs.cardinalHardCalculated;
                    maxAngle = i;
                }
            }
            return {maxAngle: maxAngle, maxSpeed: maxSpeed}
        }
        return null;
    }

    internal function fillBestVmgs():void {
        var dtr:Number = Math.PI / 180
        for (var wind:int = 0; wind < MAX_WINDSPEED; wind++) {
            if (_bestVmg[wind] === null) {
                _bestVmg[wind] = new Vector.<BestVmg>(4, true);
            }
            var container:Vector.<BestVmg> = _bestVmg[wind];
            var deg:Number = 0;

            for (var quarter:int = 0; quarter <= 3; quarter++) {
                var maxVMG:Number = 0;
                var maxAngle:int = 0;
                var aVmg:Number = 0;
                for (var angle:int = 0; angle <= 90; angle++) {
                    deg = angle + quarter * 90;
                    if (deg < 360 && _table[wind][deg] != null) {
                        aVmg = Math.abs(Math.cos(deg * dtr) * _table[wind][deg].cardinalHardCalculated);
                    }
                    if (maxVMG < aVmg) {
                        maxVMG = aVmg;
                        maxAngle = deg;

                    }
                }
                if (container[quarter] === null) {
                    container[quarter] = new BestVmg();
                }

                container[quarter].angle = maxAngle;
                container[quarter].boatSpeed = _table[wind][maxAngle].cardinalHardCalculated;
            }

        }

    }

    public function getAbsoluteMax():Number {
        var max:Number = 0;
        for (var wind:int = 0; wind < MAX_WINDSPEED; wind++) {
            for (var angle:int = 0; angle < 360; angle++) {
                if (_table[wind][angle] != null && _table[wind][angle].cardinalHardCalculated > max) {
                    max = _table[wind][angle].cardinalHardCalculated;
                }

            }

        }
        return max;
    }


    public function get bestVmg():Vector.<Vector.<BestVmg>> {
        return _bestVmg;
    }

    public function getPolarSpeed(windSpeed:Number, windDirection:Number):Number {
        windSpeed = Math.round(windSpeed);
        if (windSpeed >= MAX_WINDSPEED) {
            return NaN;
        }
        windDirection = Math.floor(windDirection);

        return _table[windSpeed][windDirection].cardinalHardCalculated >= 0 ? _table[windSpeed][windDirection].cardinalHardCalculated : 0;
    }

    public function calculatePolarSpeedMinMax():void {
        _minPolarSpeed = getPolarSpeed(0, 0);
        _maxPolarSpeed = _minPolarSpeed;
        for (var i:int = 0; i < MAX_WINDSPEED; i++) {
            for (var j:int = 0; j < 360; j++) {
                var value:Number = getPolarSpeed(i, j);
                if (value < _minPolarSpeed) {
                    _minPolarSpeed = value;
                } else if (value > _maxPolarSpeed) {
                    _maxPolarSpeed = value;
                }
            }
        }
    }

    public function get minPolarSpeed():Number {
        return _minPolarSpeed;
    }

    public function get maxPolarSpeed():Number {
        return _maxPolarSpeed;
    }

}
}
