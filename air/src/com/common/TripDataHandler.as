/**
 * Created by seamantec on 05/03/14.
 */
package com.common {
import com.sailing.WindowsHandler;
import com.sailing.combinedDataHandlers.CombinedDataHandler;
import com.sailing.combinedDataHandlers.TripDataCalculator;
import com.sailing.socket.SocketDispatcher;
import com.sailing.units.Distance;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.Timer;

public class TripDataHandler extends EventDispatcher {

    private static var _instance:TripDataHandler = null;

    private const DELAY:Number = 600000; //in ms

    private var _timer:Timer;

    public function TripDataHandler() {
        if(_instance==null) {
            _timer = new Timer(DELAY);
            _timer.addEventListener(TimerEvent.TIMER, timerHandler, false, 0, true);
            _timer.start();

            TripDataEventHandler.instance.addEventListener("resetUser", resetHandler, false, 0, true);
            (WindowsHandler.instance.application.socketDispatcher as SocketDispatcher).addEventListener("connectDisconnect", connectionHandler, false, 0, true);
            (WindowsHandler.instance.application.socketDispatcher as SocketDispatcher).addEventListener("connectDisconnectDemo", connectionDemoHandler, false, 0, true);
        }
    }

    public static function instance():TripDataHandler {
        if(_instance==null) {
            _instance = new TripDataHandler();
        }
        return _instance;
    }

    private function resetHandler(e:Event):void {
        var calculator:TripDataCalculator = (CombinedDataHandler.instance.getCombindeData("tripdata") as TripDataCalculator);
        if(calculator!=null) {
            calculator.resetUser();
        }
    }

    private function connectionHandler(e:Event):void {
        if(WindowsHandler.instance.isSocketDatasource()) {
            TripDataEventHandler.instance.enableTripData();
        } else {
            TripDataEventHandler.instance.disableTripData();
        }
    }

    private function connectionDemoHandler(e:Event):void {
        if(WindowsHandler.instance.application.socketDispatcher.isDemoConnected) {
            TripDataEventHandler.instance.disableTripData();
        } else {
            TripDataEventHandler.instance.enableTripData();
        }
    }

    public function getOverallDistance():Distance {
        var calculator:TripDataCalculator = (CombinedDataHandler.instance.getCombindeData("tripdata") as TripDataCalculator);
        if(calculator!=null && WindowsHandler.instance.isSocketDatasource() && !WindowsHandler.instance.application.socketDispatcher.isDemoConnected) {
            return calculator.overall.distance;
        }
        return null;
    }

    public function load():void {
        if (File.applicationStorageDirectory.resolvePath("trip.data").exists) {
            var overall:TripDataObject = new TripDataObject();
            var user:TripDataObject = new TripDataObject();
            var day:TripDataObject = new TripDataObject();

            var stream:FileStream = new FileStream();
            stream.open(File.applicationStorageDirectory.resolvePath("trip.data"), FileMode.READ);
            stream.position = 0;
            var file:XML = new XML(stream.readUTFBytes(stream.bytesAvailable));

            overall.utc = Boolean(file.overall.utc.toString());
            overall.i = int(file.overall.i.toString());
            overall.time = Number(file.overall.time.toString());
            overall.start = Number(file.overall.start.toString());
            overall.stand = Number(file.overall.stand.toString());
            overall.go = Number(file.overall.go.toString());
            overall.avg.value = Number(file.overall.avgspeed.toString());
            overall.max.value = Number(file.overall.maxspeed.toString());
            overall.distance.value = Number(file.overall.distance.toString());

            user.utc = Boolean(file.user.utc.toString());
            user.i = int(file.user.i.toString());
            user.time = Number(file.user.time.toString());
            user.start = Number(file.user.start.toString());
            user.stand = Number(file.user.stand.toString());
            user.go = Number(file.user.go.toString());
            user.avg.value = Number(file.user.avgspeed.toString());
            user.max.value = Number(file.user.maxspeed.toString());
            user.distance.value = Number(file.user.distance.toString());

            day.utc = Boolean(file.day.utc.toString());
            day.i = Number(file.day.i.toString());
            day.time = Number(file.day.time.toString());
            day.start = Number(file.day.start.toString());
            day.stand = Number(file.day.stand.toString());
            day.go = Number(file.day.go.toString());
            day.avg.value = Number(file.day.avgspeed.toString());
            day.max.value = Number(file.day.maxspeed.toString());
            day.distance.value = Number(file.day.distance.toString());

            var calculator:TripDataCalculator = (CombinedDataHandler.instance.getCombindeData("tripdata") as TripDataCalculator);
            if(calculator!=null) {
                calculator.overall = overall;
                calculator.user = user;
                calculator.day = day;
            }
        }
    }

    public function save():void {
        var calculator:TripDataCalculator = (CombinedDataHandler.instance.getCombindeData("tripdata") as TripDataCalculator);
        if(calculator!=null && WindowsHandler.instance.isSocketDatasource() && !WindowsHandler.instance.application.socketDispatcher.isDemoConnected) {
            var file:XML = new XML("<tripdata></tripdata>");

            var overall:XML = new XML("<overall></overall>");
            overall.appendChild(<utc>{calculator.overall.utc}</utc>);
            overall.appendChild(<i>{calculator.overall.i}</i>);
            overall.appendChild(<time>{calculator.overall.time}</time>);
            overall.appendChild(<start>{calculator.overall.start}</start>);
            overall.appendChild(<stand>{calculator.overall.stand}</stand>);
            overall.appendChild(<go>{calculator.overall.go}</go>);
            overall.appendChild(<avgspeed>{calculator.overall.avg.getPureData()}</avgspeed>);
            overall.appendChild(<maxspeed>{calculator.overall.max.getPureData()}</maxspeed>);
            overall.appendChild(<distance>{calculator.overall.distance.getPureData()}</distance>);
            file.appendChild(overall);

            var user:XML = new XML("<user></user>");
            user.appendChild(<utc>{calculator.user.utc}</utc>);
            user.appendChild(<i>{calculator.user.i}</i>);
            user.appendChild(<time>{calculator.user.time}</time>);
            user.appendChild(<start>{calculator.user.start}</start>);
            user.appendChild(<stand>{calculator.user.stand}</stand>);
            user.appendChild(<go>{calculator.user.go}</go>);
            user.appendChild(<avgspeed>{calculator.user.avg.getPureData()}</avgspeed>);
            user.appendChild(<maxspeed>{calculator.user.max.getPureData()}</maxspeed>);
            user.appendChild(<distance>{calculator.user.distance.getPureData()}</distance>);
            file.appendChild(user);

            var day:XML = new XML("<day></day>");
            day.appendChild(<utc>{calculator.day.utc}</utc>);
            day.appendChild(<i>{calculator.day.i}</i>);
            day.appendChild(<time>{calculator.day.time}</time>);
            day.appendChild(<start>{calculator.day.start}</start>);
            day.appendChild(<stand>{calculator.day.stand}</stand>);
            day.appendChild(<go>{calculator.day.go}</go>);
            day.appendChild(<avgspeed>{calculator.day.avg.getPureData()}</avgspeed>);
            day.appendChild(<maxspeed>{calculator.day.max.getPureData()}</maxspeed>);
            day.appendChild(<distance>{calculator.day.distance.getPureData()}</distance>);
            file.appendChild(day);

            var stream:FileStream = new FileStream();
            stream.open(File.applicationStorageDirectory.resolvePath("trip.data"), FileMode.WRITE);
            stream.writeUTFBytes(file);
            stream.close();
        }
    }

    private function timerHandler(event:TimerEvent):void {
        save();
    }
}
}
