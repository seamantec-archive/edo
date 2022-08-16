package com.timeline {

import com.events.EnableDisableEvent;
import com.events.UnitChangedEvent;
import com.graphs.GraphHandler;
import com.loggers.LogEntry;
import com.loggers.LogRegister;
import com.loggers.SystemLogger;
import com.notification.NotificationHandler;
import com.notification.NotificationTypes;
import com.sailing.WindowsHandler;
import com.sailing.minMax.MinMaxHandler;
import com.sailing.nmeaParser.utils.NmeaPacketer;
import com.sailing.socket.SocketDispatcher;
import com.store.Statuses;
import com.timeline.events.ParsingStartedEvent;
import com.timeline.events.ReadyEvent;
import com.timeline.events.StatusUpdateEvent;
import com.timeline.events.StopForSegmentationEvent;
import com.ui.TopBar;
import com.ui.controls.Menu;
import com.utils.FontFactory;
import com.workers.WorkersHandler;

import flash.desktop.NativeApplication;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.System;
import flash.system.WorkerState;
import flash.text.TextField;
import flash.utils.Timer;
import flash.utils.getTimer;

public class SmallTimeline extends Sprite {

    [Embed(source='../../../assets/images/Layout pngs/timeline.png')] var timelinePNG:Class;
    [Embed(source='../../../assets/images/Layout pngs/timeline_start.png')] var timelineStartPNG:Class;
    [Embed(source='../../../assets/images/Layout pngs/timeline_start_more.png')] var timelineStartMorePNG:Class;
    [Embed(source='../../../assets/images/Layout pngs/timeline_end.png')] var timelineEndPNG:Class;
    [Embed(source='../../../assets/images/Layout pngs/timeline_end_more.png')] var timelineEndMorePNG:Class;

    public static const MAX_FILE_SIZE:Number = 31457280; // 30 MB

    private var _marker:MarkerforSmallTimeline;
    private var logFile:File;
    private var _logDataHandler:LogDataHandler;
    private var _actualTimeForLabel:Date;
    private var progressGroup:LogLoaderForSmallTimelineAS;
    private var filenameContainer:Sprite
    private var filenameLabel:TextField;
    private var _zoomHandler:ZoomHandler;
    private var statusGroup:Sprite;
    private var statusBar:Sprite;
    private var unloadedSegmentsMask:Sprite;
    private var needTween:Boolean = true;
    private var playedBar:Sprite;
    public var controlls:LogReplayControlsAS;

    private var _bar:Sprite;
    private var bgBegin:Bitmap;
    private var bgEnd:Bitmap;
    private var bgRightArrow:Bitmap;
    private var bgLeftArrow:Bitmap;

    private var unloadedSegmentsXTime:Number;

    private var ruller:Ruller;
    private var parseStartTimer:Timer = new Timer(1000, 1)
    private var needOpenAfterTerminate:Boolean = false;

    private var _timelineWidth:Number;

    public function SmallTimeline() {
        super();
        //this.height = TopBar.barHeight;
        //this.width = TopBar.logReplayWidth - LogReplayControlsAS.controllsWidth + 3;// - 30;
        this.graphics.beginFill(0xffffff, 0);
        this.graphics.drawRect(0, 0, TopBar.logReplayWidth - LogReplayControlsAS.controllsWidth + 3, TopBar.barHeight);

        unloadedSegmentsMask = new Sprite();
        playedBar = new Sprite();

        initLoadingGroup();
        createBg();
        initMarker();
        this.addEventListener(Event.ADDED_TO_STAGE, activateHandler, false, 0, true);
        this.addEventListener(MouseEvent.MOUSE_DOWN, markerMouseDownHandler, false, 0, true);
        this.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
        initLogDataHandler();
        MinMaxHandler.instance.addEventListener(UnitChangedEvent.CHANGE, reloadMinMaxes, false, 0, true);
        parseStartTimer.addEventListener(TimerEvent.TIMER_COMPLETE, parseStartTimer_timerCompleteHandler, false, 0, true);
    }

    private function createBg():void {
        _bar = new Sprite();
        _bar.x = 0;
        _bar.y = 3;
        _bar.graphics.beginFill(0xffffff, 0);
        _bar.graphics.drawRect(0, 0, this.width, 9);

        var bg:Sprite = new Sprite();
        bg.graphics.beginBitmapFill((new timelinePNG() as Bitmap).bitmapData);
        bg.graphics.drawRect(0, 0, this.width - 18, 9);
        bg.graphics.endFill();
        bg.x = 9;

        bgBegin = new Bitmap((new timelineStartPNG() as Bitmap).bitmapData);
        bgBegin.width = 9;
        bgBegin.height = 9;

        bgEnd = new Bitmap((new timelineEndPNG() as Bitmap).bitmapData);
        bgEnd.x = this.width - 10;
        bgEnd.width = 9;
        bgEnd.height = 9;

        bgLeftArrow = new Bitmap((new timelineStartMorePNG() as Bitmap).bitmapData);
        bgLeftArrow.width = 9;
        bgLeftArrow.height = 9;

        bgRightArrow = new Bitmap((new timelineEndMorePNG() as Bitmap).bitmapData);
        bgRightArrow.x = this.width - 10;
        bgRightArrow.width = 9;
        bgRightArrow.height = 9;

        _bar.addChild(bgLeftArrow);
        _bar.addChild(bgBegin);
        _bar.addChild(bg);
        _bar.addChild(bgRightArrow);
        _bar.addChild(bgEnd);

        _bar.scrollRect = new Rectangle(0, 0, 0, 9);

        this.addChild(_bar);
    }

    private function initLogDataHandler():void {
        _logDataHandler = new LogDataHandler(_marker);
        _logDataHandler.addEventListener("step-timer", stepTimer, false, 0, true);
        _logDataHandler.addEventListener("select-connection-ready", resultDataReadyHandler, false, 0, true);
    }

    /**
     * If user dragging the marker and leave timestamp area release the marker.
     * */
    protected function mouseOutHandler(event:MouseEvent):void {
        if (!event.currentTarget is Marker) {
            mouseUpHandler(event);
        }
    }


    /**
     * When timeline is added to stage call this method.
     * In this method we initialize the marker maxX and some other things
     * */
    protected function activateHandler(event:Event):void {
        globalPositionX = this.localToGlobal(new Point()).x;
        _marker.maxX = this.width;
        filenameLabel = FontFactory.getLogFileNameFont();
        filenameLabel.x = 0;
        filenameLabel.y = 0;
        filenameContainer = new Sprite()
        filenameContainer.x = this.width / 2 - 50;
        filenameContainer.y = this.height;
        filenameContainer.addChild(filenameLabel)
//        filenameContainer.depth = 5;
        this.addChild(filenameContainer);
        initStepButtons();
    }

    /**
     * Initialize loading group.
     * The loading group has 3 states.
     * Loading: when log file started loading the full timeline hided by this element.
     * bg_loading: when log file still loading but there is one or more segmnets loaded,
     * in this state the loading bar is positioned the bottom of the timeline, and the timeline is usable
     * not_loading: the loading group is hidden.
     *
     * */
    private function initLoadingGroup():void {
        progressGroup = new LogLoaderForSmallTimelineAS();
        progressGroup.setCurrentState("loading");
        progressGroup.x = 0;
        progressGroup.y = 3;
        this.addChild(progressGroup);
        progressGroup.setCurrentState("not_loading");
    }

    /**
     *
     * Initialize statusbar for timeline.
     * This status bar shows the user where is the current segment stands in the full log file,
     * and shows the actual zoom levelel.
     *
     * */
    private function initStatusGroup():void {
        statusGroup = new Sprite();
        statusGroup.graphics.beginFill(0x000000);
        statusGroup.graphics.drawRect(0, this.height - 3, this.width, 2);
        statusGroup.graphics.endFill();

        statusBar = new Sprite();
        statusBar.graphics.beginFill(0xffffff);
        statusBar.graphics.drawRect(0, this.height - 3, this.width, statusGroup.height);
        statusBar.graphics.endFill();
        statusGroup.addChild(statusBar);

        this.addChild(statusGroup);
    }

    /**
     * Initialize the marker.
     * Marker actual position drive the insturemnts saildata.
     *
     * */
    private function initMarker():void {
        _marker = new MarkerforSmallTimeline(0, 0, 0xFFFF00, 1);
        _marker.maxX = this.width;
        _marker.addEventListener(MouseEvent.MOUSE_DOWN, markerMouseDownHandler, false, 0, true);
        _marker.addEventListener("actualeTimeChanged", actualTimeChanged, false, 0, true);
        if (!contains(_marker)) {
            this.addChild(playedBar);
            this.addChild(_marker);
        }

        this.width -= (_marker.width / 2);
        _timelineWidth = this.width;

        initStatusGroup();
        initStepTimers();
        initZoomHandler();
    }

    /**
     * When marker actual time changed, we need to notify instruments about this change.
     * We update graphs too in this method
     * */
    protected function actualTimeChanged(event:Event):void {
        actualTimeForLabel = new Date(_marker.actualTime);
        if (!isNaN(_marker.actualTime) && _zoomHandler.isMarkerInActualSegment()) {
            _logDataHandler.updateInstrumentsManualy(_marker.actualTime, _zoomHandler.actualSegment.index, needTween);
        }
        GraphHandler.instance.updateAllMarker(_marker.actualTime);
        reFreshPlayedBar();
    }

    private function reFreshPlayedBar():void {
        drawPlayedBar();
    }

    private function drawPlayedBar():void {
        playedBar.graphics.clear();
        playedBar.graphics.beginFill(0xffc252);//, 0.8);
        if (!bgLeftArrow.visible || _marker.actualMarkerX <= bgLeftArrow.width) {
            playedBar.graphics.drawRoundRect(1, 4, _marker.actualMarkerX, 6, 4);
        } else {
            playedBar.graphics.drawRect(bgLeftArrow.width - 2, 4, _marker.actualMarkerX - bgLeftArrow.width, 6);
        }
        playedBar.graphics.endFill();
        //this.addChild(playedBar);
    }

    protected function resultDataReadyHandler(event:Event):void {
        actualTimeChanged(new Event("temp"));
    }

    private var localMouseX:int;

    /**
     * When the user click into the timeline, or click to marker
     * stop the timer.
     * */
    protected function markerMouseDownHandler(event:MouseEvent):void {
        event.stopPropagation();
        needTween = false;
        if (progressGroup.currentState != "loading") {
            if (/*unloadedSegmentsMask != null*/ _zoomHandler.isLoading()) {
                if (event.stageX >= unloadedSegmentGlobalX) {
                    return;
                }
            }

//            if(!isDrag) {
            if (event.currentTarget is MarkerforSmallTimeline) {
                localMouseX = event.localX
            } else {
                localMouseX = 0;
            }
//                isDrag = true;
//            }
            trace("start move", localMouseX)
            moveMarker(event)
            this.addEventListener(MouseEvent.MOUSE_MOVE, mouseMovehandler, false, 0, true);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMovehandler, false, 0, true);
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
            //just horizontal movements allowed. For this restriction we need to draw a boundry rectangle, for drag
            var boundRec:Rectangle = new Rectangle(_marker.minX, _marker.y, _marker.maxX - _marker.minX, _marker.y)//_marker.height);
            //var boundRec:Rectangle = new Rectangle(_marker.minX, _marker.y, 100, _marker.y)//_marker.height);
            _marker.startDrag(false, boundRec);
            _logDataHandler.timer.stop();
            refreshPlayStopButtonLabel();
        }

    }

    private function mouseMovehandler(event:MouseEvent):void {
        moveMarker(event)
    }

    protected function mouseUpHandler(event:MouseEvent):void {
        if (_logDataHandler.speed < 10) {
            needTween = true;
        }
        this.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMovehandler);
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMovehandler);
        stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
        if (progressGroup.currentState != "loading") {
            resetStepTimers();
            _marker.stopDrag();
            _marker.actualMarkerX = _marker.x;
            _marker.calculateActualTime();
            updateZoomHandlerAndLoadSegment()
            if (timerIsStarted) {
                _logDataHandler.timer.start();
            }
            refreshPlayStopButtonLabel();
        }

