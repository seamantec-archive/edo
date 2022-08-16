/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.26.
 * Time: 15:51
 * To change this template use File | Settings | File Templates.
 */
package components.graph.custom {


import com.graphs.GraphData;
import com.graphs.GraphDataContainer;
import com.graphs.GraphHandler;
import com.graphs.YData;
import com.graphs.YDatas;
import com.layout.LayoutHandler;
import com.sailing.WindowsHandler;
import com.timeline.Marker;
import com.utils.FontFactory;

import components.graph.IGraph;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;

public class GraphInstance extends Sprite implements IGraph {

    public static const LABEL_WIDTH:uint = 55;
    [Embed(source="../../../../assets/images/graph_bg.png")]
    protected static var graphBgC:Class;
    [Embed(source="../../../../assets/images/graph_shadow.png")]
    protected static var graphShadowC:Class;
    protected static var graphShadowB:Bitmap = new graphShadowC();
    public static var topOffset:int = 10 + GraphControls.HEIGHT;
    public static var bottomOffset:int = 7;
    public static var leftOffset:int = 7;
    public static var rightOffset:int = 0;
    protected static var emptyContainer:Vector.<GraphData> = new <GraphData>[];

    protected var graphBg:Bitmap = new graphBgC();


    public static const MIN_WIDTH:int = 280;
    public static const MIN_HEIGHT:int = 100;


    public static var vAxisWidth:int = 35;
    public static var hAxisHeight:int = 20;
    public static var controlsHeight:int = 50;


    protected var _hAxis:Axis;
    protected var _vAxis:Axis;
    protected var _graph:Graph;
    protected var _zoomHandler:ZoomHandler;
    protected var _bgCanvas:Sprite;
    protected var _initWidth:int;
    protected var _initHeight:int;
    protected var _originWidth:int;
    protected var _originHeight:int;
    protected var _minMax:Object;
    protected var dragStartDataPoint:Point;
    protected var _graphAndAxis:Sprite;

    protected var _yData:String;
    protected var _marker:Marker;

    protected var _container:GraphDataContainer;
    protected var _isDragging:Boolean = false;

    protected var _frameSprite:GraphFrame;
    protected var _controls:GraphControls;

    protected var _ready:Boolean = false;
    protected var test:Boolean;
    protected var bgColor:uint;

    protected var _markerLabelBg:Sprite;
    protected var lastTValue:String;
    protected var lastLabelValuePure:Number;
    protected var _isHorizontal:Boolean = true;
    protected var defWidthForGraph:int = 0;
    protected var mouseIsDown:Boolean = false;
    protected var _zoomStartX:int = 0
    protected var _zoomStartY:int = 0
    protected var _zoomStartTime:Number = 0;
    protected var _prevGraphWidth:Number = 0;

    public function GraphInstance(yData:String, bgColor:uint = 0xffffff, test:Boolean = false) {
        super();
        this._zoomHandler = new ZoomHandler(this);
        this.test = test
        this._yData = yData;
        _graphAndAxis = new Sprite();
        createGraphByKey(_yData);
        _hAxis = new HTimeAxis(_zoomHandler.minTime, _zoomHandler.maxTime, this);
        _minMax = {min: 0, max: 100};
        _vAxis = new VDataAxis(_minMax.min, _minMax.max, this);

        this.bgColor = bgColor;
        _frameSprite = new GraphFrame();
    }

    public function graphHeightWithoutControlls():int {
        return _initHeight //- controlsHeight
    }


    public function yDataChange(newKey:String):void {
        GraphHandler.instance.removeListener(yData, this);
        //TODO ujragondolni hogy ide kell-e ez a reset
        resetGraph(false);
        _yData = newKey;
        createGraphByKey(newKey);
        _container = (GraphHandler.instance.containers[_yData.split("_")[0]][_yData.split("_")[1]] as GraphDataContainer);

        GraphHandler.instance.addListener(yData, this);
    }

    protected function createGraphByKey(key:String):void {
        if (_graphAndAxis != null && _graph != null && _graphAndAxis.contains(_graph)) {
            _graphAndAxis.removeChild(_graph);
        }
        var ydata:YData = YDatas.getByData(key)
        if (ydata === null) {
            ydata = YDatas.datas[0];
        }
        _yData = ydata.dataKey

        switch (ydata.graphType) {
            case YData.LINE_GRAPH:
                if (_vAxis != null)_vAxis.topZero = false;
                _graph = new Graph(this, this._initWidth - vAxisWidth, graphHeightWithoutControlls() - hAxisHeight, ydata);
                break;
            case YData.AREA_GRAPH:
                if (_vAxis != null) _vAxis.topZero = false;
                _graph = new AreaGraph(this, this._initWidth - vAxisWidth, graphHeightWithoutControlls() - hAxisHeight, ydata);
                break;
            case YData.DEPTH_GRAPH:
                if (_vAxis != null)_vAxis.topZero = true;
                _graph = new AreaGraph(this, this._initWidth - vAxisWidth, graphHeightWithoutControlls() - hAxisHeight, ydata);
                break;
        }

        if (_vAxis != null) _vAxis.quantalStep = ydata.quantalZoom;
        if (_bgCanvas != null) {
            _bgCanvas.setChildIndex(_vAxis, 1)
        }
        if (_graphAndAxis != null) {
            _graphAndAxis.addChild(_graph)
            if (_marker != null) {
                _graphAndAxis.setChildIndex(_graph, 1)
                _graphAndAxis.setChildIndex(_hAxis, 0)
                _graphAndAxis.setChildIndex(_marker, 2)
                _graphAndAxis.setChildIndex(_markerLabelBg, 3)
            }
        }
    }


    public function backToLive(event:MouseEvent):void {
        isDragging = false;
        if (WindowsHandler.instance.isSocketDatasource()) {
            scrollToEnd();
        } else {
            scrollToMarker();
        }
    }

    public function get marker():Marker {
        return _marker;
    }


    public function setMarkerTimeFromTimeline(time:Number, value:Number = NaN):void {
        if (marker == null) {
            return;
        }
        marker.actualTime = time;
        marker.calculateActulateX();
        if (dataProvider.length > 0) {
            marker.visible = true;
            _markerLabelBg.visible = true;
        } else {
            marker.visible = false;
            _markerLabelBg.visible = false;
        }
        if (isNaN(value)) {
            setLastLabelValue(NaN)
            setMarkerLabelXToMarker()
        } else {
            setLastLabelValue(value)
            setMarkerLabelXToMarker()
        }
        if (_isDragging || mouseIsDown) {
            return;
        }
        stepStageMarkerTime();
    }

    protected function stepStageMarkerTime():void {
        //Step into right
        if (Math.floor(_marker.actualMarkerX) > getScrollBoxEndX()) {
            scrollTo(_marker.actualMarkerX);
        } else if (_marker.actualMarkerX < getScrollBoxX()) {
            scrollTo(_marker.actualMarkerX - getScrollBoxWidth()); //hack
        }
    }

    protected function setMode():void {
        if (WindowsHandler.instance.isSocketDatasource()) {
            setLiveMode();
        } else {
            setLogReplayMode();
        }
    }

    public function setLiveMode():void {
        if (marker == null) {
            return;
        }
        marker.visible = false;
        _markerLabelBg.visible = true;
        marker.putMarkerIntoEnd();
        setMarkerLabelXToMarker()
    }

    public function setLogReplayMode():void {
        if (marker == null) {
            return;
        }
        marker.visible = true;
        if (GraphHandler.instance.timeLineMarkerTime != 0) {
            setMarkerTimeFromTimeline(GraphHandler.instance.timeLineMarkerTime)
        } else {
            marker.putMarkerIntoBeginning();
        }
        setMarkerLabelXToMarker()
    }

    public function resetGraph(needUpdateDp:Boolean = true):void {
        scrollBox(-_graphAndAxis.scrollRect.x);
        commonReset(needUpdateDp);
    }

    protected function commonReset(needUpdateDp:Boolean):void {
        _graph.reset();
        _hAxis.resetTextLabelsContainer();
        _vAxis.resetTextLabelsContainer();
        _minMax = {min: 0, max: 100};
        markerLabel.text = "";
        isDragging = false;
        //When y data change before call reset with this parameter as false
        if (needUpdateDp) {
            updateDp();
            _zoomHandler.reset();
        }
        setMode();
        _hAxis.reDraw();
        _vAxis.reDraw();
    }


    protected function mouseDownHandler(event:MouseEvent):void {
        if (!LayoutHandler.instance.editMode) {
            mouseIsDown = true;
            dragStartDataPoint = new Point(event.stageX, event.stageY);
            _bgCanvas.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true);
            _bgCanvas.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
            defWidthForGraph = _initWidth - vAxisWidth;
        }
    }

    protected function mouseMoveHandler(event:MouseEvent):void {
        if (WindowsHandler.instance.isSocketDatasource()) {
            isDragging = true;
        }
        var currDataPoint:Point = new Point(event.stageX, event.stageY);
        var dx:Number = dragStartDataPoint.x - currDataPoint.x;
        scrollBox(dx);
        dragStartDataPoint = new Point(event.stageX, event.stageY);
        putMarkerIntoMiddleLiveMode();
    }


    protected function mouseUpHandler(event:MouseEvent):void {
        _bgCanvas.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
        _bgCanvas.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
        stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
        mouseIsDown = false;
        if (WindowsHandler.instance.isSocketDatasource() && getScrollBoxEndX() === 0 && getScrollBoxEndX() === _graph.possibleMaxWidth) {
            isDragging = false;
        }
    }


    protected function scrollBox(dx:Number):void {
        scrollTo(getScrollBoxX() + dx);
    }

    public function getScrollBoxX():int {
        if (_graphAndAxis.scrollRect == null) {
            return 0;
        }
        return _graphAndAxis.scrollRect.x;
    }

    public function getScrollBoxY():int {
        if (_graphAndAxis.scrollRect == null) {
            return 0;
        }
        return _graphAndAxis.scrollRect.y;
    }

    public function getScrollBoxWidth():int {
        if (_graphAndAxis.scrollRect == null) {
            return 0;
        }
        return _graphAndAxis.scrollRect.width;
    }

    public function getScrollBoxHeight():int {
        if (_graphAndAxis.scrollRect == null) {
            return 0;
        }
        return _graphAndAxis.scrollRect.height;
    }

    public function getScrollBoxEndX():int {
        return getScrollBoxX() + getScrollBoxWidth();
    }

    public function getScrollBoxEndY():int {
        return getScrollBoxY() + getScrollBoxHeight();
    }

    public function scrollTo(x:int):void {
        if (_graphAndAxis.scrollRect == null || _graph.possibleMaxWidth === 0) {
            return;
        }
        var rect:Rectangle = _graphAndAxis.scrollRect;

        rect.x = x;
        if (rect.x < 0) {
            rect.x = 0;
        } else if ((rect.x + rect.width) > _graph.possibleMaxWidth) {
            rect.x = _graph.possibleMaxWidth - rect.width
            if (WindowsHandler.instance.isSocketDatasource()) {
                isDragging = false;
                scrollToEnd();
            }
        }
        _graphAndAxis.scrollRect = rect;

//        resizeGraphBg();
    }


    protected function scrollToEnd():void {
        if (_graphAndAxis.scrollRect == null) {
            return;
        }
        scrollTo(_graph.possibleMaxWidth - _graphAndAxis.scrollRect.width)
    }

    protected function scrollToMarker():void {
        scrollTo(_marker.actualMarkerX + getScrollBoxWidth() / 2);
    }

    public function resize(w:int, h:int):void {
        this.graphics.clear();
        this.graphics.beginFill(0x000000, 0);
        this.graphics.drawRect(0, 0, w, h);
        this.graphics.endFill();
        _initHeight = h - topOffset - bottomOffset;
        _initWidth = w - leftOffset - rightOffset;
        _originWidth = w;
        _originHeight = h;
        if (_initHeight <= 0) {
            _initHeight = 1;
        }
        //_graph.width = _initWidth - axisHeight;
        createBgCanvas();
        if (!_ready) {
            createGraphAndAxisView();
        }
//        resizeGraphBg();
        initMarker();
        if (_isHorizontal) {
            _zoomHandler.graphVisiblePixels = _initWidth - vAxisWidth;
        } else {
            _zoomHandler.graphVisiblePixels = _initHeight - hAxisHeight;

        }

        if (_isHorizontal) {
            _vAxis.x = leftOffset;
            _vAxis.y = topOffset;
        } else {
            _hAxis.x = leftOffset + vAxisWidth;
            _hAxis.y = _initHeight + topOffset - GraphControls.HEIGHT// - topOffset;
        }

        resizeMarker();
        if (!_ready && !test) {
            createGraphByKey(_yData);
            _container = (GraphHandler.instance.containers[_yData.split("_")[0]][_yData.split("_")[1]] as GraphDataContainer);
            GraphHandler.instance.addListener(this.yData, this);
            _frameSprite.createFrame(w, h);
            this.addChild(_frameSprite);
            _controls = new GraphControls(this);
            _controls.resize(_originWidth, _originHeight, _ready);
            this.addChild(_controls);
        }

        _controls.resize(_originWidth, _originHeight, _ready);

        _frameSprite.setWH(w, h);
        if (!_ready) {
            _zoomHandler.setFullZoomIfNoUserInteraction();
        }
        reDraw(!_ready);
        resizeMarker();
        if (!_ready) setMarkerTimeForActualTime()
        _ready = true;

    }

    private function setMarkerTimeForActualTime():void {
        if (!WindowsHandler.instance.isSocketDatasource()) {
            setMarkerTimeFromTimeline(marker.actualTime, _container.getDataForTimestamp(marker.actualTime))
        }
    }

    public function startResize():void {
        _graph.visible = false;
        _markerLabelBg.visible = false;
        _marker.visible = false;
    }

    public function stopResize():void {
        reDraw();
        _graph.visible = true;
        _markerLabelBg.visible = true;
        setMode();
        if (WindowsHandler.instance.isSocketDatasource()) {
            scrollToEnd();
        }
    }

    protected function resizeMarker():void {
        if (_marker == null) {
            return;
        }
        _marker.maxX = _originWidth;
        _marker.markerHeight = graphHeightWithoutControlls();
        _marker.redrawMarker();
        setMarkerLabelXToMarker();
    }

    internal function markerChangeMaxX():void {
        if (marker == null) {
            return;
        }
        marker.maxX = _graph.possibleMaxWidth;
        marker.calculateActulateX();
        setMarkerLabelXToMarker();
    }

    protected function setMarkerLabelXToMarker():void {
        if (WindowsHandler.instance.isSocketDatasource()) {
            _markerLabelBg.x = _graph.possibleMaxWidth - LABEL_WIDTH;
        } else {
            _markerLabelBg.x = marker.actualMarkerX - LABEL_WIDTH;
        }
    }

    public function reDraw(graphToo:Boolean = true):void {
        _vAxis.reDraw();
        if (graphToo && dataProvider.length > 0) {
            _graph.reDraw();
        } else {
            _graph.calcPossibleMaxWidth();
        }
        _hAxis.reDraw();
    }

    public function clear():void {
        _minMax = {min: 0, max: 100}
        _graph.actualsegmentIndex = 0;
        reDraw();
    }

    internal function scaleGraph():void {
        graph.scaleGraphX()
    }

    internal function zoomRatioChanged():void {
        setControlStates();
    }

    internal function setControlStates():void {
        if (_controls != null) {
            _controls.setZoomLevelLabel(_zoomHandler.getZoomLabelText())
            enableDisableZoomOutBtn();
            enableDisableZoomInBtn();
        }
    }

    protected function enableDisableZoomOutBtn():void {
        if (_zoomHandler.canZoomOut) {
            _controls.enableZoomOutBtn();
        } else {
            _controls.disableZoomoutBtn()
        }
    }

    protected function enableDisableZoomInBtn():void {
        if (_zoomHandler.canZoomIn) {
            _controls.enableZoomInBtn();
        } else {
            _controls.disableZoomInBtn();
        }
    }

    internal function finishZoom():void {
        _graph.finishZoom();
        if (dataProvider.length === 0) {
            _graph.calcPossibleMaxWidth()
        }
        _hAxis.reDraw();
    }


    public function get graph():Graph {
        return _graph;
    }

    public function get bgCanvas():Sprite {
        return _bgCanvas;
    }

    public function get dataProvider():Vector.<GraphData> {
        if (_container == null) {
            return emptyContainer;
        }
        return _container.dataProvider;
    }


    public function get minMax():Object {
        return _minMax;
    }

    public function set minMax(value:Object):void {
        _minMax = value;

    }

    public function get initHeight():int {
        return _initHeight;
    }

    public function get hAxis():Axis {
        return _hAxis;
    }

    public function get initWidth():int {
        return _initWidth;
    }

    public function onOffLoading(type:String):void {
    }


    public function updateDp(loadPrevZoomLevel:Boolean = false):void {
        setMinMaxTime();
        setMinMaxDatas();
        if (WindowsHandler.instance.isSocketDatasource()) {
            setMarkerLabelForLive()
        }
        reDraw();
        setMode();
    }


    public function activateAfterLayoutChange():void {
        setMinMaxTime();
        setMinMaxDatas();
        _zoomHandler.setFullZoomIfNoUserInteraction();
        reDraw();
        setMode();
        setMarkerLabelAndScrollToEndInLiveMode();
    }

    public function setMarkerLabelAndScrollToEndInLiveMode():void {
        if (WindowsHandler.instance.isSocketDatasource()) {
            if (!_isDragging) {
                scrollToEnd();
            }
            setMarkerLabelForLive()
        }
    }

    protected function setMinMaxDatas():void {
        setYMinMax()
        if (GraphHandler.instance.maxTimestamp > 0 && dataProvider.length > 0) {
            _zoomHandler.maxTime = GraphHandler.instance.maxTimestamp;
        }
        if (_marker != null) {
            _marker.maxTime = _zoomHandler.maxTime;
        }
    }

    protected function setMinMaxTime():void {
        if (dataProvider.length > 0) {
            _zoomHandler.setMinMaxTime(GraphHandler.instance.minTimestamp, GraphHandler.instance.maxTimestamp);
        } else {
            if (GraphHandler.instance.minTimestamp == 0 || GraphHandler.instance.maxTimestamp == 0) {
                _zoomHandler.initTime()
            } else {
                _zoomHandler.setMinMaxTime(GraphHandler.instance.minTimestamp, GraphHandler.instance.maxTimestamp);
            }
        }

        if (_marker != null) {
            _marker.minTime = _zoomHandler.minTime;
            _marker.maxTime = _zoomHandler.maxTime;
        }
    }


    public function setFullZoomForLogReplay():void {
        _zoomHandler.setFullZoom();
    }


    public function minTimeChange():void {
        _zoomHandler.minTime = GraphHandler.instance.minTimestamp;
    }


    //LIVE DATA HANDELING
    public function gotNewLiveData():void {
        setMinMaxDatas();
        if (dataProvider.length == 1) {
            setMinMaxTime();
        }
        reDraw();
        // _lastDpIndex++;
        if (!_isDragging) {
            scrollToEnd();
        }
        setMarkerLabelForLive();
    }

    public function updateTimeIfEmpty():void {
        if (dataProvider.length === 0) {
            _zoomHandler.setMinMaxTime(GraphHandler.instance.minTimestamp, GraphHandler.instance.maxTimestamp);

            _graph.calcPossibleMaxWidth();
            _hAxis.reDraw();

        }
    }


    public function unitChanged():void {
        setMinMaxDatas();
        reDraw()
        if (WindowsHandler.instance.isSocketDatasource()) {
            setMarkerLabelForLive()
        } else {
            //TODO refresh markerlabel for reloadData
        }
        setLastTValue();
    }

    protected function setMarkerLabelForLive():void {
        if (dataProvider.length > 0) {
            setLastLabelValue(dataProvider[dataProvider.length - 1].data)
        } else {
            setLastLabelValue(NaN);
        }
        setMarkerLabelXToMarker()
    }


    protected function setLastLabelValue(value:Number):void {
        lastLabelValuePure = value;
        setLastTValue()

    }

    protected function setLastTValue():void {
        if (!isNaN(lastLabelValuePure)) {
            lastTValue = Math.round(_container.yDataTypeContainer.convertNumber(lastLabelValuePure)* 10) / 10 + ""
            if (lastTValue.indexOf(".") === -1) {
                lastTValue += ".0"
            }
        } else {
            lastTValue = "--.-"
        }

        markerLabel.text = lastTValue;

    }

    var minMaxDist:Number = 0;

    public function setYMinMax():void {
        _minMax = {min: _container.minData, max: _container.maxData};
        _minMax = _minMax == null || _minMax.max == null ? {min: 0, max: 10} : _minMax;

        if (_minMax.min < 0) {
            if (Math.abs(_minMax.min) < Math.abs(_minMax.max) && _minMax.max > 0) {
                _minMax.min = _minMax.max * -1;
            } else if (Math.abs(_minMax.min) > Math.abs(_minMax.max) && _minMax.max > 0) {
                _minMax.max = Math.abs(_minMax.min)
            }
        }

        minMaxDist = _minMax.max - _minMax.min // Math.abs(Math.abs(_minMax.min) - Math.abs(_minMax.max));
        if (minMaxDist < 2) {
            if (_minMax.min != 0) {
                _minMax.min -= 1
            } else {
                _minMax.max += 1;
            }
            _minMax.max += 1;
        }

    }


    public function get vAxis():Axis {
        return _vAxis;
    }

    public function set vAxis(value:Axis):void {
        _vAxis = value;
    }


    public function get yData():String {
        return _yData;
    }


    public function set yData(value:String):void {
        _yData = value;
    }

    public function get isDragging():Boolean {
        return _isDragging;
    }

    public function set isDragging(value:Boolean):void {
        _isDragging = value;

        if (value) {
            _controls.setBackToLiveVisible(true);
            putMarkerIntoMiddleLiveMode();
        } else {
            _controls.setBackToLiveVisible(false);
            if (WindowsHandler.instance.isSocketDatasource()) {
                _marker.putMarkerIntoEnd();

            }
        }
    }

    protected function putMarkerIntoMiddleLiveMode():void {
        if (WindowsHandler.instance.isSocketDatasource()) {
            _marker.actualMarkerX = getScrollBoxX() + getScrollBoxWidth() / 2;
            _marker.calculateActualTime();
        }
    }


    public function get graphAndAxis():Sprite {
        return _graphAndAxis;
    }

    protected var markerLabel:TextField;

    protected function initMarker():void {
        if (_marker == null) {
            if (_isHorizontal) {
                _marker = new Marker(0, _initHeight - vAxisWidth, 0xff0000, 1, !_isHorizontal);
                _marker.maxX = _originWidth;
                _marker.y = 0;
            } else {
                _marker = new Marker(0, _initWidth - hAxisHeight, 0xff0000, 1, !_isHorizontal);
                _marker.maxX = _originHeight - vAxisWidth
                _marker.x = 0;
            }
            _marker.putMarkerIntoEnd();
            initMarkerLabel();
        }
        if (!_graphAndAxis.contains(_marker)) {
            _graphAndAxis.addChild(_marker);
            _markerLabelBg.addChild(markerLabel)
            _graphAndAxis.addChild(_markerLabelBg)

        }
    }

    protected function initMarkerLabel():void {
        if (_markerLabelBg == null) {
            _markerLabelBg = new Sprite();
            _markerLabelBg.graphics.beginFill(0xff0000, 0.4);
            _markerLabelBg.graphics.drawRoundRectComplex(0, 0, LABEL_WIDTH, 20, 5, 0, 5, 0);
            _markerLabelBg.graphics.endFill();
        }
        _markerLabelBg.y = _marker.y + 10;
        markerLabel = FontFactory.getCenterGraphLabelTextField();
        markerLabel.width = LABEL_WIDTH;
        markerLabel.alpha = 0.7
        markerLabel.x = LABEL_WIDTH / 2;
    }


    protected function graphAndAxis_mouseWheelHandler(event:MouseEvent):void {
        _zoomStartX = getScrollBoxX() + mouseX - vAxisWidth - leftOffset;
        _zoomStartY = getScrollBoxY() + mouseY - topOffset;
        calcZoomPos();
        if (event.delta > 0) {
            _zoomHandler.zoomIn();
        } else {
            _zoomHandler.zoomOut();
        }

    }

    protected function calcZoomPos():void {
        _zoomStartTime = _marker.getTimeFromPixel(_zoomStartX);
        _prevGraphWidth = _graph.possibleMaxWidth;
    }

    public function scrollToLastZoomTime():void {
        incDecSrollPosition(_marker.getPixelFromTime(_zoomStartTime) - _zoomStartX);
    }

    public function incDecSrollPosition(x:int) {
        if (_graphAndAxis.scrollRect == null) {
            return;
        }
        scrollTo(_graphAndAxis.scrollRect.x + x);
    }


    public function zoomInBtn_clickHandler(event:MouseEvent):void {
        _zoomStartX = getScrollBoxWidth() / 2
        _zoomStartY = getScrollBoxHeight() / 2
        calcZoomPos()
        _zoomHandler.zoomIn()
    }

    public function zoomOutBtn_clickHandler(event:MouseEvent):void {
        _zoomStartX = getScrollBoxWidth() / 2
        _zoomStartY = getScrollBoxHeight() / 2
        calcZoomPos();
        _zoomHandler.zoomOut()
    }

    public function get zoomStartX():int {
        return _zoomStartX;
    }


    public function get container():GraphDataContainer {
        return _container;
    }

    public function removeAllListeners():void {

    }


    public function get originWidth():int {
        return _originWidth;
    }

    public function get originHeight():int {
        return _originHeight;
    }


    internal function get frameSprite():GraphFrame {
        return _frameSprite;
    }

    public function enableDisableDropdownList(value):void {
        _controls.enableYDataList = value;
    }


    public function get controls():GraphControls {
        return _controls;
    }


    public function get zoomHandler():ZoomHandler {
        return _zoomHandler;
    }

    protected function createBgCanvas():void {
        if (_bgCanvas == null) {
            _bgCanvas = new Sprite();
            _bgCanvas.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
            _bgCanvas.addChild(_vAxis)
            this.addChild(graphBg)
            this.addChild(_bgCanvas)
        }
        _bgCanvas.y = 0;
        _bgCanvas.x = 0;
        createBgCanvasColor();
        graphBg.x = vAxisWidth + leftOffset;
        graphBg.y = topOffset;
        graphBg.width = _initWidth - vAxisWidth;
        graphBg.height = _initHeight - GraphControls.HEIGHT;

        _bgCanvas.addEventListener(MouseEvent.MOUSE_WHEEL, graphAndAxis_mouseWheelHandler, false, 0, true);
        if (_graphAndAxis != null) {
            _graphAndAxis.scrollRect = new Rectangle(0, 0, _initWidth - vAxisWidth, _initHeight);
        }
    }

    protected function createBgCanvasColor():void {
        this.graphics.clear();
        this.graphics.beginFill(GraphColors.BORDER_BG_COLOR, 1);
        this.graphics.drawRect(0, 0, _originWidth, _originHeight);
        this.graphics.endFill();
        _bgCanvas.graphics.clear();
        _bgCanvas.graphics.beginFill(0x000000, 0.01);
        _bgCanvas.graphics.drawRect(0, 0, _originWidth, _originHeight);
        _bgCanvas.graphics.endFill();
    }

    protected function createGraphAndAxisView():void {
        _graphAndAxis.x = leftOffset + vAxisWidth;
        _graphAndAxis.y = topOffset;
        _graphAndAxis.graphics.clear();
        _graphAndAxis.graphics.beginFill(0xff00ff, 0.0);
        _graphAndAxis.graphics.drawRect(0, 0, _initWidth - vAxisWidth, _initHeight - hAxisHeight);
        _graphAndAxis.graphics.endFill();
        _graphAndAxis.scrollRect = new Rectangle(0, 0, _initWidth - vAxisWidth - frameSprite.rightFrameWidth - 1, _initHeight + 2);
        _graph.width = _graphAndAxis.scrollRect.width;

//        resizeGraphBg()
//        _graphAndAxis.addChild(graphBg)
        _graphAndAxis.addChild(_graph)
        _graphAndAxis.addChild(_hAxis)
        _bgCanvas.addChild(_graphAndAxis);
    }

//    protected function resizeGraphBg():void {
//        graphBg.width = _initWidth - vAxisWidth;
//        graphBg.height = _initHeight - hAxisHeight;
//    }
}
}
