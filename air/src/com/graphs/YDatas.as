﻿/** * Created with IntelliJ IDEA. * User: pepusz * Date: 2013.02.01. * Time: 11:21 * To change this template use File | Settings | File Templates. */package com.graphs {[Bindable]public class YDatas {    public static var datas:Vector.<YData> = new <YData>[];    public static var keys:Vector.<String> = new <String>[];    public static function initYDatas():void {        datas.length = 0;        keys.length = 0;        datas.push(new YData("AWA", "apparentwind_windAngle",                             [-60, 60], [-180, 180], YData.AREA_GRAPH, { pLineColor: 0x00ff00, quantalZoom:30}))        datas.push(new YData("AWD", "apparentwind_windDirection",                         [0, 360], [0, 360],     YData.LINE_GRAPH, { pLineColor: 0xffd200, quantalZoom:45}))        datas.push(new YData("AWS", "apparentwind_windSpeed",                             [0, 10], [0, 200],      YData.LINE_GRAPH, { pLineColor: 0xffffff, quantalZoom:2}))   //   datas.push(new YData("AWD (smooth)", "windsmoothapp_windDirectionExpAvg",         [0, 360], [0, 360],     YData.LINE_GRAPH, { pLineColor: 0xffd200, quantalZoom:45}))        datas.push(new YData("TWA", "truewindc_windAngle",                                [-60, 60], [-180, 180], YData.AREA_GRAPH, { pLineColor: 0x00ff00, quantalZoom:30}))        datas.push(new YData("TWD", "truewindc_windDirection",                            [0, 360], [0, 360],     YData.LINE_GRAPH, { pLineColor: 0xffd200, quantalZoom:45}))        datas.push(new YData("TWS", "truewindc_windSpeed",                                [0, 10], [0, 200],      YData.LINE_GRAPH, { pLineColor: 0xffffff, quantalZoom:2}))    //  datas.push(new YData("TWS (smooth)", "windsmoothtrue_windSpeedExpAvg",            [0, 10], [0, 200],      YData.LINE_GRAPH, { pLineColor: 0xffffff, quantalZoom:2}))        datas.push(new YData("GWD", "mwd_windDirection",                                  [0, 360], [0, 360],     YData.LINE_GRAPH, { pLineColor: 0xffd200, quantalZoom:45}))        datas.push(new YData("GWS", "mwd_windSpeed",                                      [0, 10], [0, 200],      YData.LINE_GRAPH, { pLineColor: 0xffffff, quantalZoom:2}))        //DON'T DELETE THIS LINE BECAUSE WE USE THIS FOR POLAR, I'LL HIDE THIS FROM DROPDOWN LIST!!! (pepusz)        datas.push(new YData("STW", "vhw_waterSpeed",                [0, 2], [0, 80],        YData.LINE_GRAPH, { pLineColor: 0xffffff, quantalZoom:2}))        datas.push(new YData("SOG", "positionandspeed_sog",         [0, 2], [0, 80],        YData.LINE_GRAPH, { pLineColor: 0xffffff, quantalZoom:2}))        datas.push(new YData("VMG Wind", "vmgwind_wind",                            [-2, 2], [-80, 80],     YData.LINE_GRAPH, { pLineColor: 0xffffff, nLineColor: 0xffffff, quantalZoom:2}))        datas.push(new YData("VMG Waypoint", "vmgwaypoint_waypoint",                [-2, 2], [-80, 80],     YData.LINE_GRAPH, { pLineColor: 0xbabaff, nLineColor: 0xffffff, quantalZoom:2}))        datas.push(new YData("Heading", "heading_heading",                         [0, 360], [0, 360],     YData.LINE_GRAPH, { pLineColor: 0xffd200, quantalZoom:45}))        datas.push(new YData("COG", "positionandspeed_cog",                         [0, 360], [0, 360],     YData.LINE_GRAPH, { pLineColor: 0xffd200, quantalZoom:45}))  //    datas.push(new YData("VMG Wind", "vpw_speed",                               [-2, 2], [-80, 80],     YData.LINE_GRAPH, { pLineColor: 0xffffff, nLineColor: 0xffffff, quantalZoom:2}))        datas.push(new YData("Rudder", "rsa_rudderSensorStarboard",                 [-10, 10], [-50, 50],   YData.AREA_GRAPH, { quantalZoom:10}))//        datas.push(new YData("Waterdepth", "dbt_waterDepth",                        [0, 10],  [0, 200],     YData.DEPTH_GRAPH,{ pLineColor: 0x0077b1, pAreaColor: 0x0077b1, quantalZoom:5}))//        datas.push(new YData("Waterdepth", "waterdepth_waterDepth",                        [0, 10],  [0, 200],     YData.DEPTH_GRAPH,{ pLineColor: 0x0077b1, pAreaColor: 0x0077b1, quantalZoom:5}))        datas.push(new YData("Waterdepth", "waterdepth_waterDepthWithOffset",                        [0, 10],  [0, 200],     YData.DEPTH_GRAPH,{ pLineColor: 0x0077b1, pAreaColor: 0x0077b1, quantalZoom:5}))     //   datas.push(new YData("Heading", "vhw_waterHeading",                         [0, 360], [0, 360],     YData.LINE_GRAPH, { pLineColor: 0xffd200, quantalZoom:45}))        datas.push(new YData("Set", "setanddrift_angleset",                         [0, 360], [0, 360],     YData.LINE_GRAPH, { pLineColor: 0xffd200, quantalZoom:45}))        datas.push(new YData("Drift", "setanddrift_drift",                          [0, 2], [0, 10],        YData.LINE_GRAPH, { pLineColor: 0xffffff, quantalZoom:2}))        datas.push(new YData("Air temp.", "mda_airTemp",                             [0, 20], [-20, 40],        YData.LINE_GRAPH, { pLineColor: 0xffffff, quantalZoom:5}))        datas.push(new YData("Water temp.", "mtw_temperature",                       [0, 20], [-20, 40],        YData.LINE_GRAPH, { pLineColor: 0xffffff, quantalZoom:5}))        datas.push(new YData("Atm. pressure", "mda_barometricPressure",              [980, 1020], [950, 1050],        YData.LINE_GRAPH, { pLineColor: 0xffffff, quantalZoom:10}))        datas.push(new YData("Performance", "performance_performance",               [75, 125], [50, 150],               YData.LINE_GRAPH, { pLineColor: 0xffffff, quantalZoom:5}))        for (var i:int = 0; i < datas.length; i++) {            var k:String = datas[i].dataKey.split("_")[0];            var wasany:Boolean = false;            for (var j:int = 0; j < keys.length; j++) {                if (keys[j] === k) {                    wasany = true;                    break;                }            }            if (!wasany) {                keys.push(k);            }        }    }    public static function getByData(data:String):YData {        for (var i:int = 0; i < datas.length; i++) {            var object:YData = datas[i];            if (object.dataKey === data) {                return object;            }        }        return null;    }}}