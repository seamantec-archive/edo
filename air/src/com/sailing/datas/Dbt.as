package com.sailing.datas {
import com.sailing.units.Depth;

public class Dbt extends BaseSailData {
    //meter
    public var waterDepth:Depth = new Depth();

    public function Dbt() {
        super();
        _paramsDisplayName["waterDepth"] = { displayName: "Water depth", order: 0 };
    }

    public override function get displayName():String {
        return "Depth Below Transducer (DBT)";
    }
}
}