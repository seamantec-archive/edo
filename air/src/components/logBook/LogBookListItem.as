/**
 * Created by pepusz on 2014.02.08..
 */
package components.logBook {
import com.logbook.LogBookEntry;
import com.loggers.DataLogger;
import com.utils.FontFactory;

import components.list.DynamicListItem;
import components.list.List;
import components.windows.FloatWindow;
import components.windows.WindowFrame;

import flash.events.MouseEvent;
import flash.geom.Point;

public class LogBookListItem extends DynamicListItem {
    public static const HEIGHT:uint = 30;
    public static const WIDTH:uint = FloatWindow.W_WIDTH - WindowFrame.CONTENT_TOP_X_ZERO - WindowFrame.RIGHT_EDGE_WIDTH;
    private var _logBookEntry:LogBookEntry;

    public function LogBookListItem(logBookEntry:LogBookEntry, list:List) {
        super(WIDTH, HEIGHT, list);
        this._logBookEntry = logBookEntry;
        addContentChild(new LogBookDetail(WIDTH, logBookEntry))
        fillLabel();
        this.addEventListener(MouseEvent.CLICK, mouseDownHandler, false, 0, true);
    }

    private function fillLabel():void {
        this.addLabel(DataLogger.toFormatedUTCDateWithoutSec(_logBookEntry.timestamp), FontFactory.getAlarmTitleTextField(), 0, (HEIGHT - 16) / 2);
    }

    private function mouseDownHandler(event:MouseEvent):void {
        _downPoint = new Point(event.stageX, event.stageY);
    }

    protected override function drawBg(color:uint, alpha:Number, width:Number, height:Number):void {
        this.graphics.beginFill(0xe6e6e6);
        this.graphics.drawRect(0, 0, width, height);
        this.graphics.lineStyle(1, 0xffffff);
        this.graphics.moveTo(0, 0)
        this.graphics.lineTo(width, 0);
        this.graphics.lineStyle(1, 0xb0b0b0);
        this.graphics.moveTo(0, height - 1)
        this.graphics.lineTo(width, height - 1);
    }


    public function get logBookEntry():LogBookEntry {
        return _logBookEntry;
    }
}
}
