/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.04.
 * Time: 22:05
 * To change this template use File | Settings | File Templates.
 */
package components.graph.custom {
import com.graphs.GraphHandler;
import com.graphs.YData;
import com.graphs.YDatas;
import com.sailing.WindowsHandler;
import com.utils.FontFactory;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

public class VGraphInstance extends GraphInstance {
    public function VGraphInstance(yData:String, bgColor:uint = 0xffffff, test:Boolean = false) {
        super(yData, bgColor, test);
        _isHorizontal = false;
        _vAxis = new VTimeAxis(_zoomHandler.minTime, _zoomHandler.maxTime, this)
        _hAxis = new HDataAxis(_minMax.min, _minMax.max, this);
        _vAxis.x = 0;
        _vAxis.y = 0;
        createGraphByKey(_yData);

    }


    protected override function createGraphByKey(key:String):void {
        if (_hAxis === null) {
            return;
        }
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
                if (_hAxis != null)_hAxis.topZero = false;
                _graph = new VGraph(this, this._initWidth - vAxisWidth, _initHeight - hAxisHeight, ydata);
                break;
            case YData.AREA_GRAPH:
                if (_hAxis != null) _hAxis.topZero = false;
                _graph = new VAreaGraph(this, this._initWidth - vAxisWidth, _initHeight - hAxisHeight, ydata);
                break;
            case YData.DEPTH_GRAPH:
                if (_hAxis != null)_hAxis.topZero = false;
                _graph = new VAreaGraph(this, this._initWidth - vAxisWidth, _initHeight - hAxisHeight, ydata);
                break;
        }

        if (_hAxis != null) _hAxis.quantalStep = ydata.quantalZoom;
        if (_bgCanvas != null) {
            _bgCanvas.setChildIndex(_hAxis, 1)
//            setChildIndex(_graphShadowS, 1)
        }
        if (_graphAndAxis != null) {
            _graph.x = vAxisWidth;
            _graph.y = 0;
            _graphAndAxis.addChild(_graph)
            if (_marker != null && _graphAndAxis.contains(_marker) && _graphAndAxis.contains(_vAxis) && _graphAndAxis.contains(_graph)) {
                _graphAndAxis.setChildIndex(_graph, 1)
                _graphAndAxis.setChildIndex(_vAxis, 0)
                _graphAndAxis.setChildIndex(_marker, 2)
                _graphAndAxis.setChildIndex(_markerLabelBg, 3)
            }

        }
    }

    protected override function createBgCanvas():void {
        if (_bgCanvas == null) {
            _bgCanvas = new Sprite();
            _bgCanvas.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
//            _bgCanvas.addChild(graphBg)
            _bgCanvas.addChild(_hAxis)
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
        _hAxis.x = vAxisWidth;
        _hAxis.y = _initHeight - GraphControls.HEIGHT;
        _bgCanvas.addEventListener(MouseEvent.MOUSE_WHEEL, graphAndAxis_mouseWheelHandler, false, 0, true);
        if (_graphAndAxis != null) {
            _graphAndAxis.scrollRect = new Rectangle(0, 0, _initWidth, _initHeight - hAxisHeight);

        }
    }

    public override function graphHeightWithoutControlls():int {
        return _initHeight //- controlsHeight
    }

    protected override function createGraphAndAxisView():void {
        _graphAndAxis.x = leftOffset;
        _graphAndAxis.y = topOffset;
        _graphAndAxis.graphics.clear();
        _graphAndAxis.graphics.beginFill(0x0000ff, 0);
        _graphAndAxis.graphics.drawRect(0, 0, _initWidth, _initHeight - hAxisHeight);
        _graphAndAxis.graphics.endFill();
        _graphAndAxis.scrollRect = new Rectangle(0, 0, _initWidth, _initHeight - hAxisHeight-1);
        _graph.x = vAxisWidth;
        _graphAndAxis.addChild(_graph)
        _graphAndAxis.addChild(_vAxis)
        _bgCanvas.addChild(_graphAndAxis);
    }

    public override function reDraw(graphToo:Boolean = true):void {
        _hAxis.reDraw();
        if (graphToo && dataProvider.length > 0) {
            _graph.reDraw();
        } else {
            _graph.calcPossibleMaxWidth();
        }
        _vAxis.reDraw();

    }


    override public function resetGraph(needUpdateDp:Boolean = true):void {
        scrollBox(-_graphAndAxis.scrollRect.y);
        commonReset(needUpdateDp);
    }

    protected override function scrollBox(dy:Number):void {
        scrollTo(getScrollBoxY() + dy);
    }

    public override function scrollTo(y:int):void {
        if (_graphAndAxis.scrollRect == null || _graph.possibleMaxWidth === 0) {
            return;
        }
        var rect:Rectangle = _graphAndAxis.scrollRect;

        rect.y = y;
        if (rect.y < 0) {
            rect.y = 0;
        } else if ((rect.y + rect.height) > _graph.possibleMaxWidth) {
            rect.y = _graph.possibleMaxWidth - rect.height
            if (WindowsHandler.instance.isSocketDatasource()) {
                isDragging = false;
                scrollToEnd();
            }
        }
        _graphAndAxis.scrollRect = rect;
    }

    protected override function scrollToEnd():void {
        if (_graphAndAxis.scrollRect == null) {
            return;
        }
        scrollTo(_graph.possibleMaxWidth - _graphAndAxis.scrollRect.height)
    }

    protected override function scrollToMarker():void {
        scrollTo(_marker.actualMarkerX + getScrollBoxHeight() / 2);
    }


    protected override function mouseMoveHandler(event:MouseEvent):void {
        if (WindowsHandler.instance.isSocketDatasource()) {
            isDragging = true;
        }
        var currDataPoint:Point = new Point(event.stageX, event.stageY);
        var dy:Number = dragStartDataPoint.y - currDataPoint.y;
        scrollBox(dy);
        dragStartDataPoint = new Point(event.stageX, event.stageY);
        putMarkerIntoMiddleLiveMode();
    }

    protected override function putMarkerIntoMiddleLiveMode():void {
        if (WindowsHandler.instance.isSocketDatasource()) {
            _marker.actualMarkerX = getScrollBoxY() + getScrollBoxHeight() / 2;
            _marker.calculateActualTime();
        }
    }


    protected override function mouseUpHandler(event:MouseEvent):void {
        _bgCanvas.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
        _bgCanvas.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
        stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
        mouseIsDown = false;
        if (WindowsHandler.instance.isSocketDatasource() && getScrollBoxEndY() === 0 && getScrollBoxEndY() === _graph.possibleMaxWidth) {
            isDragging = false;
        }
    }


    public override function incDecSrollPosition(y:int) {
        if (_graphAndAxis.scrollRect == null) {
            return;
        }
        scrollTo(_graphAndAxis.scrollRect.y + y);
    }

    public override function scrollToLastZoomTime():void {
        incDecSrollPosition(_marker.getPixelFromTime(_zoomStartTime) - _zoomStartY);
    }


    protected override function calcZoomPos():void {
        _zoomStartTime = _marker.getTimeFromPixel(_zoomStartY);
        _prevGraphWidth = _graph.possibleMaxWidth;
    }

    protected override function stepStageMarkerTime():void {
        //Step into right
        if (Math.floor(_marker.actualMarkerX) > getScrollBoxEndY()) {
            scrollTo(_marker.actualMarkerX);
        } else if (_marker.actualMarkerX < getScrollBoxY()) {
            scrollTo(_marker.actualMarkerX - getScrollBoxHeight()); //hack
        }
    }


    protected override function resizeMarker():void {
        if (_marker == null) {
            return;
        }
        _marker.maxX = _originHeight - vAxisWidth;
        _marker.markerHeight = getScrollBoxWidth();
        _marker.redrawMarker();
        setMarkerLabelX();
    }

    private function setMarkerLabelX():void {
        _markerLabelBg.x = _originWidth - LABEL_WIDTH - rightOffset - frameSprite.rightFrameWidth - 10//- LABEL_WIDTH _originWidth - ;
    }

    protected override function setMarkerLabelXToMarker():void {
        if (WindowsHandler.instance.isSocketDatasource()) {
            _markerLabelBg.y = _graph.possibleMaxWidth > 0 ? _graph.possibleMaxWidth - 20 : getScrollBoxHeight() - 20;
        } else {
            _markerLabelBg.y = marker.actualMarkerX - 20;
        }
    }

    protected override function initMarkerLabel():void {
        if (_markerLabelBg == null) {
            _markerLabelBg = new Sprite();
            _markerLabelBg.graphics.beginFill(0xff0000, 0.4);
            _markerLabelBg.graphics.drawRoundRectComplex(0, 0, LABEL_WIDTH, 20, 5, 5, 0, 0);
            _markerLabelBg.graphics.endFill();
        }
        setMarkerLabelX();
        markerLabel = FontFactory.getCenterGraphLabelTextField();
        markerLabel.width = LABEL_WIDTH;
        markerLabel.alpha = 0.7
        markerLabel.x = LABEL_WIDTH / 2;
    }

    internal override function scaleGraph():void {
        graph.scaleGraphY()
    }


    override internal function finishZoom():void {
        _graph.finishZoom();
        if (dataProvider.length === 0) {
            _graph.calcPossibleMaxWidth()
        }
        _vAxis.reDraw();
    }

    override public function updateTimeIfEmpty():void {
        if (dataProvider.length === 0) {
            _zoomHandler.setMinMaxTime(GraphHandler.instance.minTimestamp, GraphHandler.instance.maxTimestamp);

            _graph.calcPossibleMaxWidth();
            _vAxis.reDraw();

        }
    }
}
}
