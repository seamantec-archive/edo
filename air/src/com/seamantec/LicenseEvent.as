/**
 * Created by pepusz on 2013.12.08..
 */
package com.seamantec {
import flash.events.Event;

public class LicenseEvent extends Event {
    public static const DEACTIVATED:String = "licenceMangerDeactivated"
    public static const ACTIVATED:String = "licenceMangerActivated"
    public static const NETWORK_ERROR:String = "licenceMangerNetworkError"
    public static const LICENSE_DOWNLOADED:String = "licenceMangerDownloaded"
//    public static const ACTIVATED:String = "licenceMangerActivated"
//    public static const ACTIVATED:String = "licenceMangerActivated"

    public function LicenseEvent(type:String) {
        super(type);
    }
}
}
