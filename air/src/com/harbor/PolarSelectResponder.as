/**
 * Created by pepusz on 2014.02.06..
 */
package com.harbor {
import flash.data.SQLResult;
import flash.errors.SQLError;
import flash.net.Responder;

public class PolarSelectResponder extends Responder {
    private var callerItem:IPolarSelectCaller;
    private var afterInsert:Boolean;

    public function PolarSelectResponder(callerItem:IPolarSelectCaller, afterInsert:Boolean = false) {
        this.callerItem = callerItem;
        this.afterInsert = afterInsert;
        super(success, failure);
    }

    private function success(event:SQLResult):void {
        if (event.data != null) {
            var results:Vector.<PolarFile> = new Vector.<PolarFile>(event.data.length, true)
            for (var i:int = 0; i < event.data.length; i++) {
                results[i] = PolarFile.parseSql(event.data[i]);
            }
            if (afterInsert) {
                callerItem.gotAfterInsertResult(results[0])
            } else {
                callerItem.gotSelectResult(results)
            }
        } else {
            if (afterInsert) {
                callerItem.gotAfterInsertResult(null)
            } else {
                callerItem.gotSelectResult(new Vector.<PolarFile>(0));
            }
        }
    }

    private function failure(event:SQLError):void {
        trace("failure", event.details)

    }
}
}
