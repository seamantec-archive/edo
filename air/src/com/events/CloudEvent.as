/**
 * Created by seamantec on 04/02/15.
 */
package com.events {
import flash.events.Event;

public class CloudEvent extends Event {

    public static const SIGNIN_COMPLETE:String = "signInComplete";
    public static const SIGNIN_ERROR:String = "signInError";
    public static const SIGNOUT:String = "signOut";
    public static const GET_DEVICES_COMPLETE:String = "getDevicesComplete";
    public static const GET_DEVICES_ERROR:String = "getDevicesError";
    public static const GET_LOGS_COMPLETE:String = "getLogsComplete";
    public static const GET_LOGS_ERROR:String = "getLogsError";
    public static const GET_POLARS_COMPLETE:String = "getPolarsComplete";
    public static const GET_POLARS_ERROR:String = "getPolarsError";
    public static const GET_POLAR_CLOUDS_COMPLETE:String = "getPolarCloudsComplete";
    public static const GET_POLAR_CLOUDS_ERROR:String = "getPolarCloudsError";

    public var data:Object;

    public function CloudEvent(type:String, data:Object = null) {
        super(type);
        this.data = data;
    }
}
}
