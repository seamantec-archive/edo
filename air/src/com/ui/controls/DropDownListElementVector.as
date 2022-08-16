/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 7/18/13
 * Time: 10:56 AM
 * To change this template use File | Settings | File Templates.
 */
package com.ui.controls {

import com.events.ListElementSelectedEvent;

import flash.events.EventDispatcher;
import flash.events.MouseEvent;

public class DropDownListElementVector extends EventDispatcher {

    private var _listElementsVector:Vector.<DropDownListElement>;
    private var _selectedIndex:uint = 0;

    public var elementWidth:uint = 120;
    public var elementHeight:uint = 20;
    public var elementFontSize:uint = 13;
    public var elements_in_ScrollRect:uint = 5;
    public var prevSelectedIndex:uint = 0;

    /*
    *   w : menu elem szélessége
    *   h : menu elem magassága
    *   font : menu elembeli font mérete
    *   elements : legördülő menuben megjelenő elemek száma
    * */
    public function DropDownListElementVector(w:uint = 120, h:uint = 20, font:uint = 13, elements:uint = 5) {
        _listElementsVector = new Vector.<DropDownListElement>();
        _selectedIndex = 0;
        elementWidth = w;
        elementHeight = h;
        elementFontSize = font;
        elements_in_ScrollRect = elements;
    }

    public function get selectedIndex():uint {
        return _selectedIndex;
    }

    public function set selectedIndex(value:uint):void {
        _selectedIndex = value;
    }

    public function get listElementsVector():Vector.<DropDownListElement> {
        return _listElementsVector;
    }

    public function set listElementsVector(value:Vector.<DropDownListElement>):void {
        _listElementsVector = value;
    }

    public function getSelected():DropDownListElement{
        return _listElementsVector[_selectedIndex];
    }

    public function addElement(element:DropDownListElement):void{
        this._listElementsVector.push(element);
        addAListener();
    }

    public function addRawElement(str:String, dt:String):void{
        this._listElementsVector.push(new DropDownListElement(str,dt,elementWidth,elementHeight,elementFontSize));
        addAListener();
    }

    private function addAListener():void{
        this._listElementsVector[_listElementsVector.length-1].addEventListener(MouseEvent.CLICK, clickAnElementHandler, false, 0, true);
    }

    public function clickAnElementHandler(e:MouseEvent):void{
        prevSelectedIndex = _selectedIndex;
        _selectedIndex = _listElementsVector.indexOf(e.currentTarget);
        this.dispatchEvent(new ListElementSelectedEvent(0,""));
    }

    public function setSelectedThis(value:String):void{
        for (var i:int = 0; i < _listElementsVector.length; i++) {
            if(_listElementsVector[i].data === value){
                _selectedIndex = i;
                break;
            }
        }
    }


}
}
