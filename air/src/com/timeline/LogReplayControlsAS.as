/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.06.21.
 * Time: 14:25
 * To change this template use File | Settings | File Templates.
 */
package com.timeline {
import com.ui.TopBar;
import com.ui.controls.BitmapButton;
import com.utils.FontFactory;
import com.utils.TimeSpan;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.globalization.DateTimeFormatter;
import flash.text.TextField;

public class LogReplayControlsAS extends Sprite {

    [Embed(source='../../../assets/images/Layout pngs/counter_bg.png')] var counterbgPNG:Class;
    [Embed(source='../../../assets/images/Layout pngs/replay_back01.png')] var replayback01PNG:Class;
    [Embed(source='../../../assets/images/Layout pngs/replay_back02.png')] var replayback02PNG:Class;
    [Embed(source='../../../assets/images/Layout pngs/replay_back03.png')] var replayback03PNG:Class;
    [Embed(source='../../../assets/images/Layout pngs/replay_play01.png')] var replayplay01PNG:Class;
    [Embed(source='../../../assets/images/Layout pngs/replay_play02.png')] var replayplay02PNG:Class;
    [Embed(source='../../../assets/images/Layout pngs/replay_play03.png')] var replayplay03PNG:Class;
    [Embed(source='../../../assets/images/Layout pngs/replay_stop01.png')] var replaystop01PNG:Class;
    [Embed(source='../../../assets/images/Layout pngs/replay_stop02.png')] var replaystop02PNG:Class;
    [Embed(source='../../../assets/images/Layout pngs/replay_stop03.png')] var replaystop03PNG:Class;
    [Embed(source='../../../assets/images/Layout pngs/replay_x01.png')] var replayx01PNG:Class;
    [Embed(source='../../../assets/images/Layout pngs/replay_x02.png')] var replayx02PNG:Class;
    [Embed(source='../../../assets/images/Layout pngs/replay_x03.png')] var replayx03PNG:Class;
    [Embed(source='../../../assets/images/Layout pngs/replay_zoomin01.png')] var replayzoomin01PNG:Class;
    [Embed(source='../../../assets/images/Layout pngs/replay_zoomin02.png')] var replayzoomin02PNG:Class;
    [Embed(source='../../../assets/images/Layout pngs/replay_zoomout01.png')] var replayzoomout01PNG:Class;
    [Embed(source='../../../assets/images/Layout pngs/replay_zoomout02.png')] var replayzoomout02PNG:Class;


    public static const UTC_TIME:int = 0;
    public static const TIME_BEFORE_MARKER:int = 1;
    public static const TIME_AFTER_MARKER:int = 2;
    private var utcTimeState:int = UTC_TIME;

    private var _smallTimeline:SmallTimeline;
    private var _utcTime:Date;

    public var utcLabel:TextField;
    public var timeLabel:TextField;

    //public var backToStartBtn:Button = new Button();
    public var backToStartBtn:BitmapButton;
    //public var playPauseBtn:Button= new Button();
    public var playPauseBtn:BitmapButton;
    public var playStopBtn:BitmapButton;
    //public var logPlaySpeedBtn:Button= new Button();
    public var logPlaySpeedBtn:BitmapButton;
    public var zoomPlusBtn:BitmapButton;
    public var zoomMinusBtn:BitmapButton;

    public static const controllsWidth:int = 166;

    public function LogReplayControlsAS(smallTimeline:SmallTimeline) {
        //this.width = 166;
        //this.height = TopBar.barHeight;
        this._smallTimeline = smallTimeline;

        createUTCLabels();
        addBtns();
    }

    public function addBtns(){

        backToStartBtn = new BitmapButton(
                replayback01PNG, replayback01PNG, replayback02PNG, replayback01PNG, replayback03PNG);
        backToStartBtn.addEventListener(MouseEvent.CLICK, _smallTimeline.backToStartHandler, false, 0, true)
        var backToStartBtnSp:Sprite = new Sprite();
        backToStartBtnSp.addChild(backToStartBtn);
        backToStartBtnSp.x = 78;
        backToStartBtnSp.y = 5;
        this.addChild(backToStartBtnSp);

        playPauseBtn = new BitmapButton(
            replayplay01PNG, replayplay01PNG, replayplay02PNG, replayplay01PNG, replayplay03PNG);
        playPauseBtn.addEventListener(MouseEvent.CLICK, _smallTimeline.playStopHandler, false, 0, true)
        var playPauseBtnSp:Sprite = new Sprite();
        playPauseBtnSp.addChild(playPauseBtn);
        playPauseBtnSp.x = 103;
        playPauseBtnSp.y = 5;
        //playPauseBtn.visible = true;
        this.addChild(playPauseBtnSp);

        playStopBtn = new BitmapButton(
                replaystop01PNG, replaystop01PNG, replaystop02PNG, replaystop01PNG, replaystop03PNG);
        playStopBtn.addEventListener(MouseEvent.CLICK, _smallTimeline.playStopHandler, false, 0, true)
        var playStopBtnSp:Sprite = new Sprite();
        playStopBtnSp.addChild(playStopBtn);
        playStopBtnSp.x = 103;
        playStopBtnSp.y = 5;
        //playStopBtn.visible = false;
        this.addChild(playStopBtnSp);

        logPlaySpeedBtn = new BitmapButton(
                replayx01PNG, replayx01PNG, replayx02PNG, replayx01PNG, replayx03PNG, "X1", null, 12, 0x000000);

        logPlaySpeedBtn.addEventListener(MouseEvent.CLICK, _smallTimeline.changeSpeed, false, 0, true)
        var logPlaySpeedBtnSp:Sprite = new Sprite();
        logPlaySpeedBtnSp.addChild(logPlaySpeedBtn);
        logPlaySpeedBtnSp.x = 138;
        logPlaySpeedBtnSp.y = 5;
        this.addChild(logPlaySpeedBtnSp);

        zoomPlusBtn = new BitmapButton(
                replayzoomin01PNG, replayzoomin01PNG, replayzoomin02PNG, replayzoomin01PNG, replayzoomin02PNG);
        zoomPlusBtn.id = "plus";
        zoomPlusBtn.addEventListener(MouseEvent.CLICK, _smallTimeline.changeZoomLevel, false, 0, true);
        var zoomPlusBtnSp:Sprite = new Sprite();
        zoomPlusBtnSp.addChild(zoomPlusBtn);
        zoomPlusBtnSp.x = 164;
        zoomPlusBtnSp.y = 3;
        this.addChild(zoomPlusBtnSp);

        zoomMinusBtn = new BitmapButton(
                replayzoomout01PNG, replayzoomout01PNG, replayzoomout02PNG, replayzoomout01PNG, replayzoomout02PNG);
        zoomMinusBtn.id = "minus";
        zoomMinusBtn.addEventListener(MouseEvent.CLICK, _smallTimeline.changeZoomLevel, false, 0, true);
        var zoomMinusBtnSp:Sprite = new Sprite();
        zoomMinusBtnSp.addChild(zoomMinusBtn);
        zoomMinusBtnSp.x = 164;
        zoomMinusBtnSp.y = 15
        this.addChild(zoomMinusBtnSp);

    }

    private function createUTCLabels():void {
        var bgsp:Sprite = new Sprite();
        bgsp.addChild(new counterbgPNG());
        bgsp.addEventListener(MouseEvent.CLICK, utcTimeL_clickHandler, false, 0, true);
        addChild(bgsp);
        timeLabel = FontFactory.getCustomDigital({size:12,align:"right"});
        timeLabel.x = 0;
        timeLabel.y = 10;
        timeLabel.width = 74;
        timeLabel.height = 22;
        //_timeLabel.addEventListener(MouseEvent.CLICK, utcTimeL_clickHandler)

        utcLabel = FontFactory.getCustomFont({size:6, width:25, height:10});
        utcLabel.x = 2;
        utcLabel.y = 2;
        utcLabel.text = "UTC";

        bgsp.addChild(timeLabel);
        bgsp.addChild(utcLabel);
    }

    public function get utcTime():Date {
        return _utcTime;
    }

    public function set utcTime(value:Date):void {
        _utcTime = value;
        setTextField()

    }

    private function setTextField():void {
        var formatter:DateTimeFormatter = new DateTimeFormatter("en-US");
        formatter.setDateTimePattern("HH:mm:ss");
        if (utcTime == null) {
            return;
        }
        switch(utcTimeState) {
            case UTC_TIME:
                timeLabel.text = formatter.formatUTC(_utcTime);
                break;
            case TIME_BEFORE_MARKER:
                var tempDate:TimeSpan = TimeSpan.fromDates(new Date(_smallTimeline.zoomHandler.minTime), utcTime);
                timeLabel.text = formatExtTime(tempDate.hours, tempDate.minutes, tempDate.seconds);
                break;
            case TIME_AFTER_MARKER:
                var tempDate:TimeSpan = TimeSpan.fromDates(utcTime, new Date(_smallTimeline.zoomHandler.maxTime));
                timeLabel.text = "- " + formatExtTime(tempDate.hours, tempDate.minutes, tempDate.seconds);
                break;
            default:
                timeLabel.text = formatter.formatUTC(_utcTime);
                break;
        }
    }

    private function formatExtTime(hours, minutes, seconds):String {
        return (hours < 10 ? "0" + hours : hours) + ":" + ( minutes < 10 ? "0" + minutes : minutes) + ":" + (seconds < 10 ? "0" + seconds : seconds)
    }

    private function utcTimeL_clickHandler(event:MouseEvent):void {
        utcTimeState++;
        utcTimeState = utcTimeState%3;

        if (utcTimeState==UTC_TIME) {
            utcLabel.visible = true;
        } else {
            utcLabel.visible = false;
        }
        setTextField();
        //TODO refresh label
    }

    public function resetTime():void {
        utcTimeState = UTC_TIME;
        utcLabel.visible = true;
        setTextField();
    }

    public function get smallTimeline():SmallTimeline {
        return _smallTimeline;
    }


    public function set smallTimeline(value:SmallTimeline):void {
        _smallTimeline = value;
    }
}
}
