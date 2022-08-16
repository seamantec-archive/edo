/**
 * Created with IntelliJ IDEA.
 * User: Jani
 * Date: 2013.04.29.
 * Time: 18:24
 * To change this template use File | Settings | File Templates.
 */
package components.graph.custom {
import com.graphs.YData;

import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.LineScaleMode;

public class LineGraphSegment extends GraphSegment {
    public var pLineColor:uint = 0x00aeef;
    public var pLineWidth:int = 1;
    public var pLineAlpha:Number = 0.7;
    public var nLineColor:uint = 0xff0000;
    public var nLineWidth:int = 1;
    public var nLineAlpha:Number = 0.7;

    public function LineGraphSegment(ydata:YData) {
        super()
        this.pLineColor = ydata.pLineColor;
        this.pLineWidth = ydata.pLineWidth;
        this.pLineAlpha = ydata.pLineAlpha;
        this.nLineColor = ydata.nLineColor;
        this.nLineWidth = ydata.nLineWidth;
        this.nLineAlpha = ydata.nLineAlpha;

    }

    public override function render():void {
        if (_rendered) {
            return;
        }
        _sprite.graphics.clear();
        _sprite.graphics.lineStyle(pLineWidth, pLineColor, pLineAlpha, false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER);//set the color
        _sprite.graphics.drawPath(_pCommands, _pCoords)
        if (_minValue < 0) {
            _sprite.graphics.lineStyle(nLineWidth, nLineColor, nLineAlpha, false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER);//set the color
            _sprite.graphics.drawPath(_nCommands, _nCoords);
        }
        _sprite.visible = true;
        _rendered = true;
        //exportArrays()
    }

    private function exportArrays():void {
        trace("_pCoords = [", _pCoords.toLocaleString(), "]")
        trace("_pCommands = [", _pCommands.toLocaleString(), "]")
        trace("------------------------------------------------------")
    }


}
}
