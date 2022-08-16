/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.01.
 * Time: 15:31
 * To change this template use File | Settings | File Templates.
 */
package com.ui.controls {
import flash.events.MouseEvent;

public class GraphDropDownElement extends MenuElement {
    private var _data:String;
    private var _ddrlist:GraphDropdown;
    private var _index:int;
    public function GraphDropDownElement(label:String, data:String, ddrList:GraphDropdown, index:int) {
        super(label, elementClicked, 129, GraphDropdown.ELEMENT_HEIGHT);
        _data = data;
        _ddrlist = ddrList;
        _index = index;
    }

    private function elementClicked(event:MouseEvent):void {
       _ddrlist.elementSelected(this._data, this._index);
    }


    public function get data():String {
        return _data;
    }
}
}
