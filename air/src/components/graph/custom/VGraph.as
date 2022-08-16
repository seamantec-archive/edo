/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.04.
 * Time: 22:14
 * To change this template use File | Settings | File Templates.
 */
package components.graph.custom {
import com.graphs.YData;

import flash.display.GraphicsPathCommand;

public class VGraph extends Graph {
    public function VGraph(graphInstance:GraphInstance, width:int, height:int, ydata:YData) {
        super(graphInstance, width, height, ydata);
    }

    protected override function calculateScales():void {
        minMaxDist = this.graphInstance.hAxis.distance;
        yScaleRatio = this.graphInstance.hAxis.pixelResolution;
        yOffset = this.graphInstance.hAxis.yOffset
    }


    protected override function drawLine():void {
        if (this.graphInstance.dataProvider == null || this.graphInstance.dataProvider.length === 0) {
            return;
        }
        _prevPossibleMaxWidth = _possibleMaxWidth;
        _possibleMaxWidth = 0;

        // establish the fill properties
        var length:int = this.graphInstance.dataProvider.length;
        var prevTimestamp:Number = 0;
        var prevX:int = -1;
        var realPrevX:int = -1;
        var prevY:int = -1;
        var xCoord:int;
        var yCoord:int;
        var prevData:Number = 0;
        var actualSegmentX:int = 0;
        var segmentsTime:Object = {min: Number, max: Number};
        var tempY:int = 0;
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
            yCoord = Math.abs(c.timestamp - graphInstance.zoomHandler.minTime) / graphInstance.zoomHandler.zoomRatio - actualXOffset;
            if (this.graphInstance.minMax.min < 0) {
                xCoord = (this.graphInstance.minMax.max - cData * -1) * yScaleRatio + yOffset
            } else {
                xCoord = (this.graphInstance.minMax.min + cData) * yScaleRatio + yOffset
            }
            if (yCoord / SEGMENT_WIDTH > 1 && i == 0) {
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
                    tempY = squaredDraw(prevData, cData, aSegment, xCoord, yCoord, tempY, realPrevX, prevY);
                } else {
                    tempY = notSquaredDraw(prevData, cData, aSegment, xCoord, yCoord, tempY, prevX, prevY);
                }
            } else {
                notFirstElement = true;
                aSegment.isFirstSegment = true;
                aSegment.pCommands.push(GraphicsPathCommand.MOVE_TO);
                aSegment.nCommands.push(GraphicsPathCommand.MOVE_TO);
                if (cData >= 0) {
                    if (_isAreaGraph) {
                        aSegment.pCommands.push(GraphicsPathCommand.LINE_TO);
                        aSegment.pCoords.push(minDataYCoord)//x
                        aSegment.pCoords.push(yCoord)//y
                    }
                    aSegment.pCoords.push(xCoord)//x
                    aSegment.pCoords.push(yCoord)//y
                    aSegment.nCoords.push(minDataYCoord)//x
                    aSegment.nCoords.push(yCoord)//y
                } else {
                    aSegment.pCoords.push(minDataYCoord)//x
                    aSegment.pCoords.push(yCoord)//y
                    if (_isAreaGraph) {
                        aSegment.nCommands.push(GraphicsPathCommand.LINE_TO);
                        aSegment.nCoords.push(minDataYCoord)//x
                        aSegment.nCoords.push(yCoord)//y
                    }
                    aSegment.nCoords.push(xCoord)//x
                    aSegment.nCoords.push(yCoord)//y
                }

            }
            prevData = cData
            prevX = xCoord;
            realPrevX = xCoord;
            prevY = yCoord;

            if (prevTimestamp == 0) {
                prevTimestamp = c.timestamp;
            }


            segmentsTime.max = c.timestamp;


            if (yCoord >= SEGMENT_WIDTH) {

                counter++;
                prevSegmentW = addSegment(actualSegmentX, segmentsTime);
                //trace('segmentContainerPointer: ' + segmentContainerPointer);
                aSegment = segmentContainer[segmentContainerPointer];
                aSegment.clearCoordsAndCommands()
                actualSegmentX += yCoord//SEGMENT_WIDTH + SEGMENT_WIDTH * counter + xCoord % SEGMENT_WIDTH + 1;
                actualXOffset += yCoord;
                prevX = 0;
                prevY = yCoord;

                if (xCoord >= minDataYCoord) {
                    if (_isAreaGraph) {
                        aSegment.pCommands[0] = GraphicsPathCommand.MOVE_TO;
                        aSegment.pCoords[0] = minDataYCoord//x
                        aSegment.pCoords[1] = 0//y
                        aSegment.pCommands[1] = GraphicsPathCommand.LINE_TO;
                        aSegment.pCoords[2] = xCoord//x
                        aSegment.pCoords[3] = 0;//y
                        (aSegment as AreaGraphSegment).startFromNegative = false;
                        (aSegment as AreaGraphSegment).startFromPositive = true;
                    } else {
                        aSegment.pCommands[0] = GraphicsPathCommand.MOVE_TO;
                        aSegment.pCoords[0] = xCoord//x
                        aSegment.pCoords[1] = 0//y
                    }
                    aSegment.nCommands[0] = GraphicsPathCommand.MOVE_TO;
                    aSegment.nCoords[0] = minDataYCoord//x
                    aSegment.nCoords[1] = 0//y


                } else {
                    aSegment.pCommands[0] = GraphicsPathCommand.MOVE_TO;
                    aSegment.pCoords[0] = xCoord//x
                    aSegment.pCoords[1] = 0//y
                    if (_isAreaGraph) {
                        aSegment.nCommands[0] = GraphicsPathCommand.MOVE_TO;
                        aSegment.nCoords[0] = minDataYCoord//x
                        aSegment.nCoords[1] = 0//y
                        aSegment.nCommands[1] = GraphicsPathCommand.LINE_TO;
                        aSegment.nCoords[2] = xCoord//x
                        aSegment.nCoords[3] = 0;//y
                        (aSegment as AreaGraphSegment).startFromNegative = true;
                        (aSegment as AreaGraphSegment).startFromPositive = false;
                    } else {
                        aSegment.nCommands[0] = GraphicsPathCommand.MOVE_TO;
                        aSegment.nCoords[0] = xCoord//x
                        aSegment.nCoords[1] = 0//y
                    }
                }
                segmentsTime.min = c.timestamp;
            }
        }
        addSegment(actualSegmentX, segmentsTime);
        if (length > 0) {
            _possibleMaxWidth = Math.abs(graphInstance.zoomHandler.timeDistance()) / graphInstance.zoomHandler.zoomRatio;
        }
        if (_possibleMaxWidth < (this.graphInstance.getScrollBoxHeight())) {
            _possibleMaxWidth = (this.graphInstance.getScrollBoxHeight());
        }

    }

    private function notSquaredDraw(prevData:Number, cData:Number, aSegment:GraphSegment, xCoord:int, yCoord:int, tempY:int, prevX:int, prevY:int):int {
        if (prevData >= 0 && cData >= 0) {
            aSegment.pCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.nCommands.push(GraphicsPathCommand.MOVE_TO);
            aSegment.pCoords.push(xCoord)//x
            aSegment.pCoords.push(yCoord)//y
            aSegment.nCoords.push(minDataYCoord)//x
            aSegment.nCoords.push(yCoord)//y
        } else if (prevData < 0 && cData < 0) {
            aSegment.pCommands.push(GraphicsPathCommand.MOVE_TO);
            aSegment.nCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.pCoords.push(minDataYCoord)//x
            aSegment.pCoords.push(yCoord)//y
            aSegment.nCoords.push(xCoord)//x
            aSegment.nCoords.push(yCoord)//y
        } else if (prevData >= 0 && cData < 0) {
            tempY = getYBetweenNegativeAndPositiveNumber(prevX, prevY, xCoord, yCoord, minDataYCoord)
            aSegment.pCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.nCommands.push(GraphicsPathCommand.MOVE_TO);
            aSegment.nCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.pCoords.push(minDataYCoord)//x
            aSegment.pCoords.push(tempY)//y
            aSegment.nCoords.push(minDataYCoord)//x
            aSegment.nCoords.push(tempY)//y
            aSegment.nCoords.push(xCoord)//x
            aSegment.nCoords.push(yCoord)//y
        } else if (prevData < 0 && cData >= 0) {
            tempY = getYBetweenNegativeAndPositiveNumber(prevX, prevY, xCoord, yCoord, minDataYCoord)
            aSegment.pCommands.push(GraphicsPathCommand.MOVE_TO);
            aSegment.pCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.nCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.pCoords.push(minDataYCoord)//x
            aSegment.pCoords.push(tempY)//y
            aSegment.pCoords.push(xCoord)//x
            aSegment.pCoords.push(yCoord)//y
            aSegment.nCoords.push(minDataYCoord)//x
            aSegment.nCoords.push(tempY)//y
        }
        return tempY;
    }

    private function squaredDraw(prevData:Number, cData:Number, aSegment:GraphSegment, xCoord:int, yCoord:int, tempY:int, prevX:int, prevY:int):int {
        if (prevData >= 0 && cData >= 0) {
            aSegment.pCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.pCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.nCommands.push(GraphicsPathCommand.MOVE_TO);
            aSegment.pCoords.push(prevX)//x
            aSegment.pCoords.push(yCoord)//y
            aSegment.pCoords.push(xCoord)//x
            aSegment.pCoords.push(yCoord)//y
            aSegment.nCoords.push(minDataYCoord)//x
            aSegment.nCoords.push(yCoord)//y
        } else if (prevData < 0 && cData < 0) {
            aSegment.pCommands.push(GraphicsPathCommand.MOVE_TO);
            aSegment.nCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.nCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.pCoords.push(minDataYCoord)//x
            aSegment.pCoords.push(yCoord)//y
            aSegment.nCoords.push(prevX)//x
            aSegment.nCoords.push(yCoord)//y
            aSegment.nCoords.push(xCoord)//x
            aSegment.nCoords.push(yCoord)//y
        } else if (prevData >= 0 && cData < 0) {
            aSegment.pCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.pCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.nCommands.push(GraphicsPathCommand.MOVE_TO);
            aSegment.nCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.pCoords.push(prevX)//x
            aSegment.pCoords.push(yCoord)//y
            aSegment.pCoords.push(minDataYCoord)//x
            aSegment.pCoords.push(yCoord)//y
            aSegment.nCoords.push(minDataYCoord)//x
            aSegment.nCoords.push(yCoord)//y
            aSegment.nCoords.push(xCoord)//x
            aSegment.nCoords.push(yCoord)//y
        } else if (prevData < 0 && cData >= 0) {
            aSegment.nCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.nCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.pCommands.push(GraphicsPathCommand.MOVE_TO);
            aSegment.pCommands.push(GraphicsPathCommand.LINE_TO);
            aSegment.nCoords.push(prevX)//x
            aSegment.nCoords.push(yCoord)//y
            aSegment.nCoords.push(minDataYCoord)//x
            aSegment.nCoords.push(yCoord)//y
            aSegment.pCoords.push(minDataYCoord)//x
            aSegment.pCoords.push(yCoord)//y
            aSegment.pCoords.push(xCoord)//x
            aSegment.pCoords.push(yCoord)//y

        }
        return tempY;
    }


    protected function getYBetweenNegativeAndPositiveNumber(x1:int, y1:int, x2:int, y2:int, xZero:int):int {
        var phi = Math.atan2(x2 - x1, y2 - y1);
        if (phi === 0 || Math.round(phi * 100) / 100 === 3.14 || Math.round(Math.tan(phi) * 10) / 10 === 0) {
            return y2
        }
        return ((xZero - x1) / Math.tan(phi)) + y1;
    }

    public override function calcPossibleMaxWidth():void {
        _possibleMaxWidth = Math.abs(graphInstance.zoomHandler.timeDistance()) / graphInstance.zoomHandler.zoomRatio;

        if (_possibleMaxWidth < (this.graphInstance.getScrollBoxHeight())) {
            _possibleMaxWidth = (this.graphInstance.getScrollBoxHeight());
        }
    }


    protected override function addSegment(actualSegmentX:int, sT:Object):int {
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
        segment.sprite.y = actualSegmentX;
        return  segment.sprite.height;
    }

    public override function finishZoom():void {
        reDraw();
    }
}
}
