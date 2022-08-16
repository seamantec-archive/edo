/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 6/24/13
 * Time: 6:21 PM
 * To change this template use File | Settings | File Templates.
 */
package com.timeline {
import com.events.EnableDisableEvent;
import com.graphs.GraphHandler;
import com.polar.PolarContainer;
import com.sailing.WindowsHandler;
import com.sailing.combinedDataHandlers.CombinedDataHandler;
import com.ui.TopBar;

import flash.display.Sprite;
import flash.events.Event;
import flash.system.System;

public class LogReplayAS extends Sprite {
    public static const controllsWidth:int = 178;

    private var _smallTimeline:SmallTimeline;
    protected var controlls:LogReplayControlsAS;
    private var _currentState:String = "closed";

    public function LogReplayAS() {
        //this.height = TopBar.barHeight;
        //this.width = TopBar.logReplayWidth;

        this.graphics.beginFill(0xffffff, 0);
        this.graphics.drawRect(0,0, TopBar.logReplayWidth,TopBar.barHeight);

        this._smallTimeline = new SmallTimeline();
        this.controlls = new LogReplayControlsAS(this._smallTimeline);
        this.controlls.x = 0;
        init();

    }

    protected function init():void {
        //BindingUtils.bindProperty(controlls, "utcTime", smallTimeline, "actualTimeForLabel");
        _smallTimeline.addEventListener("logfile-selected", logFileOpenHandler, false, 0, true);
        _smallTimeline.addEventListener("actualTimeLabelChanged", smallTimeline_actualTimeLabelChangedHandler, false, 0, true);
        _smallTimeline.controlls = controlls;
        _smallTimeline.x = controllsWidth + 8;
        _smallTimeline.y = 0;
        this.addChild(_smallTimeline);
        this.addChild(controlls);
    }

    public function hideLogReplay():void {
        WindowsHandler.instance.dataSource = "socket";
        WindowsHandler.instance.resetInstruments()
        _smallTimeline.stopTimer();
        GraphHandler.instance.resetAllGraphs();
        CombinedDataHandler.instance.resetHandlerDatas();
        GraphHandler.instance.graphDataHandler.detachMainDb();
        _smallTimeline.logDataHandler.closeSqlConnection();
//        PolarContainer.instance.reset();
        this.visible = false;
        //setCurrentState("closed");
        TopBar.menuList.dispatchEvent(new EnableDisableEvent(EnableDisableEvent.DISABLE, "closeLog"))
        System.pauseForGCIfCollectionImminent(0.15);
    }

    public function openLogReplay():void {
        _smallTimeline.openLogFileHandler();
//        WindowsHandler.instance.dataSource = "log";
    }

    protected function logFileOpenHandler(event:Event):void {
        this.visible = true;
        //setCurrentState("opened");
        TopBar.menuList.dispatchEvent(new EnableDisableEvent(EnableDisableEvent.ENABLE, "closeLog"));
    }

    private function smallTimeline_actualTimeLabelChangedHandler(event:Event):void {
        controlls.utcTime = _smallTimeline.actualTimeForLabel;
    }


    public  function setCurrentState(state:String, play:Boolean = false):void {
        if (state == "opened") {
            this.visible = true;
        } else if (state == "closed") {
            this.visible = false;
        }
    }

    public  function set currentState(state:String):void {
        setCurrentState(state);
    }

    public  function get currentState():String {
        return _currentState;
    }

    public function resetSpeed():void {
        controlls.logPlaySpeedBtn.label = "X1";
    }


    public function get smallTimeline():SmallTimeline {
        return _smallTimeline;
    }
}
}
