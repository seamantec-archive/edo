/**
 * Created by seamantec on 04/02/15.
 */
package components.cloud {
import com.events.CloudEvent;
import com.ui.controls.AlarmDownBtn;
import com.harbor.CloudHandler;

import components.list.List;
import components.list.ListItem;

import components.windows.FloatWindow;

import flash.events.MouseEvent;

public class CloudWindow extends FloatWindow {

    public static var WIDTH:Number;
    public static var HEIGHT:Number;

    private var _logButton:AlarmDownBtn;
    private var _logList:List;
    private var _polarButton:AlarmDownBtn;
    private var _polarList:List;
    private var _cloudButton:AlarmDownBtn;
    private var _cloudList:List;

    public function CloudWindow() {
        super("Cloud storage");

        WIDTH = this.width - _frame.getWidthAndContentDiff();
        HEIGHT = this.height - _frame.getHeightAndContentDiff();

        _logList = new List(0,0, WIDTH,HEIGHT);
        _content.addChild(_logList);

        _polarList = new List(0,0, WIDTH,HEIGHT);
        _polarList.visible = false;
        _content.addChild(_polarList);

        _cloudList = new List(0,0, WIDTH,HEIGHT);
        _cloudList.visible = false;
        _content.addChild(_cloudList);

        setButtonAlign(BUTTON_ALIGN_LEFT);
        _logButton = this.addDownButton(0, "NMEA log", logHandler);
        _polarButton = this.addDownButton(1, "Polar", polarHandler);
        _cloudButton = this.addDownButton(2, "Polar cloud", cloudHandler);
        disableDownButton(0);
        CloudHandler.instance.getLogs();
//        CloudHandler.instance.getPolars();
        CloudHandler.instance.getPolarClouds();

        this.resizeable = false;

        CloudHandler.instance.addEventListener(CloudEvent.GET_LOGS_COMPLETE, logsCompleteHandler, false, 0, true);
        CloudHandler.instance.addEventListener(CloudEvent.GET_POLARS_COMPLETE, polarsCompleteHandler, false, 0, true);
        CloudHandler.instance.addEventListener(CloudEvent.GET_POLAR_CLOUDS_COMPLETE, polarCloudsCompleteHandler, false, 0, true);
    }

    private function setPolarList(data:Array):void {
        _polarList.removeAllItem();

        var length:int = data.length;
        var item:Object;
        for(var i:int=0; i<length; i++) {
            item = data[i];
            if(item.id!=null && item.name!=null) {
                _polarList.addItem(new PolarListItem(_polarList, item.id, item.name, item.created_at, item.updated_at, item.s3_path));
            }
        }
    }


//    private function setList(type:String, items:Array):void {
//        _list.removeAllItem();
//
//        if(items!=null) {
//            var length:int = items.length;
//            var item:CloudListItem;
//            for(var i:int=0; i<length; i++) {
//                //item = items[i];
//                switch(type) {
//                    case "log":
//                        break;
//
//                    case "polar":
//                        break;
//
//                    case "cloud":
//                        break;
//
//                    default:
//
//                }
//
//                _list.addItem(item);
//            }
//        }
//    }

    private function logHandler(event:MouseEvent):void {
        disableDownButton(0);
        _logList.visible = true;
        _polarList.visible = false;
        _cloudList.visible = false;
    }

    private function polarHandler(event:MouseEvent):void {
        disableDownButton(1);
        _logList.visible = false;
        _polarList.visible = true;
        _cloudList.visible = false;
    }

    private function cloudHandler(event:MouseEvent):void {
        disableDownButton(2);
        _logList.visible = false;
        _polarList.visible = false;
        _cloudList.visible = true;
    }

    private function logsCompleteHandler(event:CloudEvent):void {
//        setList("log", event.data as Array);
    }

    private function polarsCompleteHandler(event:CloudEvent):void {
        setPolarList(event.data.polars as Array);
    }

    private function polarCloudsCompleteHandler(event:CloudEvent):void {
//        setList("cloud", event.data as Array);
    }
}
}
