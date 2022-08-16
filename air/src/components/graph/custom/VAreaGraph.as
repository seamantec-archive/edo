/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.05.
 * Time: 18:47
 * To change this template use File | Settings | File Templates.
 */
package components.graph.custom {
import com.graphs.YData;

import flash.display.GraphicsPathCommand;

public class VAreaGraph extends VGraph {
    public function VAreaGraph(graphInstance:GraphInstance, width:int, height:int, ydata:YData) {
        super(graphInstance, width, height, ydata);
        _isAreaGraph = true;
    }

    protected override function initSegmentsContainer():void {
//        for (var i:int = 0; i < 40; i++) {
        segmentContainer.push(new AreaGraphSegment(_ydata));
        segmentContainerPointer = 0
//        }
    }

    protected override function addSegment(actualSegmentX:int, sT:Object):int {
        var segment:AreaGraphSegment = segmentContainer[segmentContainerPointer] as AreaGraphSegment;
        segmentContainerPointer++;
        if (segmentContainer.length == segmentContainerPointer)  segmentContainer.push(new AreaGraphSegment(_ydata));
        segment.rendered = false;
        segment.sprite.visible = true;
        segment.minTime = sT.min;
        segment.maxTime = sT.max;
        segment.minYCoord = minDataYCoord;
        segment.minValue = this.graphInstance.minMax.min;

        var tempLast:Number;
        //UTOLSO ELEM LEZARASA
        if (segment.pCommands.length > 0 && segment.pCommands[segment.pCommands.length - 1] === GraphicsPathCommand.LINE_TO && segment.pCoords[segment.pCoords.length - 2] != minDataYCoord) {
            tempLast = segment.pCoords[segment.pCoords.length - 1];
            segment.pCommands.push(GraphicsPathCommand.LINE_TO)
            segment.pCoords.push(minDataYCoord);
            segment.pCoords.push(tempLast);
        }
        if (segment.nCommands.length > 0 && segment.nCommands[segment.nCommands.length - 1] === GraphicsPathCommand.LINE_TO && segment.nCoords[segment.nCoords.length - 2] != minDataYCoord) {
            tempLast = segment.nCoords[segment.nCoords.length - 1];
            segment.nCommands.push(GraphicsPathCommand.LINE_TO)
            segment.nCoords.push(minDataYCoord);
            segment.nCoords.push(tempLast);

        }

        segment.render();
        graphSegments.push(segment);
        if (!this.contains(segment.sprite)) {
            this.addChild(segment.sprite);
        }
        segment.sprite.y = actualSegmentX //- CustomGraph.SEGMENT_WIDTH;
        return segment.sprite.height;
    }
}
}
