package com.sailing.datas
{
import com.sailing.units.Distance;

public class Vlw extends BaseSailData {
	public var totalComWaterDist:Distance = new Distance();
	public var waterDistSinceReset:Distance = new Distance();
	public var totalComGroundDist:Distance = new Distance();
	public var groundDistSinceReset:Distance = new Distance();

    public function Vlw() {
        super();
        _paramsDisplayName["totalComWaterDist"] = { displayName: "Total cumulative water distance", order: 0 };
        _paramsDisplayName["waterDistSinceReset"] = { displayName: "Water distance since reset,", order: 1 };
        _paramsDisplayName["totalComGroundDist"] = { displayName: "Total cumulative ground distance", order: 2 };
        _paramsDisplayName["groundDistSinceReset"] = { displayName: "Ground distance since reset", order: 3 };
    }

    public override function get displayName():String {
        return "Dual Ground/Water Distance (VLW)";
    }
}
}