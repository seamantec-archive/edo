/**
 * Created by seamantec on 21/01/14.
 */
package com.sailing.datas {
public class Eta extends BaseSailData {

    public var eta:Number;

    public function Eta() {
        super();
        _paramsDisplayName["eta"] = { displayName: "Estimated Time of Arrival", order: 0 };
    }

    public override function get displayName():String {
        return "Estimated Time of Arrival";
    }
}
}
