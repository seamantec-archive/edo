/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.07.17.
 * Time: 18:23
 * To change this template use File | Settings | File Templates.
 */
package components.graph.custom {
import com.graphs.YData;

import flash.display.GraphicsPathCommand;

public class AreaGraph extends Graph {


    public function AreaGraph(graphInstance:GraphInstance, width:int, height:int, ydata:YData) {
        super(graphInstance, width, height, ydata);
        _isAreaGraph = true;
    }

    protected override function initSegmentsContainer():void {
//        for (var i:int = 0; i < 40; i++) {
        segmentContainer.push(new AreaGraphSegment(_ydata));
        segmentContainerPointer = 0;
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
        //UTOLSO ELEM LEZARASA
        if (segment.pCommands.length > 0 && segment.pCommands[segment.pCommands.length - 1] === GraphicsPathCommand.LINE_TO && segment.pCoords[segment.pCoords.length - 1] != minDataYCoord) {
            segment.pCommands.push(GraphicsPathCommand.LINE_TO)
            segment.pCoords.push(segment.pCoords[segment.pCoords.length - 2]);
            segment.pCoords.push(minDataYCoord);
        }
        if (segment.nCommands.length > 0 && segment.nCommands[segment.nCommands.length - 1] === GraphicsPathCommand.LINE_TO && segment.nCoords[segment.nCoords.length - 1] != minDataYCoord) {
            segment.nCommands.push(GraphicsPathCommand.LINE_TO)
            segment.nCoords.push(segment.nCoords[segment.nCoords.length - 2]);
            segment.nCoords.push(minDataYCoord);
        }

        segment.render();
        graphSegments.push(segment);
        if (!this.contains(segment.sprite)) {
            this.addChild(segment.sprite);
        }
        segment.sprite.x = actualSegmentX //- CustomGraph.SEGMENT_WIDTH;
        return segment.sprite.width;
    }
}
}
