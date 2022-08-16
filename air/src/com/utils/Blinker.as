/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.07.09.
 * Time: 15:46
 * To change this template use File | Settings | File Templates.
 */
package com.utils {
import flash.events.TimerEvent;
import flash.utils.Timer;

public class Blinker {
    private static var objects:Array = [];
    private static var blinkTimer:Timer = new Timer(500);
    private static var blinkStatus:Boolean = false;

    private static var doubleObjects:Array = [];
    private static var doubleBlinkTimer:Timer = new Timer(250);
    private static var doubleBlinkStatus:Boolean = false;

    blinkTimer.addEventListener(TimerEvent.TIMER, blinkTimer_timerHandler, false, 0, true);
    doubleBlinkTimer.addEventListener(TimerEvent.TIMER,  doubleBlinkTimer_timerHandler, false, 0, true);

    public static function addObject(object:*):void {
        if (objects.length === 0) {
            blinkTimer.start();
        }
        for (var i:int = 0; i < objects.length; i++) {
            if (objects[i] == object) {
                return;
            }
        }

        object.visible = blinkStatus;
        objects.push(object);
    }

    public static function removeObject(object:*):void {
        for (var i:int = 0; i < objects.length; i++) {
            if (objects[i] == object) {
                objects.splice(i, 1);
                object.visible = true;
                break;
            }

        }
        if (objects.length === 0) {
            blinkTimer.stop();
        }
    }

    public static function containsObject(object:*):Boolean {
        for (var i:int = 0; i < objects.length; i++) {
            if (objects[i] == object) {
                return true;
            }
        }
        return false;
    }


    private static function blinkTimer_timerHandler(event:TimerEvent):void {
        blinkStatus = !blinkStatus;
        for (var i:int = 0; i < objects.length; i++) {
            objects[i].visible = blinkStatus;
        }
    }

    public static function addDoubleObject(object:*):void {
        if (doubleObjects.length === 0) {
            doubleBlinkTimer.start();
        }
        for (var i:int = 0; i < doubleObjects.length; i++) {
            if (doubleObjects[i] == object) {
                return;
            }
        }

        object.visible = doubleBlinkStatus;
        doubleObjects.push(object);
    }

    public static function removeDoubleObject(object:*):void {
        for (var i:int = 0; i < doubleObjects.length; i++) {
            if (doubleObjects[i] == object) {
                doubleObjects.splice(i, 1);
                object.visible = true;
                break;
            }

        }
        if (doubleObjects.lenght === 0) {
            doubleBlinkTimer.stop();
        }
    }


    private static function doubleBlinkTimer_timerHandler(event:TimerEvent):void {
        doubleBlinkStatus = !doubleBlinkStatus;
        for (var i:int = 0; i < doubleObjects.length; i++) {
            doubleObjects[i].visible = doubleBlinkStatus;
        }
    }
}
}
