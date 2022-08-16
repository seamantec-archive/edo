/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.21.
 * Time: 15:25
 * To change this template use File | Settings | File Templates.
 */
package com.alarm {
import com.sailing.datas.ApparentWind;
import com.sailing.datas.Bwc;
import com.sailing.datas.Mtw;
import com.sailing.datas.Mwd;
import com.sailing.datas.OffCourse;
import com.sailing.datas.Performance;
import com.sailing.datas.PositionAndSpeed;
import com.sailing.datas.Vhw;
import com.sailing.datas.WaterDepth;
import com.sailing.datas.Windsmoothtrue;
import com.sailing.datas.Xte;
import com.sailing.units.AnchorDistance;
import com.sailing.units.Distance;

public class ListenerKeys {
    public static var waterdepth_waterDepthWithOffset:ListenerKey = new ListenerKey({klass: WaterDepth, parameter: "waterDepthWithOffset", alarmText: "water depth is", incFx: "csipp", decFx: "csipp", sfx: "reinfofx"})
    public static var windsmoothtrue_windSpeedExpAvg:ListenerKey = new ListenerKey({klass: Windsmoothtrue, parameter: "windSpeedExpAvg", alarmText: "wind speed is", incFx: "csipp", decFx: "csipp", sfx: "reinfofx"})
    public static var apparentwind_windAngle:ListenerKey = new ListenerKey({klass: ApparentWind, parameter: "windAngle", alarmText: "wind angle is", incFx: "pinngg", decFx: "pinngg", sfx: "reinfofx"})
    public static var positionandspeed_sog:ListenerKey = new ListenerKey({klass: PositionAndSpeed, parameter: "sog", alarmText: "boat speed is", incFx: "pinngg", decFx: "pinngg", sfx: "reinfofx"})
    public static var vhw_waterSpeed:ListenerKey = new ListenerKey({klass: Vhw, parameter: "waterSpeed", alarmText: "boat speed is", incFx: "pinngg", decFx: "pinngg", sfx: "reinfofx"})
    public static var mtw_temperature:ListenerKey = new ListenerKey({klass: Mtw, parameter: "temperature", alarmText: "water temperature is", incFx: "pinngg", decFx: "pinngg", sfx: "reinfofx"})
    public static var xte_xteMagnitude:ListenerKey = new ListenerKey({klass: Xte, parameter: "xteMagnitude", alarmText: "cross track error is", incFx: "pinngg", decFx: "pinngg", sfx: "reinfofx"})
    public static var connection_con_sys:ListenerKey = new ListenerKey({klass: "connection", parameter: "con", alarmText: "no connection", incFx: "pinngg", decFx: "pinngg", sfx: "reinfofx"})
    public static var mwd_windDirection_shift:ListenerKey = new ListenerKey({klass: Mwd, parameter: "windDirection", alarmText: "wind direction shift is", incFx: "pinngg", decFx: "pinngg", sfx: "reinfofx", shift: true})
    public static var anchor:ListenerKey = new ListenerKey({klass: PositionAndSpeed, parameter: "lat", alarmText: "anchor", incFx: "pinngg", decFx: "pinngg", sfx: "reinfofx", unit: new AnchorDistance()})
    public static var ais:ListenerKey = new ListenerKey({klass: "ais", parameter: "cpa", alarmText: "AIS Vessel will be in", incFx: "pinngg", decFx: "pinngg", sfx: "reinfofx", unit: new Distance()})
    public static var bwc_waypointDistance:ListenerKey = new ListenerKey({klass: Bwc, parameter: "waypointDistance", alarmText: "waypoint distance is", incFx: "pinngg", decFx: "pinngg", sfx: "reinfofx"})
    public static var offcourse_offCourse:ListenerKey = new ListenerKey({klass: OffCourse, parameter: "offCourse", alarmText: "off course is", incFx: "pinngg", decFx: "pinngg", sfx: "reinfofx"})
    public static var performance_performance:ListenerKey = new ListenerKey({klass: Performance, parameter: "performance", alarmText: "performance is", incFx: "pinngg", decFx: "pinngg", sfx: "reinfofx"})
}
}
