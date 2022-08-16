/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.25.
 * Time: 15:33
 * To change this template use File | Settings | File Templates.
 */
package components.graph.custom {

import com.graphs.YData;
import com.sailing.WindowsHandler;

import flash.display.GraphicsPathCommand;
import flash.display.Sprite;
import flash.events.Event;

public class Graph extends Sprite {
    public static const SEGMENT_WIDTH:int = 2048;
    protected var graphInstance:GraphInstance;
    protected var _possibleMaxWidth:int = 0;
    protected var _prevPossibleMaxWidth:int = _possibleMaxWidth;
    protected var yScaleRatio:Number;
//    protected var _zoomRatio:Number = -1;
//    protected var _minZoomLevel:Number;
    protected var minMaxDist:Number;
    protected var yOffset:int;
    protected var graphSegments:Vector.<GraphSegment> = new <GraphSegment>[];
    protected var _actualsegmentIndex:int = 0;
    protected var segmentContainer:Vector.<GraphSegment> = new <GraphSegment>[];
    protected var segmentContainerPointer:int = 0;
    protected var tempWidth:int = 0;
    protected var actualXOffset = 0;
    protected var length:int
    protected var _isAreaGraph:Boolean = false;
    protected var _ydata:YData;

    public function Graph(graphInstance:GraphInstance, width:int, height:int, ydata:YData) {
        super();

        drawBg(width, height);
        this.graphInstance = graphInstance;
        this.graphInstance.addEventListener(Event.RESIZE, resizeHandler, false, 0, true);
        this.y = 0;
        this._ydata = ydata;

        initSegmentsContainer();
    }

    private function drawBg(w:int, h:int):void {
        this.graphics.clear();
        this.graphics.beginFill(0x00ff00, 0)
        this.graphics.drawRect(0, 0, w, h)
        this.graphics.endFill();
    }

    protected function initSegmentsContainer():void {
        segmentContainer.push(new LineGraphSegment(_ydata));
        segmentContainerPointer = 0;
    }

    public function reset():void {
        _possibleMaxWidth = 0;
        segmentContainerPointer = 0;
        graphSegments.length = 0;
        graphics.clear();
        if (numChildren > 0) {
            this.removeChildren(0, numChildren - 1);
        }
        clearSegmentContainer();
    }


    protected function calculateScales():void {
        minMaxDist = this.graphInstance.vAxis.distance;
        yScaleRatio = this.graphInstance.vAxis.pixelResolution;
        yOffset = this.graphInstance.vAxis.yOffset
    }

    public function redrawFrom() {
        reDraw();
    }

    protected var minDataYCoord:int = 0;

    protected function drawLine():void {
        if (this.graphInstance.dataProvider == null || this.graphInstance.dataProvider.length === 0) {
            return;
        }
        _prevPossibleMaxWidth = _possibleMaxWidth;
        _possibleMaxWidth = 0;

        // establish the fill properties
        var length:int = this.graphInstance.dataProvider.length;
        var prevTimestamp:Number = 0;
        var prevX:int = -1;
        var prevY:int = -1;
        var xCoord:int;
        var yCoord:int;
        var prevData:Number = 0;
        var actualSegmentX:int = 0;
        var segmentsTime:Object = {min: Number, max: Number};
        var tempX:int = 0;
        graphics.clear();
        if (numChildren > 0) {
            this.removeChildren(0, numChildren - 1);
        }
        graphSegments.length = 0;
        segmentContainerPointer = 0;
        actualXOffset = 0;
        graphics.lineStyle(2, 0xff0000, 1);//set the color
        var c:Object;
        var counter:int = 0;
        var aSegment:GraphSegment = segmentContainer[segmentContainerPointer];
        aSegment.clearCoordsAndCommands();
        segmentsTime.min = graphInstance.dataProvider[0].timestamp;
        var coordsLength:int;
        var interpolatedObject:Object;
        var wasInterpolateP:Boolean = false;
        var wasInterpolateN:Boolean = false;
        var notFirstElement:Boolean = false;
        var prevSegmentW:int = 0;
        var cData:Number;
        if (_ydata.graphType != YData.DEPTH_GRAPH) {
            minDataYCoord = (this.graphInstance.minMax.max - 0) * yScaleRatio + yOffset;
        } else {
            minDataYCoord = 0;
        }
        for (var i:int = 0; i < length; i++) {
            c = this.graphInstance.dataProvider[i];
            if (c.timestamp < graphInstance.zoomHandler.minTime) {
                this.graphInstance.dataProvider.splice(i, 1);
                length--;
                continue;
            }
            cData = this.graphInstance.container.yDataTypeContainer.convertNumber(c.data);
            if (cData < this.graphInstance.minMax.min || cData > this.graphInstance.minMax.max) {
                continue;
            }
            xCoord = Math.abs(c.timestamp - graphInstance.zoomHandler.minTime) / graphInstance.zoomHandler.zoomRatio - actualXOffset;

            if (_ydata.graphType != YData.DEPTH_GRAPH) {
                yCoord = (this.graphInstance.minMax.max - cData) * yScaleRatio + yOffset
            } else {
                yCoord = (this.graphInstance.minMax.min + cData) * yScaleRatio + yOffset
            }
            if (xCoord / SEGMENT_WIDTH > 1 && i == 0) {
                counter++;
                actualSegmentX = SEGMENT_WIDTH * counter;
                actualXOffset = SEGMENT_WIDTH * counter;
                i--;
                continue;
            }
            if (xCoord == prevX && yCoord == prevY) {
                continue;
            }


            if (notFirstElement) {
                if (_ydata.squaredDraw) {
                    tempX = squaredDraw(prevData, cData, aSegment, xCoord, yCoord, tempX, prevX, prevY);
                } else {
                    tempX = notSquaredDraw(prevData, cData, aSegment, xCoord, yCoord, tempX, prevX, prevY);
                }
            } else {
                notFirstElement = true;
                aSegment.isFirstSegment = true;
                aSegment.pCommands.push(GraphicsPathCommand.MOVE_TO);
                aSegment.nCommands.push(GraphicsPathCommand.MOVE_TO);
                if (cData >= 0) {
                    if (_isAreaGraph) {
                        aSegment.pCommands.push(GraphicsPathCommand.LINE_TO);
                        aSegment.pCoords.push(xCoord)//x
                        aSegment.pCoords.push(minDataYCoord)//y
                    }
                    aSegment.pCoords.push(xCoord)//x
                    aSegment.pCoords.push(yCoord)//y
                    aSegment.nCoords.push(xCoord)//x
                    aSegment.nCoords.push(minDataYCoord)//y
                } else {
                    aSegment.pCoords.push(xCoord)//x
                    aSegment.pCoords.push(minDataYCoord)//y
                    if (_isAreaGraph) {
                        aSegment.nCommands.push(GraphicsPathCommand.LINE_TO);
                        aSegment.nCoords.push(xCoord)//x
                        aSegment.nCoords.push(minDataYCoord)//y
                    }
                    aSegment.nCoords.push(xCoord)//x
                    aSegment.nCoords.push(yCoord)//y
                }

            }
            prevData = cData
            prevX = xCoord;
            prevY = yCoord;

            if (prevTimestamp == 0) {
                prevTimestamp = c.timestamp;
            }


            segmentsTime.max = c.timestamp;


            if (xCoord >= SEGMENT_WIDTH) {

                counter++;
                prevSegmentW = addSegment(actualSegmentX, segmentsTime);
                //trace('segmentContainerPointer: ' + segmentContainerPointer);
                aSegment = segmentContainer[segmentContainerPointer];
                aSegment.clearCoordsAndCommands()
                actualSegmentX += xCoord//SEGMENT_WIDTH + SEGMENT_WIDTH * counter + xCoord % SEGMENT_WIDTH + 1;
                actualXOffset += xCoord;
                prevX = 0;
                prevY = yCoord;

                if (yCoord <= minDataYCoord || _ydata.graphType == YData.DEPTH_GRAPH) {
                    if (_isAreaGraph) {
                        aSegment.pCommands[0] = GraphicsPathCommand.MOVE_TO;
                        aSegment.pCoords[0] = 0//x
                        aSegment.pCoords[1] = minDataYCoord//y
                        aSegment.pCommands[1] = GraphicsPathCommand.LINE_TO;
                        aSegment.pCoords[2] = 0//x
                        aSegment.pCoords[3] = yCoord;//y
                        (aSegment as AreaGraphSegment).startFromNegative = false;
                        (aSegment as AreaGraphSegment).startFromPositive = true;
                    } else {
                        aSegment.pCommands[0] = GraphicsPathCommand.MOVE_TO;
                        aSegment.pCoords[0] = 0//x
                        aSegment.pCoords[1] = yCoord//y
                    }
                    aSegment.nCommands[0] = GraphicsPathCommand.MOVE_TO;
                    aSegment.nCoords[0] = 0//x
                    aSegment.nCoords[1] = minDataYCoord//y


                } else {
                    aSegment.pCommands[0] = GraphicsPathCommand.MOVE_TO;
                    aSegment.pCoords[0] = 0//x
                    aSegment.pCoords[1] = minDataYCoord//y
                    if (_isAreaGraph) {
                        aSegment.nCommands[0] = GraphicsPathCommand.MOVE_TO;
                        aSegment.nCoords[0] = 0//x
                        aSegment.nCoords[1] = minDataYCoord//y
                        aSegment.nCommands[1] = GraphicsPathCommand.LINE_TO;
                        aSegment.nCoords[2] = 0//x
                        aSegment.nCoords[3] = yCoord;//y
                        (aSegment as AreaGraphSegment).startFromNegative = true;
                        (aSegment as AreaGraphSegment).startFromPositive = false;
                    } else {
                        aSegment.nCommands[0] = GraphicsPathCommand.MOVE_TO;
                        aSegment.nCoords[0] = 0//x
                        aSegment.nCoords[1] = yCoord//y
                    }
                }
                segmentsTime.min = c.timestamp;
            }
        }
        addSegment(actualSegmentX, segmentsTime);
        if (length > 0) {
            _possibleMaxWidth = Math.abs(graphInstance.zoomHandler.maxTime - graphInstance.zoomHandler.minTime) / graphInstance.zoomHandler.zoomRatio;
        }
        if (_possibleMaxWidth < (this.graphInstance.initWidth - GraphInstance.vAxisWidth)) {
            _possibleMaxWidth = (this.graphInstance.initWidth - GraphInstance.vAxisWidth);
        }

    }

    private function notSquaredDraw(prevData:Number, cData:Number, aSegment:GraphSegment, xCoord:int, yCoord:int, tempX:int, prevX:int, prevY:int):int {
        if (prevData >= 0 && cData >= 0) {
            aSegment.pCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.nCommands.push(GraphicsPathCommand.MOVE_TO);
            aSegment.pCoords.push(xCoord)//x
            aSegment.pCoords.push(yCoord)//y
            aSegment.nCoords.push(xCoord)//x
            aSegment.nCoords.push(minDataYCoord)//y
        } else if (prevData < 0 && cData < 0) {
            aSegment.pCommands.push(GraphicsPathCommand.MOVE_TO);
            aSegment.nCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.pCoords.push(xCoord)//x
            aSegment.pCoords.push(minDataYCoord)//y
            aSegment.nCoords.push(xCoord)//x
            aSegment.nCoords.push(yCoord)//y
        } else if (prevData >= 0 && cData < 0) {
            tempX = getXBetweenNegativeAndPositiveNumber(prevX, prevY, xCoord, yCoord, minDataYCoord)
            aSegment.pCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.nCommands.push(GraphicsPathCommand.MOVE_TO);
            aSegment.nCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.pCoords.push(tempX)//x
            aSegment.pCoords.push(minDataYCoord)//y
            aSegment.nCoords.push(tempX)//x
            aSegment.nCoords.push(minDataYCoord)//y
            aSegment.nCoords.push(xCoord)//x
            aSegment.nCoords.push(yCoord)//y
        } else if (prevData < 0 && cData >= 0) {
            tempX = getXBetweenNegativeAndPositiveNumber(prevX, prevY, xCoord, yCoord, minDataYCoord)
            aSegment.pCommands.push(GraphicsPathCommand.MOVE_TO);
            aSegment.pCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.nCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.pCoords.push(tempX)//x
            aSegment.pCoords.push(minDataYCoord)//y
            aSegment.pCoords.push(xCoord)//x
            aSegment.pCoords.push(yCoord)//y
            aSegment.nCoords.push(tempX)//x
            aSegment.nCoords.push(minDataYCoord)//y
        }
        return tempX;
    }

    private function squaredDraw(prevData:Number, cData:Number, aSegment:GraphSegment, xCoord:int, yCoord:int, tempX:int, prevX:int, prevY:int):int {
        if (prevData >= 0 && cData >= 0) {
            aSegment.pCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.pCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.nCommands.push(GraphicsPathCommand.MOVE_TO);
            aSegment.pCoords.push(xCoord)//x
            aSegment.pCoords.push(prevY)//y
            aSegment.pCoords.push(xCoord)//x
            aSegment.pCoords.push(yCoord)//y
            aSegment.nCoords.push(xCoord)//x
            aSegment.nCoords.push(minDataYCoord)//y
        } else if (prevData < 0 && cData < 0) {
            aSegment.pCommands.push(GraphicsPathCommand.MOVE_TO);
            aSegment.nCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.nCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.pCoords.push(xCoord)//x
            aSegment.pCoords.push(minDataYCoord)//y
            aSegment.nCoords.push(xCoord)//x
            aSegment.nCoords.push(prevY)//y
            aSegment.nCoords.push(xCoord)//x
            aSegment.nCoords.push(yCoord)//y
        } else if (prevData >= 0 && cData < 0) {
            aSegment.pCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.pCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.nCommands.push(GraphicsPathCommand.MOVE_TO);
            aSegment.nCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.pCoords.push(xCoord)//x
            aSegment.pCoords.push(prevY)//y
            aSegment.pCoords.push(xCoord)//x
            aSegment.pCoords.push(minDataYCoord)//y
            aSegment.nCoords.push(xCoord)//x
            aSegment.nCoords.push(minDataYCoord)//y
            aSegment.nCoords.push(xCoord)//x
            aSegment.nCoords.push(yCoord)//y
        } else if (prevData < 0 && cData >= 0) {
            aSegment.nCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.nCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.pCommands.push(GraphicsPathCommand.MOVE_TO);
            aSegment.pCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.nCoords.push(xCoord)//x
            aSegment.nCoords.push(prevY)//y
            aSegment.nCoords.push(xCoord)//x
            aSegment.nCoords.push(minDataYCoord)//y
            aSegment.pCoords.push(xCoord)//x
            aSegment.pCoords.push(minDataYCoord)//y
            aSegment.pCoords.push(xCoord)//x
            aSegment.pCoords.push(yCoord)//y
        }
        return tempX;
    }


    protected function addSegment(actualSegmentX:int, sT:Object):int {
        var segment:GraphSegment = segmentContainer[segmentContainerPointer];
        segmentContainerPointer++;
        if (segmentContainer.length == segmentContainerPointer)  segmentContainer.push(new LineGraphSegment(_ydata));
        segment.rendered = false;
        segment.sprite.visible = true;
        segment.minTime = sT.min;
        segment.maxTime = sT.max;
        segment.minValue = this.graphInstance.minMax.min;
        segment.render();
        graphSegments.push(segment);
        if (!this.contains(segment.sprite)) {
            this.addChild(segment.sprite);
        }
        segment.sprite.x = actualSegmentX;
        return  segment.sprite.width;
    }

    protected function getXBetweenNegativeAndPositiveNumber(x1:int, y1:int, x2:int, y2:int, yZero:int):int {
        var phi = Math.atan2(y2 - y1, x2 - x1);
        if (phi === 0) {
            return x2
        }
        return ((yZero - y1) / Math.sin(phi)) * Math.cos(phi) + x1;
    }

    protected function interpolateBetweenSegments(x1:int, y1:int, x2:int, y2:int):Object {
        var xDist = x2 - x1;
        var phi = Math.atan2(y2 - y1, xDist);
        var rObject:Object = {}
        if (x2 > SEGMENT_WIDTH) {
            var nSegments = Math.floor(xDist / SEGMENT_WIDTH);
            var left = 0;
            var r = 0;
            var y = y1;
            if (nSegments >= 1) {
                var r = SEGMENT_WIDTH / Math.cos(phi);
                var partY = r * Math.sin(phi)
                left = xDist - SEGMENT_WIDTH * nSegments
                var xx = x1
                //elso tort segmens
                if (x1 != 0) {
                    var r1 = (SEGMENT_WIDTH - x1) / Math.cos(phi);
                    y += r1 * Math.sin(phi);
                    rObject["firstY"] = y;
                    rObject["firstX"] = SEGMENT_WIDTH;

                }
                //egesz szegmensek
                for (var i = 0; i < nSegments; i++) {
                    //TODO create segment moveTo 0,y, line to
                    y += partY;
                    //TODO lineTo SEGMENT_WIDTH, y
                    xx = SEGMENT_WIDTH;
                    if (y > y2) {
                        break;
                    }
                }
                //maradek szegmensbe kiiras
                xx = x2 - SEGMENT_WIDTH * nSegments;
                if (xx % SEGMENT_WIDTH != 0) {
                    y = y2;
                    if (xx > SEGMENT_WIDTH) { //ha volt elotort szegmens is, meg uto is van
                        xx -= SEGMENT_WIDTH;
                    }
                    rObject["lastY"] = y;
                    rObject["lastX"] = xx;
                }
            } else {
                //nincs egesz szegmens csak tort
                rObject["firstY"] = ((SEGMENT_WIDTH - x1) / Math.cos(phi)) * Math.sin(phi) + y1;
                rObject["firstX"] = SEGMENT_WIDTH;
                rObject["lastY"] = y2;
                rObject["lastX"] = x2 - SEGMENT_WIDTH;
            }
        }
        return rObject;
    }


    protected function resizeHandler(event:Event):void {
        reDraw()
    }


    public function reDraw():void {
        this.scaleX = 1;
        this.scaleY = 1;
        calculateScales();
        drawLine();
        markerChangeMaxX();
    }

    public function calcPossibleMaxWidth():void {
        _possibleMaxWidth = Math.abs(graphInstance.zoomHandler.timeDistance()) / graphInstance.zoomHandler.zoomRatio;

        if (_possibleMaxWidth < (this.graphInstance.initWidth - GraphInstance.vAxisWidth)) {
            _possibleMaxWidth = (this.graphInstance.initWidth - GraphInstance.vAxisWidth);
        }
    }

    protected function markerChangeMaxX():void {
        graphInstance.markerChangeMaxX();
    }


    public function scaleGraphX():void {
        tempWidth = graphInstance.zoomHandler.timeDistance() / graphInstance.zoomHandler.zoomRatio;
        if (tempWidth != _possibleMaxWidth && possibleMaxWidth > 0) {
            var scale:Number = tempWidth / possibleMaxWidth;

            var prefMarkerX:int = graphInstance.marker.actualMarkerX;
            this.scaleX *= scale
            _possibleMaxWidth = tempWidth;
            markerChangeMaxX();
            graphInstance.hAxis.reDraw();
            if (WindowsHandler.instance.isSocketDatasource()) {
                if (graphInstance.isDragging) {
                    //zoom to mouse
                    graphInstance.scrollToLastZoomTime()
                } else {
                    //zoom in the end when live mode and not dragging
                    graphInstance.marker.putMarkerIntoEnd();
                    graphInstance.scrollTo(_possibleMaxWidth - graphInstance.getScrollBoxWidth());
                }
            } else {
                graphInstance.scrollToLastZoomTime()
            }
        }
    }

    public function scaleGraphY():void {
        tempWidth = graphInstance.zoomHandler.timeDistance() / graphInstance.zoomHandler.zoomRatio;
        if (tempWidth != _possibleMaxWidth && possibleMaxWidth > 0) {
            var scale:Number = tempWidth / possibleMaxWidth;
            if (scale == Infinity) {
                return;
            }
            this.scaleY *= scale
            _possibleMaxWidth = tempWidth;
            markerChangeMaxX();
            graphInstance.vAxis.reDraw();
            if (WindowsHandler.instance.isSocketDatasource()) {
                if (graphInstance.isDragging) {
                    //zoom to mouse
                    graphInstance.scrollToLastZoomTime()
                } else {
                    //zoom in the end when live mode and not dragging
                    graphInstance.marker.putMarkerIntoEnd();
                    graphInstance.scrollTo(_possibleMaxWidth - graphInstance.getScrollBoxHeight());
                }
            } else {
                graphInstance.scrollToLastZoomTime()
            }
        }
    }

    public function finishZoom():void {
        reDraw();
    }

    public function get possibleMaxWidth():int {
        return _possibleMaxWidth;
    }

    public function get actualsegmentIndex():int {
        return _actualsegmentIndex;
    }

    public function set actualsegmentIndex(value:int):void {
        _actualsegmentIndex = value;
    }

    public function clearSegmentContainer():void {
        for (var i:int = segmentContainer.length - 1; i >= 0; i--) {
            segmentContainer[i].deAlloc();
            segmentContainer[i] = null;
        }
        segmentContainer.length = 0;
        segmentContainerPointer = 0;
        initSegmentsContainer();
    }
}
}
