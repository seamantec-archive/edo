/**
 * Created by pepusz on 2014.02.08..
 */
package components.logBook {
import com.logbook.LogBookEntry;

import components.ais.AisListItem;
import components.ais.AisListItemText;

import flash.display.Sprite;

public class LogBookDetail extends Sprite {
    private var initWidth:uint;
    private var _logBookEntry:LogBookEntry;

    public function LogBookDetail(width:uint, logBookEntry:LogBookEntry) {
        super();
        initWidth = width;
        this._logBookEntry = logBookEntry;
        drawBg();
        initGrid();

    }

    private function drawBg():void {
        this.graphics.beginBitmapFill(AisListItem.itemBgBitmap.bitmapData);
        this.graphics.drawRect(0, 0, initWidth, AisListItem.itemBgBitmap.height);
        this.graphics.endFill();
    }

    private function initGrid():void {
        this.addChild(new AisListItemText("Lat", LogBookEntry.convertValue(_logBookEntry.lat), 70, 25, 0, 5, ["right", "bottom"]));
        this.addChild(new AisListItemText("Lon", LogBookEntry.convertValue(_logBookEntry.lon), 60, 25, 70, 5, ["right","bottom"]));
        this.addChild(new AisListItemText("SOG", LogBookEntry.convertValue(_logBookEntry.sog), 65, 25, 130, 5, ["right","bottom"]));
        this.addChild(new AisListItemText("COG", LogBookEntry.convertValue(_logBookEntry.cog, 0), 50, 25, 195, 5, ["right","bottom"]));
        this.addChild(new AisListItemText("Water Depth", LogBookEntry.convertValue(_logBookEntry.depth), 60, 25, 245, 5, ["right","bottom"]));

        this.addChild(new AisListItemText("Water Temp.", LogBookEntry.convertValue(_logBookEntry.waterTemp), 70, 25, 0, 30,["right"]));
        this.addChild(new AisListItemText("Air Temp.", LogBookEntry.convertValue(_logBookEntry.airTemp), 60, 25, 70, 30, ["right"]));
        this.addChild(new AisListItemText("Wind Speed", LogBookEntry.convertValue(_logBookEntry.windSpeed), 65, 25, 130, 30, ["right"]));
        this.addChild(new AisListItemText("Wind Dir.", LogBookEntry.convertValue(_logBookEntry.windDir, 0), 50, 25, 195, 30, ["right"]));
        this.addChild(new AisListItemText("Distance", LogBookEntry.convertValue(_logBookEntry.tripDistance, 0), 60, 25, 245, 30, ["right"]));
    }

    


}
}