//        isDrag = false;
    }

    /**
     * Update the marker current time from mouse new x position.
     * */
    private function moveMarker(event:MouseEvent):void {
        resetStepTimers();
        var tempMakerX = _marker.actualMarkerX;
        if (_zoomHandler.isLoading()) {
            if (event.target is MarkerforSmallTimeline && event.currentTarget is Stage) {
                return;
            }
            if (event.stageX >= unloadedSegmentGlobalX) {
                _marker.actualMarkerX = unloadedSegmentGlobalX - globalPositionX;
                _marker.calculateActualTime();
                updateZoomHandlerAndLoadSegment()
                return;
            }
        }


        _marker.actualMarkerX = mouseX - localMouseX;
        _marker.calculateActualTime();

        //Prev segment section
        if (_marker.actualMarkerX == _marker.minX) {
            prevSegmentTimer.start();
        } else if (_marker.actualMarkerX == _marker.maxX) {
            nextSegmentTimer.start();
        }
        updateZoomHandlerAndLoadSegment()
    }

    private var lastMoveTimer:Number = 0;
    private var prevSegmentTimer:Timer = new Timer(50);
    private var nextSegmentTimer:Timer = new Timer(50);
    private var timerIsStarted:Boolean = false;
    private var globalPositionX:Number;
    private var unloadedSegmentGlobalX:Number;

    private function initStepTimers():void {
        prevSegmentTimer.addEventListener(TimerEvent.TIMER, prevSegmentTimerHandler, false, 0, true);
        nextSegmentTimer.addEventListener(TimerEvent.TIMER, nextSegmentTimerHandler, false, 0, true);
    }

    private function resetStepTimers():void {
        prevSegmentTimer.stop();
        prevSegmentTimer.reset();
        prevSegmentTimer.delay = 50;
        nextSegmentTimer.stop();
        nextSegmentTimer.reset();
        nextSegmentTimer.delay = 50;
    }

    protected function nextSegmentTimerHandler(event:TimerEvent):void {

        nextSegmentTimer.delay = 150;
        var tempADist:Number = getStepTimeDistanceForStep();//zoomHandler.actualDistance;
        var maxDist:Number = _zoomHandler.maxTime - _zoomHandler.minTime;
        if (_zoomHandler.actualMax + tempADist <= _zoomHandler.maxTime) {
            _zoomHandler.actualMin += tempADist;
            _zoomHandler.actualMax += tempADist;
            _marker.calculateActualTime();
            refreshLabels();
        } else if (_zoomHandler.actualDistance != maxDist) {
            _zoomHandler.actualMin += _zoomHandler.maxTime - _zoomHandler.actualMax;
            _zoomHandler.actualMax = _zoomHandler.maxTime;
            _marker.calculateActualTime();
            refreshLabels();
        }

    }

    protected function prevSegmentTimerHandler(event:TimerEvent):void {
        prevSegmentTimer.delay = 150;
        var tempADist:Number = getStepTimeDistanceForStep()//zoomHandler.actualDistance;
        var maxDist:Number = _zoomHandler.maxTime - _zoomHandler.minTime;
        if (_zoomHandler.actualMin - tempADist >= _zoomHandler.minTime) {
            _zoomHandler.actualMin -= tempADist;
            _zoomHandler.actualMax -= tempADist;
            _marker.calculateActualTime();
            refreshLabels();
        } else if (_zoomHandler.actualDistance != maxDist) {
            _zoomHandler.actualMax -= (_zoomHandler.actualMin - _zoomHandler.minTime);
            _zoomHandler.actualMin = _zoomHandler.minTime
            _marker.calculateActualTime();
            refreshLabels();
        }

    }

    private function getStepTimeDistanceForStep():Number {
        if (_zoomHandler.tickSpaceId === 0) {
            return 3000000
        } else if (_zoomHandler.tickSpaceId === 1) {
            return 3000000
        } else if (_zoomHandler.tickSpaceId === 2) {
            return 1200000
        } else if (_zoomHandler.tickSpaceId === 3) {
            return 300000
        } else if (_zoomHandler.tickSpaceId === 4) {
            return 300000
        } else if (_zoomHandler.tickSpaceId === 5) {
            return 300000
        } else if (_zoomHandler.tickSpaceId === 6) {
            return 60000
        } else if (_zoomHandler.tickSpaceId === 7) {
            return 60000
        } else if (_zoomHandler.tickSpaceId === 8) {
            return 30000
        }
        return 60000
    }

    private function initStepButtons():void {
        //controlls.zoomPlusBtn.addEventListener(MouseEvent.CLICK, changeZoomLevel, false, 0, true);
        //controlls.zoomMinusBtn.addEventListener(MouseEvent.CLICK, changeZoomLevel, false, 0, true);
//        plusZoom.addEventListener(MouseEvent.CLICK, changeZoomLevel, false, 0, true);
//        minusZoom.addEventListener(MouseEvent.CLICK, changeZoomLevel, false, 0, true);
    }


    private function updateStatusBar(x:Number, width:Number):void {
        statusBar.width = width;
        statusBar.x = x;
    }


    protected function stepTimer(event:Event):void {
        try {
            _marker.actualTime = _marker.actualTime + 1000;
            _marker.calculateActulateX();
            if (_zoomHandler.actualSegment.maxTime < _marker.actualTime) {
                if (_zoomHandler.actualSegment.index == _zoomHandler.segments.length - 1) {
                    //stopAndBackToBeginning();
                    stopPlay();
                } else {
                    _zoomHandler.setActualSegmantAt(_zoomHandler.actualSegment.index + 1); //step into new db segment
                    loadActualSegment();
                    if (!_zoomHandler.actualSegment.inited) {
                        //stopAndBackToBeginning();
                        stopPlay();
                        return;
                    }
                    if (!_logDataHandler.timer.running) {
                        _logDataHandler.timer.start();
                    }
                }
            }
            if (_zoomHandler.actualMax < _marker.actualTime && _zoomHandler.maxTime > _marker.actualTime) {
                var newMax:Number = _marker.actualTime + _zoomHandler.actualDistance;
                if (newMax < _zoomHandler.maxTime) {
                    _zoomHandler.actualMin = _marker.actualTime;
                    _zoomHandler.actualMax = newMax;
                } else {
                    var leftDistance:Number = newMax - _zoomHandler.maxTime;
                    _zoomHandler.actualMin = _marker.actualTime - leftDistance;
                    _zoomHandler.actualMax = _zoomHandler.maxTime;
                }
                refreshLabels();
            }
        } catch (e:Error) {
            SystemLogger.Error("can't step timer " + e.message + " zoomhandler " + _zoomHandler + "_zoomHandlerr.actualSegment " + _zoomHandler.actualSegment);
            SystemLogger.Debug(e.getStackTrace());
        }
    }

    private function initZoomHandler():void {
        _zoomHandler = new ZoomHandler(_marker, statusGroup.width);
        _zoomHandler.addEventListener("actual-distance-changed", zoomActualDistanceChangeHandler, false, 0, true);
        _zoomHandler.addEventListener("max-loaded-time-changed", maxLoadedTimeChangeHandler, false, 0, true);
    }

    /**
     * update loaded db segments mask.
     * */
    protected function maxLoadedTimeChangeHandler(event:Event):void {
        if (progressGroup.currentState == "loading") {
            return;
        }

        if (_zoomHandler.isLoading()) {
            //TODO remove
            try {
                this.removeChild(unloadedSegmentsMask);
            } catch (e:Error) {

            }
//        }
//
//        if (_zoomHandler.isLoading()) {

            //unloadedSegmentsMask.height = TopBar.barHeight;

            var maskWidth:Number = ((_zoomHandler.maxLoadedTime - _zoomHandler.minTime) / (_zoomHandler.maxTime - _zoomHandler.minTime)) * this.width;
//
//            if (maskWidth < 0) {
//                maskWidth = 0;
//            }
//
//            if (maskWidth <= this.width) {
//                //unloadedSegmentsMask.width = maskWidth;
//                unloadedSegmentsMask.x = 0;
//
//            } else {
//                maskWidth = this.width;
//                //unloadedSegmentsMask.width = this.width;
//                unloadedSegmentsMask.x = 0;
//
//            }
//
//            drawUnloadedSegmentMask(maskWidth);//, TopBar.barHeight);
//
            unloadedSegmentGlobalX = maskWidth + globalPositionX;
////            unloadedSegmentsMask.depth = 10;
//            unloadedSegmentsXTime = unloadedSegmentsMask.x * _marker.pixelDensity;
//            this.addChild(unloadedSegmentsMask);
//            this.setChildIndex(_marker, this.numChildren - 1);
            drawSegmentMask(maskWidth);
        } else {
            drawSegmentMask(_timelineWidth);
//            unloadedSegmentsMask.depth = 10;
//            drawUnloadedSegmentMask(this.width);
//            this.addChild(unloadedSegmentsMask);
//            this.setChildIndex(_marker, this.numChildren - 1);
        }

    }

    private function drawSegmentMask(width:Number):void {
        _bar.scrollRect = new Rectangle(0, 0, width, 9);
    }

    protected function zoomActualDistanceChangeHandler(event:Event):void {
        refreshLabels(true);
    }


    /**
     *
     * Refres time tick labels.
     *
     * There are different resolutions for a timeline.
     * The resolution mean how long in ms the timeline.
     *
     *The respolution categories setup in zoomHandler
     *
     * **/
    private function refreshLabels(isZoom:Boolean = false):void {
        _zoomHandler.statusBarWidthRatio = (isNaN(_zoomHandler.statusBarWidthRatio)) ? this.width : _zoomHandler.statusBarWidthRatio;

        if (ruller == null) {
            ruller = new Ruller(_zoomHandler.minTime, _zoomHandler.maxTime, this.height, this.width);
            this.addChildAt(ruller, this.getChildIndex(playedBar) + 1);
            ruller.reDraw(this.width / _zoomHandler.statusBarWidthRatio, this.width, _zoomHandler.minTime, _zoomHandler.maxTime);
        }
        updateStatusBar(_zoomHandler.statusBarX, _zoomHandler.statusBarWidthRatio);

        if (isZoom) {
            ruller.reDraw(this.width / _zoomHandler.statusBarWidthRatio, this.width, _zoomHandler.minTime, _zoomHandler.maxTime);
            ruller.moveToActualMin(_zoomHandler.statusBarX * (this.width / _zoomHandler.statusBarWidthRatio));

        } else {
            ruller.moveToActualMin(_zoomHandler.statusBarX * (this.width / _zoomHandler.statusBarWidthRatio));
        }

        if (progressGroup.currentState == "not_loading") {
            controlls.zoomPlusBtn.enabled = _zoomHandler.zoomPlusEnabled;
            controlls.zoomMinusBtn.enabled = _zoomHandler.zoomMinusEnabled;
        } else {
            disableZoomButtons();
        }

        if (_zoomHandler.minTime == _zoomHandler.actualMin && _zoomHandler.maxTime == _zoomHandler.actualMax) {
            bgLeftArrow.visible = false;
            bgRightArrow.visible = false;
            bgBegin.visible = true;
            bgEnd.visible = true;
        } else if (_zoomHandler.minTime != _zoomHandler.actualMin && _zoomHandler.maxTime != _zoomHandler.actualMax) {
            bgBegin.visible = false;
            bgEnd.visible = false;
            bgLeftArrow.visible = true;
            bgRightArrow.visible = true;
        } else if (_zoomHandler.minTime == _zoomHandler.actualMin && _zoomHandler.maxTime != _zoomHandler.actualMax) {
            bgLeftArrow.visible = false;
            bgEnd.visible = false;
            bgRightArrow.visible = true;
            bgBegin.visible = true;
        } else if (_zoomHandler.minTime != _zoomHandler.actualMin && _zoomHandler.maxTime == _zoomHandler.actualMax) {
            bgBegin.visible = false;
            bgRightArrow.visible = false;
            bgEnd.visible = true;
            bgLeftArrow.visible = true;
        }
    }


    private function updateZoomHandlerAndLoadSegment():void {
        if (!_zoomHandler.isMarkerInActualSegment()) {
            var segment:Segment = _zoomHandler.getSegmentForMarkerActualTime();
            if (segment != null) {
                _logDataHandler.openDb(_logDataHandler.getExistingLogFile(segment.name), segment.index);
                actualTimeChanged(new Event("temp"));
            }
        }
    }


    /**
     * Promt open file native os window.
     * */
    public function openLogFileHandler():void {
        if (Statuses.instance.socketStatus && !WindowsHandler.instance.application.socketDispatcher.isDemoConnected) {
            NotificationHandler.createAlert(NotificationTypes.USER_CONNECTION_CLOSE_ALERT, NotificationTypes.USER_CONNECTION_CLOSE_ALERT_TEXT, 1, selectFileForLoadLog);
        } else {
            selectFileForLoadLog();
        }

    }

    private function selectFileForLoadLog():void {
        WindowsHandler.instance.application.socketDispatcher.close(false);
        WindowsHandler.instance.application.socketDispatcher.stopDemoConnect();
        TopBar.timeline.hideLogReplay();

        NativeApplication.nativeApplication.openedWindows[0].activate();
        logFile = File.documentsDirectory;
        logFile.browseForOpen("Load NMEA log");
        logFile.addEventListener(Event.SELECT, logFileOpenSelectedHandler, false, 0, true);
        logFile.addEventListener(Event.CANCEL, logFileOpenCancelHandler, false, 0, true);


    }

    protected function logFileOpenSelectedHandler(event:Event):void {
        logFile = event.target as File;
        beforeOpenFileTerminateWorker();

    }

    public function reloadActualLog():void {
        TopBar.timeline.hideLogReplay();
        beforeOpenFileTerminateWorker();

    }

    private function beforeOpenFileTerminateWorker():void {
        try {
            terminateParserWorker(true);
        } catch (e:Error) {
            trace(e.message)

        }
    }


    public function openLog():void {

        if (!(logFile is File)) {
            return;
        }
        if (logFile.size <= MAX_FILE_SIZE) {
            var fileStream:FileStream = new FileStream();
            fileStream.open(logFile, FileMode.READ);
            var data:Array = new NmeaPacketer().newReadPacket(fileStream.readUTFBytes(NmeaPacketer.MAX_NMEA_MESSAGE_LEN + 10));
            fileStream.close()
            if (data.length > 0) {
                readyToLoad();
            } else {
                NotificationHandler.createWarning(NotificationTypes.WRONG_LOG_WARNING, NotificationTypes.WRONG_LOG_WARNING_TEXT);
            }
        } else {
            NotificationHandler.createWarning(NotificationTypes.LARGE_FILE_WARNING, NotificationTypes.LARGE_FILE_WARNING_TEXT);
        }
    }

    private function readyToLoad():void {
        trace("ready to load")
        WindowsHandler.instance.dataSource = "log";
        _logDataHandler.timer.stop();
        _logDataHandler.timer.reset();
        _bar.scrollRect = new Rectangle(0, 0, 0, 9);
        setLogFileText("");
        refreshPlayStopButtonLabel();
        initZoomHandler();
        initLogDataHandler();
        var logEntry:LogEntry = LogRegister.instance.getLogEntry(logFile);
        if (logEntry == null) {
            LogRegister.instance.addNewLog(logFile);
            logEntry = LogRegister.instance.getLogEntry(logFile);
        }
        if (logEntry == null) {
            SystemLogger.Error("Log entry is null " + logFile.nativePath);
            return;
        }

        GraphHandler.instance.updateAllMarker(marker.actualTime)
        MinMaxHandler.instance.datasourceChanged();
        WindowsHandler.instance.resetInstruments();

        if (logFile.extension == "edodb") {
            _logDataHandler.openDb(logFile, 0);
            trace("sqlite");
        } else {
            progressGroup.setCurrentState("loading");
            try {
                this.removeChild(unloadedSegmentsMask);
            } catch (e:Error) {
                parseNmeaData();
            }

        }
        disableControllButtons();
        _marker.actualMarkerX = _marker.minX;
        _marker.redrawMarker();
        stopAndBackToBeginning();
        dispatchEvent(new Event("logfile-selected"));

        TopBar.visibleSimulationLabel(false);
        Menu.enableAlarms(false);

//      if (AppProperties.settingWin != null) {
//          AppProperties.settingWin.enableLLN();
//      }
    }

    private function logFileOpenCancelHandler(event:Event):void {
        if (WindowsHandler.instance.isSocketDatasource()) {
            WindowsHandler.instance.dataSource = "socket";
            TopBar.menuList.dispatchEvent(new EnableDisableEvent(EnableDisableEvent.ENABLE, "nmeaMessagesE"));
        }
    }

    private function parseStartTimer_timerCompleteHandler(event:TimerEvent):void {
        if (SocketDispatcher.isArduinoNull()) {
            trace("startparsing arduino null")
            parseNmeaData();
        } else {
            trace("arduino not null wait more")
            parseStartTimer.reset();
            parseStartTimer.start();
        }
    }

    private function parseNmeaData():void {
        progressGroup.setCurrentState("loading");
        DataParserHandler.instance.addEventListener(StatusUpdateEvent.STATUS_UPDATE, setProgress, false, 0, true);
        DataParserHandler.instance.addEventListener(ReadyEvent.READY, readyLoadingHandler, false, 0, true);
        DataParserHandler.instance.addEventListener(StopForSegmentationEvent.STOP_FOR_SEGMENTATION, refreshLoadingHandler, false, 0, true);
        DataParserHandler.instance.addEventListener(ParsingStartedEvent.PARSING_STARTED, logFileParsingStartedHandler, false, 0, true);
        DataParserHandler.instance.parseNmeaData(logFile);
    }

    public function stopLoading(event:MouseEvent = null):void {
        terminateParserWorker(false)
        progressGroup.setCurrentState("not_loading");
    }

    public function setProgress(event:StatusUpdateEvent):void {
        progressGroup.setProgress(event.completed / event.total);
    }

    var readyLoadingLog:Boolean = false;

    public function readyLoadingHandler(event:ReadyEvent):void {
        var nPath:String = event.logFileNativePath;
        var logEntry:LogEntry = LogRegister.instance.getLogEntry(new File(nPath));
        if (logEntry != null) {
            setLogFileText(logEntry.name);
        }
        _zoomHandler.refreshFullSegmentList(logEntry);
        _logDataHandler.loadMinMaxes(_zoomHandler.segments);
        if (_zoomHandler.actualSegment == null) {
            loadFirstSegment();
            _zoomHandler.updateSegmentStatus(0, logEntry.id);

        }
        progressGroup.setCurrentState("not_loading");

        terminateParserWorker(false);
        GraphHandler.instance.graphDataHandler.openLogEntry(logEntry);
        GraphHandler.instance.graphDataHandler.fillGraphDataContainers();
        GraphHandler.instance.notifyAllEmptyGraphsToRefreshTimeline()
        GraphHandler.instance.updateAllMarker(marker.actualTime);
        drawSegmentMask(_timelineWidth);
        reFreshPlayedBar();
        readyLoadingLog = true;
        enableControllButtons();
        System.pauseForGCIfCollectionImminent(0.15);

    }

    private function setLogFileText(value:String):void {
        filenameLabel.text = value;
        filenameContainer.graphics.clear();
        filenameContainer.graphics.beginFill(0x000000, 0.5);
        filenameContainer.graphics.drawRect(-10, 0, filenameLabel.width+20, filenameLabel.height)
        filenameContainer.graphics.endFill()
    }

    public function reloadMinMaxes(event:UnitChangedEvent):void {
        if (!WindowsHandler.instance.isSocketDatasource()) {
            _logDataHandler.loadMinMaxes(_zoomHandler.segments);
        }
    }

    /***
     *
     * When stop for segmentation run this method.
     * Set the progress group into bg loading, and update zoomhandler segments
     * Notify the parser worker to continue
     *
     * If actualsegment which we got from event is 0 we load it.
     * */
    public function refreshLoadingHandler(event:StopForSegmentationEvent):void {
        var fileName:String = event.fileName;
        var actualIndex:Number = event.actualIndex;
        var nativePath:String = event.fileNativePath;
        progressGroup.setCurrentState("bg_loading");
        var logEntry:LogEntry = LogRegister.instance.getLogEntry(new File(event.fileNativePath));
        _zoomHandler.updateSegmentStatus(event.actualSegment, logEntry.id);
        _logDataHandler.loadMinMaxes(_zoomHandler.segments);
        //TODO refactor itt mar csak egy refresh kell, a log mar megvany nyitva
        GraphHandler.instance.graphDataHandler.openLogEntry(logEntry);
        GraphHandler.instance.graphDataHandler.fillGraphDataContainers();
        GraphHandler.instance.notifyAllEmptyGraphsToRefreshTimeline();
        GraphHandler.instance.updateAllMarker(marker.actualTime)
        //load just the first log file
        if (event.actualSegment == 0) {
            loadFirstSegment();
        }
        enableControllButtons();
        event.preventDefault();
        WorkersHandler.instance.mainToNmeaReader.send({action: "continue", from: actualIndex + 1});
    }

    /**
     * When the parsing started
     * check the db logregister if there is a line for this logfile its mean it is a countenue parsing,
     * so we can try to load first db segment
     * */
    public function logFileParsingStartedHandler(event:ParsingStartedEvent):void {
        var fileNativePath:String = event.fileName;
        disableZoomButtons();
        logFile = new File(fileNativePath);
        var logEntry:LogEntry = LogRegister.instance.getLogEntry(new File(fileNativePath));
        if (logEntry != null) {
            setLogFileText(logEntry.name);
        }
        if (logEntry != null) {
            _zoomHandler.maxTime = event.lastTimestamp;
            _zoomHandler.refreshFullSegmentList(logEntry);
            if (logEntry.lineCounter >= 30000 || logEntry.lineCounter == logEntry.maxLineCounter) {
                loadFirstSegment();
                _zoomHandler.updateSegmentStatus(0, logEntry.id);

            }
        }
    }

    private function loadActualSegment():void {
        try {
            _logDataHandler.openDb(_logDataHandler.getExistingLogFile(_zoomHandler.actualSegment.name), _zoomHandler.actualSegment.index);
        } catch (e:Error) {
            //SystemLogger.Error("can't load segment " + e.message + " zoomhandler " + _zoomHandler + "_zoomHandlerr.actualSegment " + _zoomHandler.actualSegment);
            //SystemLogger.Debug(e.getStackTrace());
        }
    }

    /**
     * if needFullReset we reset the zoom level too,
     *  if not we just go to the first segment and put the marker into the first position
     * */
    private function loadFirstSegment(needFullReset = true):void {
        _zoomHandler.setActualSegmantAt(0);
        loadActualSegment();
        if (needFullReset) {
            _zoomHandler.resetActualDistance();
        } else {
            _zoomHandler.goToBegeningOfTimelineWithoutZoomReset();
        }
        //FIXME bizonyos esetkebn az actualSegment null... egymasutan betoltott 4. log utan
        if (_zoomHandler.actualSegment == null) {
            return;
        }
        _marker.actualTime = _zoomHandler.actualSegment.minTime;
        _marker.calculateActulateX();
    }

    private function terminateParserWorker(needOpen:Boolean):void {
        DataParserHandler.instance.removeEventListener(StatusUpdateEvent.STATUS_UPDATE, setProgress);
        DataParserHandler.instance.removeEventListener(ReadyEvent.READY, readyLoadingHandler);
        DataParserHandler.instance.removeEventListener(StopForSegmentationEvent.STOP_FOR_SEGMENTATION, refreshLoadingHandler);
        DataParserHandler.instance.removeEventListener(ParsingStartedEvent.PARSING_STARTED, logFileParsingStartedHandler);
        if (!WorkersHandler.instance.isNmeaLogReaderWorkerNull() && (WorkersHandler.instance.nmeaLogReaderWorker.state == WorkerState.RUNNING || WorkersHandler.instance.nmeaLogReaderWorker.state == WorkerState.NEW)) {
            needOpenAfterTerminate = needOpen;
            WorkersHandler.instance.nmeaLogReaderWorker.addEventListener(Event.WORKER_STATE, workerStateHandler);
            WorkersHandler.instance.nmeaLogReaderWorker.terminate();
        } else if (needOpen) {
            needOpenAfterTerminate = needOpen;
            openLog();
        }
    }

    private function workerStateHandler(event:Event):void {
        if (event.currentTarget.state == WorkerState.TERMINATED) {
            WorkersHandler.instance.nmeaLogReaderWorker.removeEventListener(Event.WORKER_STATE, workerStateHandler)
            WorkersHandler.instance.setLogWorkerToNull();
            if (needOpenAfterTerminate) {
                var time:Number = getTimer();
                while (getTimer() - time < 300) {

                }
                openLog()
            }
        }
    }


    private function disableControllButtons():void {
        disableTime();
        disablePSButtons();
        disableZoomButtons();
        _marker.visible = false;
    }

    private function disableTime():void {
        controlls.timeLabel.visible = false;
        controlls.utcLabel.visible = false;
    }

    private function disablePSButtons():void {
        controlls.backToStartBtn.enabled = false;
        controlls.playPauseBtn.enabled = false;
        controlls.logPlaySpeedBtn.enabled = false;
        controlls.logPlaySpeedBtn.label = "";
    }

    private function disableZoomButtons():void {
        controlls.zoomPlusBtn.enabled = false;
        controlls.zoomMinusBtn.enabled = false;
    }

    private function enableControllButtons():void {
        enableTime();
        enablePSButtons();
        enableZoomButtons();
        _marker.visible = true;
    }

    private function enableTime():void {
        controlls.resetTime();
        controlls.timeLabel.visible = true;
        controlls.utcLabel.visible = true;
    }

    private function enablePSButtons():void {
        controlls.backToStartBtn.enabled = true;
        controlls.playPauseBtn.enabled = true;
        controlls.logPlaySpeedBtn.enabled = true;
        TopBar.timeline.resetSpeed();
    }

    private function enableZoomButtons():void {
        if (!_zoomHandler.isLoading()) {
            controlls.zoomPlusBtn.enabled = true;
            controlls.zoomMinusBtn.enabled = true;
        } else {
            disableZoomButtons();
        }
    }

    public function changeZoomLevel(event:MouseEvent):void {
        if (event.target.id == "minus") {
            _zoomHandler.decreaseZoom()
        } else if (event.target.id == "plus") {
            _zoomHandler.increaseZoom()
        }
        reFreshPlayedBar();
    }


    [Bindable]
    public function get actualTimeForLabel():Date {
        return _actualTimeForLabel;
    }

    public function set actualTimeForLabel(value:Date):void {
        _actualTimeForLabel = value;
        dispatchEvent(new Event("actualTimeLabelChanged"));
    }

    public function playStopHandler(event:MouseEvent):void {
        if (_logDataHandler.timer.running) {
            stopTimer();
            controlls.playPauseBtn.visible = true;
            controlls.playStopBtn.visible = false;
            event.currentTarget.label = ""//play";

        } else if (_marker.actualTime < _zoomHandler.maxTime) {
            _logDataHandler.timer.start();
            timerIsStarted = true;
            controlls.playPauseBtn.visible = false;
            controlls.playStopBtn.visible = true;
            event.currentTarget.label = ""//pause";
        }
    }

    public function stopTimer():void {
        _logDataHandler.timer.stop();
        timerIsStarted = false;
    }

    private function refreshPlayStopButtonLabel() {
        if (!_logDataHandler.timer.running) {
            controlls.playPauseBtn.visible = true;
            controlls.playStopBtn.visible = false;
        } else {
            controlls.playPauseBtn.visible = false;
            controlls.playStopBtn.visible = true;
        }
    }

    public function backToStartHandler(event:MouseEvent):void {
        stopAndBackToBeginning(false);
    }

    public function changeSpeed(event:MouseEvent):void {
        _logDataHandler.changeSpeed(event, zoomHandler.maxTime - zoomHandler.minTime);
        if (_logDataHandler.speed >= 10) {
            needTween = false;
        } else {
            needTween = true;
        }
    }

    private function stopAndBackToBeginning(needZoomreset:Boolean = true):void {
        _logDataHandler.timer.stop();
        _logDataHandler.timer.reset();
        timerIsStarted = false;
        goToBeginningOfTimelineSegment(needZoomreset);
        refreshPlayStopButtonLabel();
        playedBar.graphics.clear();
    }

    private function stopPlay():void {
        _logDataHandler.timer.stop();
        _logDataHandler.timer.reset();
        refreshPlayStopButtonLabel();
        timerIsStarted = false;
    }


    private function goToBeginningOfTimelineSegment(needZoomreset:Boolean = true):void {
        //marker.actualTime = logDataHandler.firstData.sailDataTimestamp;
        loadFirstSegment(needZoomreset);
    }


    public function get marker():Marker {
        return _marker;
    }

    public function get zoomHandler():ZoomHandler {
        return _zoomHandler;
    }


    public function get logDataHandler():LogDataHandler {
        return _logDataHandler;
    }


}
}