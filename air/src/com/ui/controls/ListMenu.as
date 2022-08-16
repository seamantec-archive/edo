/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 7/19/13
 * Time: 2:09 PM
 * To change this template use File | Settings | File Templates.
 */
package com.ui.controls {
import com.events.ListElementSelectedEvent;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

public class ListMenu extends Sprite {

    private var elementsList:DropDownListElementVector;
    private var elementsListSprite:Sprite;

    public function ListMenu(list:DropDownListElementVector, w:uint = 100, h:uint = 100) {
        elementsList = list;
        elementsListSprite = new Sprite();
        addSprite();
        elementsList.addEventListener(ListElementSelectedEvent.SELECT, selectHandler, false, 0, true);
    }

    private function addSprite():void{
        fillElements();
        this.addChild(elementsListSprite);
    }

    private function fillElements():void{
        for(var i:uint = 0; i < elementsList.listElementsVector.length; i++){
            elementsList.listElementsVector[i].x = 0;
            elementsList.listElementsVector[i].y = i*elementsList.listElementsVector[i].height;
            elementsListSprite.addChild(elementsList.listElementsVector[i]);
        }
        elementsListSprite.x = 0;
        elementsListSprite.y = 0;
        elementsListSprite.scrollRect = new Rectangle(0,10,
                elementsList.elementWidth, elementsList.elementHeight*elementsList.elements_in_ScrollRect);
        elementsListSprite.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, false, 0, true);
        elementsList.listElementsVector[elementsList.selectedIndex].labelText.backgroundColor = 0x6249ff;
    }

    private function mouseWheelHandler(event:MouseEvent):void {
        scrollBox(-event.delta, false);
    }

    private function scrollBox(dy:Number, needSlowDown:Boolean = true):void {
        var rect:Rectangle = elementsListSprite.scrollRect;
        rect.y += dy;
        if (rect.y < elementsListSprite.y/* - elementsList.elementHeight*/) {
            rect.y = elementsListSprite.y// - elementsList.elementHeight;
        }else if(rect.y > elementsList.elementHeight * (elementsList.elements_in_ScrollRect - 1) ){
            rect.y = elementsList.elementHeight * (elementsList.elements_in_ScrollRect - 1);
        }

//        if (rect.y > elementsListSprite.y - upSprt.height*1.5){
//            showUpSprt();
//        }else{
//            hideUpSprt();
//        }
//
//        if(rect.y < elementsList.elementHeight * (elementsList.elements_in_ScrollRect - 2) + downSprt.height){
//            showDownSprt();
//        }else{
//            hideDownSprt();
//        }

        elementsListSprite.scrollRect = rect;
    }

    private function selectHandler(e:ListElementSelectedEvent):void{
        elementsList.listElementsVector[elementsList.prevSelectedIndex].selected = false;
        elementsList.listElementsVector[elementsList.prevSelectedIndex].labelText.backgroundColor = 0x000000;
        elementsList.listElementsVector[elementsList.selectedIndex].selected = true;
        elementsList.listElementsVector[elementsList.selectedIndex].labelText.backgroundColor = 0x6249ff;
    }
}
}
