/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 10/11/13
 * Time: 9:37 AM
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.combinedDataHandlers {
import com.sailing.datas.BaseSailData;
import com.sailing.datas.PositionAndSpeed;
import com.sailing.datas.Setanddrift;
import com.sailing.datas.Vhw;
import com.sailing.units.Unit;

public class SetAndDriftCalculator extends CombinedData {
    private const AVERAGECOUNTER:uint = 5;
    private const DATALENGTH:uint = 3;
    private const AVERAGELENGTH:uint = AVERAGECOUNTER * DATALENGTH;

    private var vhwList:Array = new Array();
    private var pasList:Array = new Array();

    private var data:Setanddrift = new Setanddrift();

    public function SetAndDriftCalculator() {
        dataKey = "setanddrift";
        listenerKeys.push("vhw");
        listenerKeys.push("positionandspeed");
    }

    override public function reset():void {
        data = new Setanddrift();
        lastDatas = new Object();
        vhwList = [];
        pasList = [];
    }

    override public function calculate(timestamp:Number, key:String):BaseSailData {
        var vhw:Vhw = lastDatas.vhw;
        var pas:PositionAndSpeed = lastDatas.positionandspeed;
        if (vhw != null && (vhwList.length == 0 || vhwList[vhwList.length - 1] != timestamp)) {
            if (vhwList.length >= AVERAGELENGTH) {
                vhwList.splice(0, DATALENGTH);
            }
            vhwList.push(vhw.waterHeading.getPureData());
            //vhwList.push((tmp>180) ? tmp - 360 : tmp);
            vhwList.push(vhw.waterSpeed.getPureData());
            vhwList.push(timestamp);
        }
        if (pas != null && (pasList.length == 0 || pasList[pasList.length - 1] != timestamp)) {
            if (pasList.length >= AVERAGELENGTH) {
                pasList.splice(0, DATALENGTH);
            }
            if(pas.cog.getPureData()==Unit.INVALID_VALUE) {
                return null;
            }
            pasList.push(pas.cog.getPureData());
            //rmcList.push((tmp>180) ? tmp - 360 : tmp);
            pasList.push(pas.sog.getPureData());
            pasList.push(timestamp);
        }
        if (vhwList.length >= AVERAGELENGTH && pasList.length >= AVERAGELENGTH) {
            calculateAverageSetAndDrift();
            vhwList = [];
            pasList = [];
            return data;
        }
        return null;
    }

    private function calculateAverageSetAndDrift():void {
        var avgSet:Number = 0;
        var avgDrift:Number = 0;
        var a, b, c, bx, by, cx, cy, dx, dy:Number;
        var heading, cog, angleSet:Number;
//        for (var i = 0; i < AVERAGELENGTH; i += DATALENGTH) {
//            b = vhwList[i + 1];
//            c = rmcList[i + 1];
//            heading = vhwList[i] * (Math.PI / 180);
//            cog = rmcList[i] * (Math.PI / 180);
//            a = Math.sqrt(Math.pow(b * Math.cos(heading) - c * (Math.cos(cog)), 2) + Math.pow(b * Math.sin(heading) - c * (Math.sin(cog)), 2));
//            if(vhwList[i]==rmcList[i]) {
//                angleSet = 0;
//            } else {
//                angleSet = Math.acos((a * a + b * b - c * c) / (2 * a * b));
//            }
//            if(isNaN(angleSet)) {
//                angleSet = 0;
//            }
//            /*
//            if(vhwList[i]>rmcList[i]) {
//                angleSet += (Math.PI/2);
//            }
//            */
//            avgSet += angleSet * (180 / Math.PI);
//            avgDrift += a;
//        }
        for (var i:int = 0; i < AVERAGELENGTH; i += DATALENGTH) {
            heading = vhwList[i] * (Math.PI / 180);
            cog = pasList[i] * (Math.PI / 180);
            b = vhwList[i + 1];
            c = pasList[i + 1];
            bx = b * Math.cos(heading);
            by = b * Math.sin(heading);
            cx = c * Math.cos(cog);
            cy = c * Math.sin(cog);
            a = Math.sqrt(Math.pow(bx - cx, 2) + Math.pow(by - cy, 2));
            if (b == 0) {
                angleSet = 0;
            } else {
                if (a == 0) {
                    angleSet = (c >= b) ? 0 : 180;
                } else {
                    dx = bx - cx;
                    dy = by - cy;
                    angleSet = (Math.atan2(dy, dx) * (180 / Math.PI)) + 180;
                    if (angleSet < 0) {
                        angleSet += 360;
                    } else if (angleSet > 360) {
                        angleSet -= 360;
                    }
                }
//                angleSet += vhwList[i];
//                if(angleSet>360) {
//                    angleSet -= 360;
//                }
            }

            avgSet += angleSet;
            avgDrift += a;
        }

        data.angleset.value = Math.floor(avgSet / AVERAGECOUNTER);
        data.drift.value = avgDrift / AVERAGECOUNTER;
    }
}
}
