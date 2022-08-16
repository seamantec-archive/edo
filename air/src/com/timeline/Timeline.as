package com.timeline
{
[Bindable]
	public class Timeline extends Window
	{
//		private var graph:CartesianChart;
//		private var _dataProvider:ArrayCollection = new ArrayCollection();
//		private var yData:String;
//		private var logFile:File;
//		private var canvas:CartesianDataCanvas;
//		private var sqlConnection:SQLConnection = new SQLConnection();
//		private var sqlStatement:SQLStatement = new SQLStatement();
//		private var sqlConnectionSelect:SQLConnection = new SQLConnection();
//		private var sqlStatementSelect:SQLStatement = new SQLStatement();
//		private var dpLength:Number = 0;
//		private var hGroup:HGroup;
//		private var controllBar:LogReplayControlls;
//		private var minMaxDistance:Number;
//		private var _zoomPercent:Number = 0;
//		private var _wReady:Boolean = false;
//		private static var _instance:Timeline;
//		private var marker:Marker;
//		private var horizontalAxis:DateTimeAxis;
//		private var progressBar:ProgressBar;
//		private var progressGroup:LogLoader;
//		private var segmentsNumber:Number;
//		private var maxSegmentsNumber:Number;
//		private var actualSegment:Number;
//		private var segmentsView:HGroup;
//		private var realClose:Boolean = false;
//		private var logDataHandler:LogDataHandler;
//
//		public function Timeline()
//		{
//			if(_instance != null){
//
//			}else{
//				super();
//				this.width = 800;
//				this.height = 300;
//				yData = "vhw_waterSpeedKnots"
//				hGroup = new HGroup();
//				hGroup.percentWidth = 100;
//				hGroup.top = 0;
//				hGroup.bottom = 50;
//
//				segmentsView = new HGroup();
//				segmentsView.percentWidth = 100;
//				segmentsView.bottom = 0;
//				segmentsView.height = 50;
//
//				this.addElement(hGroup);
//				this.addElement(segmentsView);
//
//				controllBar = new LogReplayControlls();
//				hGroup.addElementAt(controllBar, 0);
//				initGraph();
//
//				this.addEventListener(Event.CLOSING, closeHandler);
//				this.addEventListener(Event.OPEN, openHandler);
//				this.addEventListener(Event.RESIZE, resizeHandler);
//				this.addEventListener(AIREvent.WINDOW_COMPLETE, windowReadyHandler);
//
//			/*	sqlStatementSelect.sqlConnection = sqlConnectionSelect;
//				sqlConnectionSelect.open(logFile);*/
//
//
//
//
//			}
//
//		}
//		private function dataReadyHandler(event:Event){
//			dataProvider = logDataHandler.dataProvider;
//			goToBeginningOfGraph();
//		}
//		private function initLoadingGroup():void{
//			progressGroup = new LogLoader();
//			progressGroup.setCurrentState("not_loading");
//			this.addElement(progressGroup);
//			progressBar = progressGroup.progressBar;
//		}
//
//		protected function stopLoading(event:MouseEvent):void
//		{
//			terminateParserWorker()
//			progressGroup.setCurrentState("not_loading");
//			controllBar.openLogFileBtn.enabled = true;
//		}
//
//		private function terminateParserWorker():void{
//			DataParserHandler.instance.removeEventListener(StatusUpdateEvent.STATUS_UPDATE, setProgress);
//			DataParserHandler.instance.removeEventListener(ReadyEvent.READY, readyLoadingHandler);
//			DataParserHandler.instance.removeEventListener(UpdateSegmentsEvent.UPDATE_SEGMENTS, updateSegmentsStatusHandler);
//			DataParserHandler.instance.removeEventListener(StopForSegmentationEvent.STOP_FOR_SEGMENTATION, refreshLoadingHandler);
//			DataParserHandler.instance.removeEventListener(ParsingStartedEvent.PARSING_STARTED, logFileParsingStartedHandler);
//			WorkersHandler.instance.nmeaLogReaderWorker.terminate();
//
//		}
//
//		protected function windowReadyHandler(event:AIREvent):void
//		{
//			_wReady = true;
//
//			initLoadingGroup();
//			initMarker();
//			var file:File = DataLogger.instance.db;
//			logDataHandler = new LogDataHandler(marker, file, true, dataProvider, yData);
//			logDataHandler.addEventListener("data-ready", dataReadyHandler);
//			logDataHandler.addEventListener("step-timer", stepTimer);
//			initControlls();
//
//
//			graph.addEventListener(MouseEvent.MOUSE_DOWN, graphMouseDownHandler);
//			graph.addEventListener(MouseEvent.MOUSE_UP, graphMouseUpHandler);
//
//		}
//		private function initMarker():void{
//			marker = new Marker(canvas.parent.x + controllBar.width, canvas.height);
//			marker.maxX = this.width;
//			marker.addEventListener(MouseEvent.MOUSE_DOWN, graphMouseDownHandler);
//			marker.addEventListener("actualeTimeChanged", actualTimeChanged)
//			this.addElement(marker);
//		}
//		protected function actualTimeChanged(event:Event):void
//		{
//			logDataHandler.updateInstrumentsManualy(marker.actualTime);
//			logDataHandler.updateGraphs();
//		}
//
//		public function getDataForChart(tableName:String, timestamp:Number):ArrayCollection{
//			return logDataHandler.getDataForChart(tableName, timestamp);
//		}
//
//		private function initControlls():void{
//
//			controllBar.playPauseBtn.addEventListener(MouseEvent.CLICK, playStopHandler);
//			controllBar.backToStartBtn.addEventListener(MouseEvent.CLICK, backToStartHandler)
//			controllBar.logPlaySpeedBtn.addEventListener(MouseEvent.CLICK, logDataHandler.changeSpeed);
//			//controllBar.chartZoomScroll.addEventListener(Event.CHANGE, zoomChangeHandler);
//			controllBar.zoomMinus.addEventListener(MouseEvent.CLICK, zoomChangeHandler);
//			controllBar.zoomPlus.addEventListener(MouseEvent.CLICK, zoomChangeHandler);
//			controllBar.setSelectedYData(yData);
//			controllBar.yDataDDList.addEventListener(Event.CHANGE, selectYDataHandler);
//			controllBar.openLogFileBtn.addEventListener(MouseEvent.CLICK, openLogFileHandler);
//			controllBar.selectYDataBtn.addEventListener(MouseEvent.CLICK, testHandler);
//		}
//
//		protected function testHandler(event:MouseEvent):void
//		{
//			getFileNameFromSegmentName("Log 2012-05-23 161506.nmea.1.edodb");
//
//		}
//
//		/*----------- MARKER MOUSE HANDLER--------------------*/
//		protected function graphMouseDownHandler(event:MouseEvent):void
//		{
//
//			moveMarker(event)
//			this.addEventListener(MouseEvent.MOUSE_MOVE, mouseMovehandler);
//			logDataHandler.timer.stop()
//			controllBar.playPauseBtn.label = "play";
//			var boundRec:Rectangle = new Rectangle(marker.minX, marker.y, marker.maxX-marker.minX, marker.height);
//			marker.startDrag(false, boundRec);
//
//
//		}
//		protected function graphMouseUpHandler(event:MouseEvent):void
//		{
//			this.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMovehandler);
//			marker.stopDrag();
//		}
//		private function mouseMovehandler(event:MouseEvent):void{
//			moveMarker(event)
//		}
//
//		private function moveMarker(event:MouseEvent):void{
//			marker.actualMarkerX = event.stageX;
//			marker.calculateActualTime();
//		}
//
//
//
//
//
//		protected function selectYDataHandler(event:Event):void
//		{
//			logDataHandler.yData = event.currentTarget.selectedItem.data;
//
//		}
//
//
//
//		//BIG TODO COMMENTEZES AMIG EMLEKSZEM RA
//		protected function zoomChangeHandler(event:Event):void
//		{
//			var oldFragmentsNumber:Number = logDataHandler.fragementsNumber;
//
//			var diffFragments:Number = 0;
//			if(event.currentTarget.id == "zoomMinus"){
//				increaseZoom()
//			}else if(event.currentTarget.id == "zoomPlus"){
//				decreaseZoom()
//			}
//
//			logDataHandler.fragementsNumber = 100 - zoomPercent;
//			diffFragments = oldFragmentsNumber-logDataHandler.fragementsNumber;
//			var chartMinimumTime:Number = horizontalAxis.minimum.time;
//			var chartMaximumTime:Number = horizontalAxis.maximum.time;
//			var timeFromMin:Number = marker.actualTime-chartMinimumTime;
//			var timeFromMax:Number = chartMaximumTime- marker.actualTime;
//
//			var minMaxRate:Number = timeFromMin /  (chartMaximumTime-chartMinimumTime);
//			var fragmentsToMin:Number = diffFragments * minMaxRate;
//			var fragmentsToMax:Number = diffFragments - fragmentsToMin;
//
//			var newMin:Number = chartMinimumTime+fragmentsToMin*logDataHandler.fragementLength;
//			var newMax:Number = chartMaximumTime-fragmentsToMax*logDataHandler.fragementLength;
//			if(newMax > logDataHandler.lastData.sailDataTimestamp){
//				newMax = logDataHandler.lastData.sailDataTimestamp
//			}
//
//			if(newMin < logDataHandler.firstData.sailDataTimestamp){
//				newMin = logDataHandler.firstData.sailDataTimestamp
//			}
//			setChartMinMax(newMin, newMax);
//
//
//			marker.calculateActulateX();
//		}
//
//
//
//
//		private function getRemainedMinFragmentsForReduction(fragmentsFromMin:Number):Number{
//			var enoughMin:Boolean = false;
//			var i:int = 1;
//			while(!enoughMin && fragmentsFromMin > 0){
//				if(logDataHandler.firstData.sailDataTimestamp < (marker.actualTime - logDataHandler.fragementLength*i)){
//					fragmentsFromMin--;
//					i++;
//				}else{
//					enoughMin = true;
//				}
//			}
//			return fragmentsFromMin;
//		}
//		private function getRemainedMaxFragmentsForIncrease(fragmentsFromMax:Number):Number{
//			var enoughMax:Boolean = false;
//			var i:int = 1;
//			while(!enoughMax && fragmentsFromMax > 0){
//				if(logDataHandler.lastData.sailDataTimestamp > (marker.actualTime + logDataHandler.fragementLength*i)){
//					fragmentsFromMax--;
//					i++;
//				}else{
//					enoughMax = true;
//				}
//			}
//			return fragmentsFromMax;
//		}
//		private function getRemainedMaxFragmentsForReduction(fragmentsFromMax:Number):Number{
//			var enoughMax:Boolean = false;
//			var i:int = 1;
//			while(!enoughMax && fragmentsFromMax > 0){
//				if(logDataHandler.lastData.sailDataTimestamp > (marker.actualTime + logDataHandler.fragementLength*i)){
//					fragmentsFromMax--;
//					i++;
//				}else{
//					enoughMax = true;
//				}
//			}
//			return fragmentsFromMax;
//		}
//
//
//		protected function backToStartHandler(event:MouseEvent):void
//		{
//			stopAndBackToBegening();
//
//		}
//
//		protected function playStopHandler(event:MouseEvent):void
//		{
//			if(logDataHandler.timer.running){
//				logDataHandler.timer.stop();
//				controllBar.playPauseBtn.label = "play";
//			}else{
//				logDataHandler.timer.start();
//				controllBar.playPauseBtn.label = "pause";
//			}
//		}
//
//
//		protected  function closeHandler(event:Event):void
//		{
//			if(!realClose){
//				this.visible = false;
//				event.preventDefault();
//			}
//			logDataHandler.timer.stop();
//			WindowsHandler.instance.dataSource = "socket";
//		}
//
//		[Bindable]
//		public function get dataProvider():ArrayCollection
//		{
//			return _dataProvider;
//		}
//
//		public function set dataProvider(value:ArrayCollection):void
//		{
//			_dataProvider = value;
//		}
//
//
//
//
//
//		protected function stepTimer(event:Event):void
//		{
//			marker.actualTime = marker.actualTime + 1000;
//			marker.calculateActulateX();
//			if(logDataHandler.lastData.sailDataTimestamp < marker.actualTime){
//				if(actualSegment == maxSegmentsNumber){
//					stopAndBackToBegening();
//				}else{
//					actualSegment++;
//					logDataHandler.openDb(getExistingLogFile(getFileNameFromSegmentName(logFile.name) + "." + actualSegment), actualSegment);
//					if(!logDataHandler.timer.running){
//						logDataHandler.timer.start();
//					}
//				}
//			}
//			if(horizontalAxis.maximum.time < marker.actualTime && logDataHandler.lastData.sailDataTimestamp > marker.actualTime){
//				var newMax:Number = marker.actualTime + logDataHandler.fragementLength * logDataHandler.fragementsNumber;
//				if(newMax < logDataHandler.lastData.sailDataTimestamp){
//					setChartMinMax(marker.actualTime, newMax);
//				}else{
//					var leftDistance = newMax - logDataHandler.lastData.sailDataTimestamp;
//					var additionalMinSegments:Number = Math.round(leftDistance / logDataHandler.fragementLength);
//					setChartMinMax(marker.actualTime -logDataHandler.fragementLength*additionalMinSegments, logDataHandler.lastData.sailDataTimestamp);
//				}
//			}
//
//		}
//
//		private function setChartMinMax(min:Number, max:Number):void{
//			var axis:DateTimeAxis = horizontalAxis;
//			axis.minimum = new Date(min);
//			axis.maximum = new Date(max);
//			marker.minTime = min;
//			marker.maxTime = max;
//		}
//
//
//		private function stopAndBackToBegening():void{
//			actualSegment = 1;
//			logDataHandler.openDb(getExistingLogFile(getFileNameFromSegmentName(logFile.name) + "." + actualSegment), actualSegment);
//			logDataHandler.timer.stop();
//			logDataHandler.timer.reset();
//			controllBar.playPauseBtn.label = "play";
//			goToBeginningOfGraph();
//		}
//
//		private function goToBeginningOfGraph():void{
//			marker.actualTime = logDataHandler.firstData.sailDataTimestamp;
//			marker.calculateActulateX();
//			setChartMinMax(logDataHandler.firstData.sailDataTimestamp,logDataHandler.lastData.sailDataTimestamp)
//			logDataHandler.fragementsNumber = 100;
//			zoomPercent=0;
//
//		}
//
//
//
//
//		private function increaseZoom():void{
//			if(zoomPercent > 0){
//				zoomPercent = zoomPercent - 5;
//			}
//		}
//
//		private function decreaseZoom():void{
//			if(zoomPercent < 100){
//				zoomPercent= zoomPercent + 5;
//			}
//
//		}
//		private function initGraph():void{
//			graph = new LineChart();
//			graph.showDataTips = true;
//			var backgroundFill = new SolidColor();
//			backgroundFill.color = 0x202020;
//			backgroundFill.alpha = 1;
//			graph.setStyle("fill", backgroundFill);
//			graph.percentWidth = 100;
//			graph.percentHeight = 100;
//			graph.top = 30;
//			graph.bottom = 30;
//			BindingUtils.bindProperty(graph, "dataProvider", this, "dataProvider");
//			var dtAxis:DateTimeAxis = new DateTimeAxis();
//			dtAxis.dataUnits="milliseconds";
//			dtAxis.parseFunction = myParseFunction;
//
//			graph.horizontalAxis = dtAxis;
//
//
//			var linearSeries:LineSeries = new LineSeries();
//			linearSeries.xField="sailDataTimestamp";
//			linearSeries.displayName = "Windspeed";
//			linearSeries.yField = "field_value";
//			linearSeries.interpolateValues = true;
//			linearSeries.setStyle("form", "segment");
//			var stroke:SolidColorStroke = new SolidColorStroke();
//			stroke.color = 0xFFFFFF;
//			stroke.weight = 3;
//			linearSeries.setStyle("lineStroke", stroke);
//			graph.series.push(linearSeries);
//
//
//
//			//GRID LINES
//			var bge:GridLines = new GridLines();
//
//			var s:SolidColorStroke = new SolidColorStroke(0x202020, 1);
//			bge.setStyle("horizontalStroke", s);
//
//			var f:SolidColor = new SolidColor(0x202020, .3);
//			bge.setStyle("horizontalFill",f);
//
//			var f2:SolidColor = new SolidColor(0x336699, .3);
//			bge.setStyle("horizontalAlternateFill",f2);
//
//			graph.backgroundElements = [bge];
//
//			canvas = new CartesianDataCanvas();
//			canvas.includeInRanges = true;
//			graph.annotationElements.push(canvas);
//			hGroup.addElement(graph);
//
//			horizontalAxis = DateTimeAxis(graph.horizontalAxis);
//
//		}
//
//		protected function openLogFileHandler(event:MouseEvent):void
//		{
//			logFile = File.documentsDirectory;
//			logFile.browseForOpen("Open");
//			logFile.addEventListener(Event.SELECT, logFileOpenSelectedHandler);
//
//		}
//
//		protected function logFileOpenSelectedHandler(event:Event):void
//		{
//			logFile = event.target as File;
//
//
//			if(logFile.extension == "edodb"){
//				logDataHandler.openDb(logFile, 0);
//				trace("sqlite");
//			}else{
//				progressGroup.setCurrentState("loading");
//				progressGroup.stopBtn.addEventListener(MouseEvent.CLICK, stopLoading)
//				progressBar = progressGroup.progressBar;
//				parseNmeaData();
//
//			}
//		}
//
//		private function getExistingLogFile(fileName:String = null):File
//		{
//			if(fileName == null){
//				fileName = logFile.name;
//			}
//			//TODO ha nincs a file, akkor baj van, ezt lekell kezelni
//			var file:File = File.documentsDirectory;
//			file = file.resolvePath("sailing/"+fileName+".edodb");
//			return file;
//		}
//
//		public function readyLoadingHandler(event:ReadyEvent):void{
//			var fileName = event.fileName;
//			logFile = getExistingLogFile(fileName);
//			logDataHandler.openDb(logFile, 0);
//			progressGroup.setCurrentState("not_loading");
//			terminateParserWorker()
//			controllBar.openLogFileBtn.enabled = true;
//		}
//
//		public function refreshLoadingHandler(event:StopForSegmentationEvent):void{
//			var fileName:String = event.fileName;
//			var actualIndex:Number = event.actualIndex;
//			var nativePath:String = event.fileNativePath;
//			//load just the first log file
//			if(actualIndex <= 30000){
//				logFile = getExistingLogFile(fileName);
//				logDataHandler.openDb(logFile, 0);
//			}
//			progressGroup.setCurrentState("bg_loading");
//			updateSegmentsStatusHandler(new UpdateSegmentsEvent(nativePath));
//			WorkersHandler.instance.mainToNmeaReader.send({action:"continue", from: actualIndex+1});
//		}
//
//		public function logFileParsingStartedHandler(event:ParsingStartedEvent):void{
//			var fileNativePath:String = event.fileName;
//			var logEntry:Object = LogRegister.instance.getLogEntry(new File(fileNativePath));
//			if(logEntry != null){
//				maxSegmentsNumber = logEntry.max_number_of_segments;
//				segmentsNumber = logEntry.number_of_segments;
//				actualSegment = -1;
//				if(logEntry.line_counter >=30000 || logEntry.line_counter == logEntry.max_line_counter){
//					actualSegment = 1;
//					logFile = getExistingLogFile(logEntry.name + "." + actualSegment);
//					logDataHandler.openDb(logFile,0);
//				}
//			}
//			controllBar.openLogFileBtn.enabled = false;
//
//		}
//
//		public function updateSegmentsStatusHandler(event:UpdateSegmentsEvent):void{
//			var fileNativePath:String = event.fileName;
//			var logEntry:Object = LogRegister.instance.getLogEntry(new File(fileNativePath));
//			maxSegmentsNumber = logEntry.max_number_of_segments;
//			segmentsNumber = logEntry.number_of_segments;
//			segmentsView.removeAllElements();
//			for(var i:int = 1; i<=maxSegmentsNumber;i++){
//					var btn:Button = new Button();
//					btn.label = i + "";
//					btn.id = i + "";
//					btn.addEventListener(MouseEvent.CLICK, segmentChangeHandler);
//					if(i<=segmentsNumber){
//						btn.enabled = true;
//					}else{
//						btn.enabled = false;
//					}
//					segmentsView.addElement(btn);
//			}
//		}
//
//		protected function segmentChangeHandler(event:MouseEvent):void
//		{
//
//			trace("segment changed to " + getFileNameFromSegmentName(logFile.name) + "." + event.currentTarget.id +".edodb" );
//			logDataHandler.openDb(getExistingLogFile(getFileNameFromSegmentName(logFile.name) + "." + event.currentTarget.id), 0);
//			actualSegment = event.currentTarget.id;
//
//		}
//
//		private function getFileNameFromSegmentName(name:String):String{
//			var temp:Array = name.split(".");
//			var newFileContent:Array = [];
//			for(var i:int = 0;i<temp.length-2;i++){
//				newFileContent.push(temp[i]);
//			}
//			return newFileContent.join(".");
//		}
//
//
//
//		private function parseNmeaData():void{
//			progressGroup.setCurrentState("loading");
//			DataParserHandler.instance.addEventListener(StatusUpdateEvent.STATUS_UPDATE, setProgress);
//			DataParserHandler.instance.addEventListener(ReadyEvent.READY, readyLoadingHandler);
//			DataParserHandler.instance.addEventListener(UpdateSegmentsEvent.UPDATE_SEGMENTS, updateSegmentsStatusHandler);
//			DataParserHandler.instance.addEventListener(StopForSegmentationEvent.STOP_FOR_SEGMENTATION, refreshLoadingHandler);
//			DataParserHandler.instance.addEventListener(ParsingStartedEvent.PARSING_STARTED, logFileParsingStartedHandler);
//			DataParserHandler.instance.parseNmeaData(logFile);
//		}
//
//		public function setProgress(event:StatusUpdateEvent):void{
//				progressBar.setProgress(event.completed, event.total);
//		}
//
//
//		private function myParseFunction(s:Number):Date {
//			var newDate:Date = new Date(s);
//			return newDate;
//		}
//
//
//
//		protected function resizeHandler(event:ResizeEvent):void
//		{
//			if(_wReady){
//				marker.maxX = this.width;
//				marker.calculateActulateX();
//			}
//		}
//
//		public function get zoomPercent():Number
//		{
//			return _zoomPercent;
//		}
//
//		public function set zoomPercent(value:Number):void
//		{
//			_zoomPercent = value;
//			controllBar.zoomLevel.text = zoomPercent+"%";
//		}
//
//		protected function openHandler(event:Event):void
//		{
//			this.visible = true;
//
//		}
//
//		public static function get instance():Timeline{
//			if(_instance == null){
//				_instance = new Timeline();
//			}
//			return _instance;
//		}
//
//
//
//		public function killinstance():void
//		{
//			realClose = true;
//		}
	}
}