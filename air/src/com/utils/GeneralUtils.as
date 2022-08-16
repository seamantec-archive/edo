package com.utils {
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

public class GeneralUtils {
    public static function generateCapitalizedSentence(string:String):String {
        var splittedString:String = string.replace("_", " ");
        splittedString = splittedString.replace(/((?<![A-Z])[A-Z]|[A-Z](?![A-Z]))/g, ' $1');
        if (splittedString.charAt(0) == ' ')
            splittedString = splittedString.substr(1);
        var splittedStringA:Array = splittedString.split(" ");
        for (var i:int = 0; i < splittedStringA.length; i++) {
            var s:String = splittedStringA[i];
            splittedStringA[i] = upperCase(s);
        }
        return splittedStringA.join(" ");
    }

    public static function upperCase(str:String):String {
        var firstChar:String = str.substr(0, 1);
        var restOfString:String = str.substr(1, str.length);
        return firstChar.toUpperCase() + restOfString.toLowerCase();
    }

    public static function roundTo(value:Number, place:Number = 0, base:Number = 10):Number {
        var p:Number = Math.pow(base, -place);

        return Math.round(value * p) / p;
    }

    public static function stringToBoolean(string:String):Boolean {
        switch (string) {
            case "true":
                return true;
                break;
            case "false":
                return false;
                break;
        }
        return false;
    }

    public static function getShortUnit(unit:String):String {
        switch (unit) {
            case "meter":
                return "m";
            case "knots":
                return "kts";
            case "celsius":
                return "c";
            case "degree":
                return "°";
            default :
                return "";
        }
    }


    public static function setMinMaxLimitForData(klass:Class, minKey:String, maxKey:String, value):void {
        if (value > klass[maxKey]) {
            klass[maxKey] = value;
        }
        if (value < klass[minKey]) {
            klass[minKey] = value;
        }
    }

    public static function getClass(obj:Object):Class {
        return Class(getDefinitionByName(getQualifiedClassName(obj)));
    }


    public static function breakTextAt(string:String, maxChar:uint):String {
        var splittedString:Array = string.split(" ");
        var returnString:String = "";
        var lastBreakIndex:uint = 0;
        for (var i:int = 0; i < splittedString.length; i++) {
            if (lastBreakIndex + splittedString[i].length <= maxChar) {
                returnString += splittedString[i]+" ";
                lastBreakIndex += splittedString[i].length +1;
            } else {
                returnString += "\n" + splittedString[i];
                lastBreakIndex = 0;
            }
        }
        return returnString;
    }

}
}