/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.04.08.
 * Time: 16:31
 * To change this template use File | Settings | File Templates.
 */
package com.alarm.soundfx {
public class FxContainer {
    [Embed(source="../../../../assets/fxes/bell_but.mp3")]
    internal static var _bell_but:Class;
    [Embed(source="../../../../assets/fxes/bell_but2.mp3")]
    internal static var _bell_but2:Class;
    [Embed(source="../../../../assets/fxes/idg-bang.mp3")]
    internal static var _idg_bang:Class;
    [Embed(source="../../../../assets/fxes/poise-xrikazen.mp3")]
    internal static var _poise:Class;
    [Embed(source="../../../../assets/fxes/submarine.mp3")]
    internal static var _submarine:Class;
    [Embed(source="../../../../assets/fxes/wobbelo.mp3")]
    internal static var _wobbelo:Class;
    [Embed(source="../../../../assets/alert1.mp3")]
    internal static var _reinfofx:Class;
    [Embed(source="../../../../assets/fxes/disalert.mp3")]
    internal static var _disalert:Class;

    [Embed(source="../../../../assets/fxes/pinngg.mp3")]
    internal static var _pinngg:Class;

    [Embed(source="../../../../assets/fxes/csipp.mp3")]
    internal static var _csipp:Class;

    public static function getClass(klass:String):Class{
        return FxContainer[klass]
    }

    public static var container:Object = {
        "bell_but": new _bell_but(),
        "bell_but2": new _bell_but2(),
        "poise": new _poise(),
        "submarine": new _submarine(),
        "wobbelo": new _wobbelo(),
        "reinfofx": new _reinfofx(),
        "disalert": new _disalert(),
        "pinngg": new _pinngg(),
        "csipp": new _csipp()
    }
}
}
