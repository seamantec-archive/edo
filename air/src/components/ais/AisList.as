/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.10.07.
 * Time: 14:56
 * To change this template use File | Settings | File Templates.
 */
package components.ais {
import com.events.AisVesselSelected;
import com.events.UnitChangedEvent;
import com.sailing.ais.AisContainer;
import com.sailing.ais.Vessel;
import com.sailing.ais.events.ShipChangeEvent;
import com.sailing.ais.events.ShipRemovedEvent;
import com.sailing.units.UnitHandler;
import com.store.Statuses;

import components.windows.FloatWindow;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

public class AisList extends Sprite {
    public static const HEADERY_OFFSET:uint = 37;
    private var _isWindowOpen:Boolean = false;
    private var _allShipList:Vector.<AisListItem> = new <AisListItem>[];
    private var _underwayList:Vector.<AisListItem> = new <AisListItem>[];
    private var openCounter:uint = 0;
    private var _listHeight:int;
    private var _listWidth:int;
    protected var dragStartDataPoint:Point;
    private var _scrollBar:ScrollBarIndicator;
    private var actualSelectedMMSI:String = null;
    private var _allShipsView:Sprite = new Sprite();
    private var _underwayShipsView:Sprite = new Sprite();

    public function AisList() {
        super();
        this.x = 0;
        this.y = 20;
        _listHeight = FloatWindow.L_HEIGHT - AisListWindow.HEADER_HEIGHT;
        _listWidth = FloatWindow.L_WIDTH;
        this.scrollRect = new Rectangle(0, 0, _listWidth, _listHeight);
        this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true);
        this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
        this._scrollBar = new ScrollBarIndicator();
        this._scrollBar.x = _listWidth - _scrollBar.width - 6 + this.x;
        _scrollBar.yOffset = this.y;
        _scrollBar.setY(0);
        _scrollBar.windowHeight = _listHeight;
        _allShipsView.y = 0;
        _allShipsView.x = 0;
        this.addChild(_allShipsView)
        _underwayShipsView.y = 0;
        _underwayShipsView.x = 0;
        _underwayShipsView.visible = false;
        this.addChild(_underwayShipsView);
        AisContainer.instance.addEventListener(AisVesselSelected.AIS_VESSEL_SELECTED, aisVesselSelectedMMSIHandler, false, 0, true);
    }

    private function addedToStageHandler(event:Event):void {
        stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, false, 0, true);
        if (!this.parent.contains(_scrollBar)) {
            this.parent.addChild(_scrollBar);
        }
    }

    public function get isWindowOpen():Boolean {
        return _isWindowOpen;
    }

    public function set isWindowOpen(value:Boolean):void {
        _isWindowOpen = value;
        if (_isWindowOpen) {
            reAddAllShip();
            AisContainer.instance.addEventListener(ShipChangeEvent.SHIP_CHANGED_EVENT, shipChangedHandler, false, 0, true);
            AisContainer.instance.addEventListener(ShipRemovedEvent.SHIP_REMOVED_EVENT, ship_removedHandler, false, 0, true);
            AisContainer.instance.addEventListener("removeAllShip", removeAllShipHandler, false, 0, true);
            UnitHandler.instance.addEventListener(UnitChangedEvent.CHANGE, unit_changed_eventHandler, false, 0, true);
            AisContainer.instance.addEventListener("all-ship-data-changed", allShipChangedHandler, false, 0, true);
        } else {
            AisContainer.instance.removeEventListener(ShipChangeEvent.SHIP_CHANGED_EVENT, shipChangedHandler);
            AisContainer.instance.removeEventListener(ShipRemovedEvent.SHIP_REMOVED_EVENT, ship_removedHandler);
            AisContainer.instance.removeEventListener("removeAllShip", removeAllShipHandler);
            UnitHandler.instance.removeEventListener(UnitChangedEvent.CHANGE, unit_changed_eventHandler);
            AisContainer.instance.removeEventListener("all-ship-data-changed", allShipChangedHandler);
        }
    }

    public function addItem(vessel:Vessel):void {
        var view:AisListItem = getItemByMmsi(vessel.mmsi);
        if (view === null) {
            view = new AisListItem(vessel, this);
            view.x = 0;
            _allShipList.push(view);
            _scrollBar.listHeight = getListHeight()
        } else {
            view.update();
        }
        order();
    }

    private function order():void {
        _allShipList.sort(sortByDistance);
        refreshShipLists();
        refreshVisibleList();
    }

    private function refreshShipLists():void {
        var item:AisListItem;
        for (var i:int = 0; i < _allShipList.length; i++) {
            item = _allShipList[i];
            if (item.vessel.isUnderWay()) {
                addUnderway(item)
            } else {
                removeUnderway(item)
            }
        }
        _underwayList.sort(sortByDistance);
        dispatchEvent(new Event("UnderWayCounterChanged"));
    }

    private function addUnderway(item:AisListItem):void {
        for (var i:int = 0; i < _underwayList.length; i++) {
            if (_underwayList[i] === item) {
                return;
            }
        }
        _underwayList.push(item)
    }

    private function removeUnderway(item:AisListItem):void {
        for (var i:int = 0; i < _underwayList.length; i++) {
            if (_underwayList[i] === item) {
                _underwayList.splice(i, 1);
                return;
            }
        }
    }


    private function sortByDistance(a:AisListItem, b:AisListItem):int {
        if (a.vessel.distanceFromOwnShip < b.vessel.distanceFromOwnShip) {
            return -1
        } else if (a.vessel.distanceFromOwnShip > b.vessel.distanceFromOwnShip) {
            return 1;
        } else {
            return 0
        }
    }

    private function getItemByMmsi(mmsi:String):AisListItem {
        for (var i:int = 0; i < _allShipList.length; i++) {
            if (_allShipList[i].vessel.mmsi === mmsi) {
                return _allShipList[i]
            }
        }
        return null;
    }


    private function shipChangedHandler(event:ShipChangeEvent):void {
        if (event.vessel == null) {
            return;
        }
        if (event.vessel.shipStatus == Vessel.SHIP_OUTDATED) {
            removeItem(event.vessel.mmsi);
            return;
        }
        addItem(event.vessel);
    }

    private function refreshVisibleList():void {
        if (_allShipsView.visible) {
            refreshAllView();
        } else {
            refreshUnderwayView();
        }
        setScrollBarHeight();
        if (_scrollBar.y < _scrollBar.yOffset) {
            _scrollBar.setY(0);
        }
    }

    public function isAllView():Boolean {
        return _allShipsView.visible;
    }

    private function refreshAllView():void {
        var item:AisListItem;
        var openedIndex:int = -1;
        for (var i:int = 0; i < _allShipList.length; i++) {
            item = _allShipList[i];
            if (item.isOpen()) {
                openedIndex = i;
            }
            if (!_allShipsView.contains(item)) {
                _allShipsView.addChild(item);
            }
            if (i <= openedIndex || openedIndex == -1) {
                item.y = i * AisListItem.HEADER_HEIGHT;
            } else {
                item.y = i * AisListItem.HEADER_HEIGHT + AisListItem.itemBgBitmap.height;
            }
        }
        if (_allShipList.length != _allShipsView.numChildren) {
            var needToRemove:Vector.<int> = new <int>[];
            for (var i:int = 0; i < _allShipsView.numChildren; i++) {
                if (!hasItemInAllList(_allShipsView.getChildAt(i) as AisListItem)) {
                    needToRemove.push(i)
                }
            }
            for (var i:int = 0; i < needToRemove.length; i++) {
                _allShipsView.removeChildAt(needToRemove[i]);
            }
        }
    }

    private function refreshUnderwayView():void {
        var item:AisListItem;
        var openedIndex:int = -1;
        for (var i:int = 0; i < _underwayList.length; i++) {
            item = _underwayList[i];
            if (item.isOpen()) {
                openedIndex = i;
            }
            if (!_underwayShipsView.contains(item)) {
                _underwayShipsView.addChild(item);
            }
            if (i <= openedIndex || openedIndex == -1) {
                item.y = i * AisListItem.HEADER_HEIGHT;
            } else {
                item.y = i * AisListItem.HEADER_HEIGHT + AisListItem.itemBgBitmap.height;
            }
        }
        if (_underwayList.length != _underwayShipsView.numChildren) {
            var needToRemove:Vector.<int> = new <int>[];
            for (var i:int = 0; i < _underwayShipsView.numChildren; i++) {
                if (!hasItemInUnderwayList(_underwayShipsView.getChildAt(i) as AisListItem)) {
                    needToRemove.push(i)
                }
            }
            for (var i:int = 0; i < needToRemove.length; i++) {
                _underwayShipsView.removeChildAt(needToRemove[i]);

            }
        }
    }

    private function hasItemInUnderwayList(item:AisListItem):Boolean {
        return hasItemInList(_underwayList, item);
    }

    private function hasItemInAllList(item:AisListItem):Boolean {
        return hasItemInList(_allShipList, item);
    }

    private function hasItemInList(list:Vector.<AisListItem>, item:AisListItem):Boolean {
        for (var i:int = 0; i < list.length; i++) {
            if (list[i] === item) {
                return true;
            }
        }
        return false;
    }

    public function removeItem(mmsi:String):void {
        var view:AisListItem = getItemByMmsi(mmsi);
        if (_allShipsView.contains(view)) {
            _allShipsView.removeChild(view);
        }
        if (_underwayShipsView.contains(view)) {
            _underwayShipsView.removeChild(view);
        }

        for (var i:int = 0; i < _allShipList.length; i++) {
            if (_allShipList[i] === view) {
                _allShipList.splice(i, 1);
                break;
            }
        }
        if (view.vessel.isUnderWay()) {
            for (var i:int = 0; i < _underwayList.length; i++) {
                if (_underwayList[i] === view) {
                    _underwayList.splice(i, 1);
                    break;
                }
            }
        }
        if (mmsi === actualSelectedMMSI) {
            openCounter--;
            actualSelectedMMSI = null;
        }
        refreshVisibleList();
        handleGapInTheEndOfListAfterRemoveCloseElement();
    }

    public function openCloseElement(mmsi:String, isOpen:Boolean = true):void {
        for (var i:int = 0; i < _allShipList.length; i++) {
            if (_allShipList[i].vessel.mmsi === mmsi) {
                if (isOpen) {
                    if (actualSelectedMMSI === mmsi) {
                        break;
                    }
                    if (actualSelectedMMSI != null) {
                        getItemByMmsi(actualSelectedMMSI).closeElement();
                    }
                    actualSelectedMMSI = mmsi;
                    openCounter++;
                    shiftDownElements(i);
                } else {
                    openCounter--;
                    closeElement(i);

                }
                break;
            }
        }
        refreshVisibleList();
    }

    //after open an element we need to shift down other elements
    private function shiftDownElements(selectedIndex:uint):void {
        var itemHeight:uint = AisListItem.itemBgBitmap.height;
        for (var i:int = selectedIndex + 1; i < _allShipList.length; i++) {
            _allShipList[i].y += itemHeight;
        }
        _scrollBar.listHeight = getListHeight();
        if (selectedIndex === _allShipList.length - 1) {
            scrollBox(+itemHeight);
        }
    }

    //when close an element we need to shift up other elements
    public function closeElement(selectedIndex:uint):void {
        var itemHeight:uint = AisListItem.itemBgBitmap.height;
        for (var i:int = selectedIndex + 1; i < _allShipList.length; i++) {
            _allShipList[i].y -= itemHeight;
        }
        handleGapInTheEndOfListAfterRemoveCloseElement();
        actualSelectedMMSI = null;
    }


    ////--------SCROLLING----------
    public function mouseDownHandler(event:MouseEvent):void {
        if (event.target is AisOpenCloseButton) {
            return;
        }
        stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true);
        stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
        dragStartDataPoint = new Point(event.stageX, event.stageY);
    }

    private function mouseMoveHandler(event:MouseEvent):void {
        var currDataPoint:Point = new Point(event.stageX, event.stageY);
        var dy:Number = dragStartDataPoint.y - currDataPoint.y;
        scrollBox(dy);
        dragStartDataPoint = currDataPoint;
    }

    protected function scrollBox(dy:Number):void {
        var rect:Rectangle = this.scrollRect;
        rect.y += dy;
        if (rect.y < 0) {
            rect.y = 0
        } else if (rect.y >= (getListHeight() - _listHeight)) {
            if (((getListHeight()) > (_listHeight))) {
                rect.y = getListHeight() - _listHeight
            } else {
                rect.y = 0
            }
        }
        setScrollBarYToRectY(rect);
        this.scrollRect = rect;
    }

    //closing, removing element need to reposition scroll
    private function handleGapInTheEndOfListAfterRemoveCloseElement():void {
        _scrollBar.listHeight = getListHeight();
        if (getListHeight() - this.scrollRect.y < this.scrollRect.height) {
            scrollBox(getListHeight() - this.scrollRect.y);
        }
    }

    private function getListHeight():Number {
        if (_allShipsView.visible) {
            return _allShipList.length * AisListItem.HEADER_HEIGHT + openCounter * AisListItem.itemBgBitmap.height;
        } else {
            return _underwayList.length * AisListItem.HEADER_HEIGHT + openCounter * AisListItem.itemBgBitmap.height;
        }
    }

    private function scrollToTop():void {
        var rect:Rectangle = this.scrollRect;
        rect.y = 0;
        setScrollBarYToRectY(rect);
        this.scrollRect = rect;

    }

    private function setScrollBarYToRectY(rect:Rectangle):void {
        _scrollBar.setY(rect.y);
    }

    private function mouseUpHandler(event:MouseEvent):void {
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
        stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
    }

    private function mouseWheelHandler(event:MouseEvent):void {
        var delta:Number = -event.delta*2;
        if(Statuses.isWindows()) {
            delta *= 4;
        }
        scrollBox(delta);
    }


    private function aisVesselSelectedMMSIHandler(event:AisVesselSelected):void {
        if (!_isWindowOpen) {
            return;
        }
        var item:AisListItem;
        if (event.mmsi != null && (actualSelectedMMSI == null || event.mmsi != actualSelectedMMSI)) {
            item = getItemByMmsi(event.mmsi)
            if (item === null) {
                return
            }
            item.openElement();
        } else if (event.mmsi == null && actualSelectedMMSI != null) { //when was opened element, but other component deselect all ship
            item = getItemByMmsi(actualSelectedMMSI)
            if (item === null) {
                return;
            }
            item.closeElement();
        }
        refreshVisibleList();
    }

    private function removeAllShipHandler(event:Event):void {
        resetList();
    }

    private function resetList():void {
        removeAllShipsView();
        removeAllUnerwayShips();
        _allShipList.length = 0;
        openCounter = 0;
        _underwayList.length = 0;
        dispatchEvent(new Event("UnderWayCounterChanged"));
        scrollToTop();
    }

    private function removeAllUnerwayShips():void {
        if (_underwayShipsView.numChildren > 0)_underwayShipsView.removeChildren(0, _underwayShipsView.numChildren - 1);
    }

    private function removeAllShipsView():void {
        if (_allShipsView.numChildren > 0) _allShipsView.removeChildren(0, _allShipsView.numChildren - 1);
    }


    private function reAddAllShip():void {
        resetList();
        for each (var object:Vessel in AisContainer.instance.container) {
            addItem(object);
        }
        if (AisContainer.instance.selectedShipMMSI != null) {
            getItemByMmsi(AisContainer.instance.selectedShipMMSI).openElement();
        }
        order();
    }

    private function unit_changed_eventHandler(event:UnitChangedEvent):void {
        //TODO implement
    }

    private function allShipChangedHandler(event:Event):void {
        //TODO implement
    }


    public function showAllVessel():void {
        removeAllShipsView();
        refreshAllView();
        _underwayShipsView.visible = false;
        _allShipsView.visible = true;
        setScrollBarHeight();
        scrollToTop();
    }

    public function showUnderwayShips():void {
        removeAllUnerwayShips();
        refreshUnderwayView();
        _underwayShipsView.visible = true;
        _allShipsView.visible = false;
        setScrollBarHeight();
        scrollToTop();

    }

    private function setScrollBarHeight():void {
        _scrollBar.listHeight = getListHeight();

    }

    public function get allShipList():Vector.<AisListItem> {
        return _allShipList;
    }


    public function get underwayList():Vector.<AisListItem> {
        return _underwayList;
    }

    public function get scrollBar():ScrollBarIndicator {
        return _scrollBar;
    }

    public function scrollTo(y:uint) {
        scrollBox(y);
    }

    private function ship_removedHandler(event:ShipRemovedEvent):void {
        removeItem(event.mmsi)
    }
}
}
