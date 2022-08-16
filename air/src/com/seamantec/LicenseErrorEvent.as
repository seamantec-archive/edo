/**
 * Created by pepusz on 2014.02.18..
 */
package com.seamantec {
import flash.events.Event;

public class LicenseErrorEvent extends Event {
    public static const LICENSE_ERROR:String = "license-error"
    public var errorMessages:String
    public function LicenseErrorEvent(errorMessages:String) {
        super(LICENSE_ERROR);
        this.errorMessages = errorMessages;
    }
}
}
