/**
 * Created by pepusz on 2014.02.06..
 */
package com.logbook {
import flash.data.SQLResult;
import flash.errors.SQLError;
import flash.net.Responder;

public class SelectResponder extends Responder {
    private var callerItem:ISelectCaller

    public function SelectResponder(callerItem:ISelectCaller) {
        this.callerItem = callerItem;
        super(success, failure);
    }

    private function success(event:SQLResult):void {
        if (event.data != null) {
            var results:Vector.<LogBookEntry> = new Vector.<LogBookEntry>(event.data.length, true)
            for (var i:int = 0; i < event.data.length; i++) {
                results[i] = LogBookEntry.parseSql(event.data[i]);
            }
            callerItem.gotResult(results)
        } else {
            callerItem.gotResult(null);
        }
    }

    private function failure(event:SQLError):void {
        trace("failure", event.details)

    }
}
}
