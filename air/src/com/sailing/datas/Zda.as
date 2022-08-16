package com.sailing.datas {
public class Zda extends BaseSailData {
    public var utc:Date = new Date();
    public var hour:Number = 0;
    public var min:Number = 0;
    public var sec:Number = 0;
    public var localTime:Date = new Date();
    public var offsetInMin:Number = 0;

    public function Zda() {
        super();
        _paramsDisplayName["utc"] = { displayName: "UTC", order: 0 };
        _paramsDisplayName["hour"] = { displayName: "Hour", order: 1 };
        _paramsDisplayName["min"] = { displayName: "Minute", order: 2 };
        _paramsDisplayName["sec"] = { displayName: "Second", order: 3 };
        _paramsDisplayName["localTime"] = { displayName: "Local time", order: 4 };
        _paramsDisplayName["offsetInMin"] = { displayName: "Local time offset in minutes", order: 5 };
    }

    public override function get displayName():String {
        return "Time & Date (ZDA)";
    }
}
}