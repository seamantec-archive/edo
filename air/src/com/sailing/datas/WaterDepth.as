/**
 * Created by pepusz on 2014.07.31..
 */
package com.sailing.datas {
import com.sailing.units.Depth;

import flash.events.EventDispatcher;

public class WaterDepth extends BaseSailData {
    public static var eventDispatcher:EventDispatcher = new EventDispatcher();
    public var waterDepth:Depth = new Depth();
    public var offset:Depth = new Depth();
    public var maximumRange:Depth = new Depth();
    public var waterDepthWithOffset:Depth = new Depth();

    public function WaterDepth() {
        super();
        _paramsDisplayName["waterDepth"] = { displayName: "Water depth relative to the transducer", order: 0 };
        _paramsDisplayName["offset"] = { displayName: "Offset", order: 1 };
        _paramsDisplayName["maximumRange"] = { displayName: "Maximum range", order: 2 };
        _paramsDisplayName["waterDepthWithOffset"] = { displayName: "Water depth with offset", order: 3 };
    }

    public override function get displayName():String {
        return "Water Depth";
    }
}
}
