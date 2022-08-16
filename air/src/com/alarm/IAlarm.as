package com.alarm{

public interface IAlarm{
    function addAlarmToSpeechAndHistory():void;
    function isValidValue():Boolean;
    function set actualValue(value:Number):void;
    function toXML():XML;
}
}