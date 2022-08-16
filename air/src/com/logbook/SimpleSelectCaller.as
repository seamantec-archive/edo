/**
 * Created by pepusz on 2014.02.06..
 */
package com.logbook {
public class SimpleSelectCaller implements ISelectCaller {
    private var _results:Vector.<LogBookEntry>;

    public function SimpleSelectCaller() {
    }


    public function gotResult(entries:Vector.<LogBookEntry>):void {
        _results = entries;
    }

    public function get results():Vector.<LogBookEntry> {
        return _results;
    }
}
}
