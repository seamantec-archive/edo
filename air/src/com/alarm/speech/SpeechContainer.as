/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.14.
 * Time: 17:03
 * To change this template use File | Settings | File Templates.
 */
package com.alarm.speech {
import com.common.SysConfig;
import com.greensock.events.LoaderEvent;
import com.greensock.loading.LoaderMax;
import com.greensock.loading.MP3Loader;
import com.sailing.WindowsHandler;

import flash.media.Sound;

public class SpeechContainer {
    [Embed(source="../../../../assets/speech/0.mp3")]
    internal static var _0:Class;
    [Embed(source="../../../../assets/speech/1.mp3")]
    internal static var _1:Class;
    [Embed(source="../../../../assets/speech/2.mp3")]
    internal static var _2:Class;
    [Embed(source="../../../../assets/speech/3.mp3")]
    internal static var _3:Class;
    [Embed(source="../../../../assets/speech/4.mp3")]
    internal static var _4:Class;
    [Embed(source="../../../../assets/speech/5.mp3")]
    internal static var _5:Class;
    [Embed(source="../../../../assets/speech/6.mp3")]
    internal static var _6:Class;
    [Embed(source="../../../../assets/speech/7.mp3")]
    internal static var _7:Class;
    [Embed(source="../../../../assets/speech/8.mp3")]
    internal static var _8:Class;
    [Embed(source="../../../../assets/speech/9.mp3")]
    internal static var _9:Class;
    [Embed(source="../../../../assets/speech/10.mp3")]
    internal static var _10:Class;
    [Embed(source="../../../../assets/speech/11.mp3")]
    internal static var _11:Class;
    [Embed(source="../../../../assets/speech/12.mp3")]
    internal static var _12:Class;
    [Embed(source="../../../../assets/speech/13.mp3")]
    internal static var _13:Class;
    [Embed(source="../../../../assets/speech/14.mp3")]
    internal static var _14:Class;
    [Embed(source="../../../../assets/speech/15.mp3")]
    internal static var _15:Class;
    [Embed(source="../../../../assets/speech/16.mp3")]
    internal static var _16:Class;
    [Embed(source="../../../../assets/speech/17.mp3")]
    internal static var _17:Class;
    [Embed(source="../../../../assets/speech/18.mp3")]
    internal static var _18:Class;
    [Embed(source="../../../../assets/speech/19.mp3")]
    internal static var _19:Class;
    [Embed(source="../../../../assets/speech/20.mp3")]
    internal static var _20:Class;
    [Embed(source="../../../../assets/speech/30.mp3")]
    internal static var _30:Class;
    [Embed(source="../../../../assets/speech/40.mp3")]
    internal static var _40:Class;
    [Embed(source="../../../../assets/speech/50.mp3")]
    internal static var _50:Class;
    [Embed(source="../../../../assets/speech/60.mp3")]
    internal static var _60:Class;
    [Embed(source="../../../../assets/speech/70.mp3")]
    internal static var _70:Class;
    [Embed(source="../../../../assets/speech/80.mp3")]
    internal static var _80:Class;
    [Embed(source="../../../../assets/speech/90.mp3")]
    internal static var _90:Class;
    [Embed(source="../../../../assets/speech/100.mp3")]
    internal static var _100:Class;
    [Embed(source="../../../../assets/speech/200.mp3")]
    internal static var _200:Class;
    [Embed(source="../../../../assets/speech/300.mp3")]
    internal static var _300:Class;
    [Embed(source="../../../../assets/speech/400.mp3")]
    internal static var _400:Class;
    [Embed(source="../../../../assets/speech/500.mp3")]
    internal static var _500:Class;
    [Embed(source="../../../../assets/speech/600.mp3")]
    internal static var _600:Class;
    [Embed(source="../../../../assets/speech/700.mp3")]
    internal static var _700:Class;
    [Embed(source="../../../../assets/speech/800.mp3")]
    internal static var _800:Class;
    [Embed(source="../../../../assets/speech/900.mp3")]
    internal static var _900:Class;
    [Embed(source="../../../../assets/speech/wind_speed_is_.mp3")]
    internal static var _wind_speed_is_:Class;
    [Embed(source="../../../../assets/speech/water_depth_is_.mp3")]
    internal static var _water_depth_is_:Class;
    [Embed(source="../../../../assets/speech/water_temperature_is_.mp3")]
    internal static var _water_temperature_is_:Class;
    [Embed(source="../../../../assets/speech/boat_speed_is_.mp3")]
    internal static var _boat_speed_is_:Class;
    [Embed(source="../../../../assets/speech/current_depth_is_.mp3")]
    internal static var _current_depth_is_:Class;
    [Embed(source="../../../../assets/speech/ship_is_too_close_.mp3")]
    internal static var _ship_is_too_close_:Class;
    [Embed(source="../../../../assets/speech/wind_angle_is_.mp3")]
    internal static var _wind_angle_is_:Class;
    [Embed(source="../../../../assets/speech/knots.mp3")]
    internal static var _knots:Class;
    [Embed(source="../../../../assets/speech/miles_per_hour.mp3")]
    internal static var _miles_per_hour:Class;
    [Embed(source="../../../../assets/speech/kilometer_per_hour.mp3")]
    internal static var _kilometer_per_hour:Class;
    [Embed(source="../../../../assets/speech/meter_per_secundum.mp3")]
    internal static var _meter_per_secundum:Class;
    [Embed(source="../../../../assets/speech/nautical_mile.mp3")]
    internal static var _nautical_mile:Class;
    [Embed(source="../../../../assets/speech/beaufort.mp3")]
    internal static var _beaufort:Class;
    [Embed(source="../../../../assets/speech/mile.mp3")]
    internal static var _mile:Class;
    [Embed(source="../../../../assets/speech/kilometer.mp3")]
    internal static var _kilometer:Class;
    [Embed(source="../../../../assets/speech/meter.mp3")]
    internal static var _meter:Class;
    [Embed(source="../../../../assets/speech/degree.mp3")]
    internal static var _degree:Class;
    [Embed(source="../../../../assets/speech/feet.mp3")]
    internal static var _feet:Class;
    [Embed(source="../../../../assets/speech/fathom.mp3")]
    internal static var _fathom:Class;
    [Embed(source="../../../../assets/speech/point.mp3")]
    internal static var _point:Class;
    [Embed(source="../../../../assets/speech/percent.mp3")]
    internal static var _percent:Class;
    [Embed(source="../../../../assets/speech/celsius.mp3")]
    internal static var _celsius:Class;
    [Embed(source="../../../../assets/speech/fahrenheit.mp3")]
    internal static var _fahrenheit:Class;
    [Embed(source="../../../../assets/speech/kelvin.mp3")]
    internal static var _kelvin:Class;
    [Embed(source="../../../../assets/speech/water_depth_changed_dramatically.mp3")]
    internal static var _water_depth_changed_dramatically:Class;
    [Embed(source="../../../../assets/speech/wind_changed_dramatically.mp3")]
    internal static var _wind_changed_dramatically:Class;
    [Embed(source="../../../../assets/speech/water_temperature_changed_dramatically.mp3")]
    internal static var _water_temperature_changed_dramatically:Class;
    [Embed(source="../../../../assets/speech/no_connection.mp3")]
    internal static var _no_connection:Class;
    [Embed(source="../../../../assets/speech/no_data.mp3")]
    internal static var _no_data:Class;
    [Embed(source="../../../../assets/speech/not_valid.mp3")]
    internal static var _not_valid:Class;
    [Embed(source="../../../../assets/speech/cross_track_error_is.mp3")]
    internal static var _cross_track_error_is:Class;
    [Embed(source="../../../../assets/speech/minus.mp3")]
    internal static var _minus:Class;
    [Embed(source="../../../../assets/speech/anchor.mp3")]
    internal static var _anchor:Class;
    [Embed(source="../../../../assets/speech/wind_direction_shift_is.mp3")]
    internal static var _wind_direction_shift_is:Class;
    [Embed(source="../../../../assets/speech/waypoint_distance_is.mp3")]
    internal static var _waypoint_distance_is:Class;
    [Embed(source="../../../../assets/speech/off_course_is.mp3")]
    internal static var _off_course_is:Class;
    [Embed(source="../../../../assets/speech/performance_is.mp3")]
    internal static var _performance_is:Class;
    [Embed(source="../../../../assets/speech/AIS_Vessel_will_be_in.mp3")]
    internal static var _AIS_Vessel_will_be_in:Class;


    public static var container:Object = {"0": new _0() as Sound,
        "1": new _1() as Sound,
        "2": new _2() as Sound,
        "3": new _3() as Sound,
        "4": new _4() as Sound,
        "5": new _5() as Sound,
        "6": new _6() as Sound,
        "7": new _7() as Sound,
        "8": new _8() as Sound,
        "9": new _9() as Sound,
        "10": new _10() as Sound,
        "11": new _11() as Sound,
        "12": new _12() as Sound,
        "13": new _13() as Sound,
        "14": new _14() as Sound,
        "15": new _15() as Sound,
        "16": new _16() as Sound,
        "17": new _17() as Sound,
        "18": new _18() as Sound,
        "19": new _19() as Sound,
        "20": new _20() as Sound,
        "30": new _30() as Sound,
        "40": new _40() as Sound,
        "50": new _50() as Sound,
        "60": new _60() as Sound,
        "70": new _70() as Sound,
        "80": new _80() as Sound,
        "90": new _90() as Sound,
        "100": new _100() as Sound,
        "200": new _200() as Sound,
        "300": new _300() as Sound,
        "400": new _400() as Sound,
        "500": new _500() as Sound,
        "600": new _600() as Sound,
        "700": new _700() as Sound,
        "800": new _800() as Sound,
        "900": new _900() as Sound,
        "windspeedis": new _wind_speed_is_() as Sound,
        "waterdepthis": new _water_depth_is_() as Sound,
        "watertemperatureis": new _water_temperature_is_() as Sound,
        "boatspeedis": new _boat_speed_is_() as Sound,
        "currentdepthis": new _current_depth_is_() as Sound,
        "shipistooclose": new _ship_is_too_close_() as Sound,
        "windangleis": new _wind_angle_is_() as Sound,
        "knots": new _knots() as Sound,
        "milesperhour": new _miles_per_hour() as Sound,
        "kilometerperhour": new _kilometer_per_hour() as Sound,
        "meterpersecundum": new _meter_per_secundum() as Sound,
        "nauticalmile": new _nautical_mile() as Sound,
        "beaufort": new _beaufort() as Sound,
        "mile": new _mile() as Sound,
        "kilometer": new _kilometer() as Sound,
        "meter": new _meter() as Sound,
        "degree": new _degree() as Sound,
        "feet": new _feet() as Sound,
        "fathom": new _fathom() as Sound,
        "point": new _point() as Sound,
        "percent": new _percent() as Sound,
        "celsius": new _celsius() as Sound,
        "fahrenheit": new _fahrenheit() as Sound,
        "kelvin": new _kelvin() as Sound,
        "waterdepthchangeddramatically": new _water_depth_changed_dramatically() as Sound,
        "windchangeddramatically": new _wind_changed_dramatically() as Sound,
        "watertemperaturechangeddramatically": new _water_temperature_changed_dramatically() as Sound,
        "noconnection": new _no_connection() as Sound,
        "nodata": new _no_data() as Sound,
        "notvalid": new _not_valid() as Sound,
        "crosstrackerroris": new _cross_track_error_is() as Sound,
        "minus": new _minus() as Sound,
        "anchor": new _anchor() as Sound,
        "winddirectionshiftis": new _wind_direction_shift_is() as Sound,
        "waypointdistanceis": new _waypoint_distance_is() as Sound,
        "performanceis": new _performance_is() as Sound,
        "offcourseis": new _off_course_is() as Sound,
        "AISVesselwillbein": new _AIS_Vessel_will_be_in() as Sound
    }

    public static var isComplete:Boolean = false;

    public static function loadConfigs():void {
        if (!SysConfig.isNull("alarmSpeeches")) {
            var queue:LoaderMax = new LoaderMax({ onComplete: completeHandler, onError: errorHandler });
            var speeches:Object = SysConfig.getObjects("alarmSpeeches.*");
            for (var key:String in speeches) {
                if (SpeechContainer[key] != null) {
                    queue.append(new MP3Loader("file:/" + speeches[key], { name: key.split("_").join(""), autoPlay: false, onComplete: childCompleteHandler }));
                }
            }
            queue.load();
        }
    }

    private static function completeHandler(event:LoaderEvent):void {
        trace("all sound loaded");
        isComplete = true;
        WindowsHandler.instance.allLoadingComplete();

    }

    private static function childCompleteHandler(event:LoaderEvent):void {
        SpeechContainer.container[event.target.name] = event.target.content as Sound;
    }

    private static function errorHandler(event:LoaderEvent):void {
    }

}
}
