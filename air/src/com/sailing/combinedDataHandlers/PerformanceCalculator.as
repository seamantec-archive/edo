/**
 * Created by pepusz on 2014.08.02..
 */
package com.sailing.combinedDataHandlers {
import com.common.SpeedToUse;
import com.polar.BestVmg;
import com.polar.PolarBoatSpeed;
import com.polar.PolarContainer;
import com.polar.PolarTable;
import com.sailing.datas.BaseSailData;
import com.sailing.datas.Performance;
import com.sailing.datas.PositionAndSpeed;
import com.sailing.datas.TrueWindC;
import com.sailing.datas.Vhw;
import com.sailing.units.Unit;
import com.sailing.units.UnitHandler;

public class PerformanceCalculator extends CombinedData {
    public var data:Performance = new Performance();
    private var lastTimestamp:Number = 0;

    public function PerformanceCalculator() {
        dataKey = "performance";
        listenerKeys.push("truewindc");
        listenerKeys.push("vhw");
        listenerKeys.push("positionandspeed");
    }

    override public function reset():void {
        data = new Performance();
        lastDatas = new Object();
        lastTimestamp = 0;
    }

    override public function calculate(timestamp:Number, key:String):BaseSailData {
        var trueWind:TrueWindC = lastDatas.truewindc;
        var pas:PositionAndSpeed = lastDatas.positionandspeed;
        var vhw:Vhw = lastDatas.vhw;
        if (lastTimestamp === timestamp) {
            return null;
        }
        lastTimestamp = timestamp;
        var polarTable:PolarTable = PolarContainer.instance.polarTableFromFile;
        if (polarTable != null && trueWind != null) {
            data.performance.value = -1;
            if (SpeedToUse.instance.selected == SpeedToUse.STW && vhw != null) {
                data.performance.value = polarTable.getPerformanceForAngle(trueWind.windSpeed.getPureData(), trueWind.windDirection.getPureData(), vhw.waterSpeed.getPureData());
            } else if (pas != null) {
                data.performance.value = polarTable.getPerformanceForAngle(trueWind.windSpeed.getPureData(), trueWind.windDirection.getPureData(), pas.sog.getPureData());
            }
            if (data.performance.value != -1) {
                data.performance.value = Math.round(data.performance.getPureData() * 100)
            }

            var pbs:PolarBoatSpeed = polarTable.getValueForWSpeedAndDirection(Math.round(trueWind.windSpeed.getPureData()), Math.floor(trueWind.windDirection.value));
            data.polarSpeed.value = (pbs!=null) ? pbs.cardinalHardCalculated : Unit.INVALID_VALUE;

            data.beatAngle.value = Unit.INVALID_VALUE;
            data.beatVmg.value = Unit.INVALID_VALUE;
            data.runAngle.value = Unit.INVALID_VALUE;
            data.runVmg.value = Unit.INVALID_VALUE;

            var up:BestVmg = null;
            var down:BestVmg = null;
            var windSpeed:Number = Math.round(trueWind.windSpeed.getPureData());
            if(polarTable.hasPolarForWind(windSpeed)) {
                var vmg:BestVmg;
                for (var i:int = 0; i <= 3; i++) {
                    vmg = (polarTable.bestVmg[windSpeed] != null) ? polarTable.bestVmg[windSpeed][i] : null;
                    if (vmg != null) {
                        if ((vmg.angle <= 90 || vmg.angle > 270) && up == null) {
                            up = vmg;
                        } else if ((vmg.angle > 90 && vmg.angle <= 270) && down == null) {
                            down = vmg;
                        }
                    }
                }

                if(up!=null) {
                    data.beatAngle.value = (up.angle<180) ? up.angle : (360 - up.angle);
                    data.beatVmg.value = Math.abs(up.boatSpeed*Math.cos(data.beatAngle.value*(Math.PI/180)));
                }
                if(down!=null) {
                    data.runAngle.value = (down.angle<180) ? down.angle : (360 - down.angle);
                    data.runVmg.value = Math.abs(down.boatSpeed*Math.cos(data.runAngle.value*(Math.PI/180)));
                }
            }

            return data;
        }

        return null;
    }
}
}
