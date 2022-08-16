/**
 * Created by seamantec on 17/07/14.
 */
package com.notification {
import com.polar.PolarContainer;

import flash.events.Event;

public class PolarNotification {

    private static var _instance:PolarNotification = null;

    public function PolarNotification() {
        PolarContainer.instance.addEventListener("too-large", openTooLargeWarningHandler);
        PolarContainer.instance.addEventListener("bad-extension", openBadExtensionWarningHandler);
        PolarContainer.instance.addEventListener("bad-file", bad_fileHandler);
        PolarContainer.instance.addEventListener("bad-cloud", bad_cloudHandler);
        PolarContainer.instance.addEventListener("polar-cloud-empty", polarCloudEmptyWarningHandler);
        PolarContainer.instance.addEventListener("wrong-log", wrongLogWarningHandler);
    }

    public static function get instance():PolarNotification {
        if(_instance==null) {
            _instance = new PolarNotification();
        }

        return _instance;
    }

    private function openTooLargeWarningHandler(e:Event):void {
        NotificationHandler.createWarning(NotificationTypes.LARGE_FILE_WARNING, NotificationTypes.LARGE_FILE_WARNING_TEXT);
    }

    private function openBadExtensionWarningHandler(e:Event):void {
        NotificationHandler.createWarning(NotificationTypes.POLAR_EXTENSION_WARNING, NotificationTypes.POLAR_EXTENSION_WARNING_TEXT);
    }

    private function polarCloudEmptyWarningHandler(e:Event):void {
        NotificationHandler.createWarning(NotificationTypes.POLAR_CLOUD_EMPTY, NotificationTypes.POLAR_CLOUD_EMPTY_TEXT);
    }

    private function wrongLogWarningHandler(e:Event):void {
        NotificationHandler.createWarning(NotificationTypes.WRONG_LOG_WARNING, NotificationTypes.WRONG_LOG_WARNING_TEXT);
    }

    private function bad_fileHandler(event:Event):void {
        NotificationHandler.createWarning(NotificationTypes.POLAR_FILE_IS_NOT_POLAR, NotificationTypes.POLAR_FILE_IS_NOT_POLAR_TEXT);
    }

    private function bad_cloudHandler(event:Event):void {
        NotificationHandler.createWarning(NotificationTypes.POLAR_CLOUD_IS_NOT_CLOUD, NotificationTypes.POLAR_CLOUD_IS_NOT_CLOUD_TEXT);
    }
}
}
