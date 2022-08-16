package components.list {

import com.events.AppClick;
import com.store.Statuses;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

public class List extends Sprite {

    private var _container:Vector.<ListItem>;
    private var _list:Sprite;
    private var _header:ListHeader;
    private var _scrollBar:Sprite;
    private var _dragPoint:Point;

    private var _color:uint;
    private var _alpha:Number;

    private var _order:Function;
    private var _filters:Vector.<Function>;

    private var _clickFilters:Vector.<Class>;

    public function List(x:Number, y:Number, width:Number, height:Number, color:uint = 0xFFFFFF, alpha:Number = 0) {
        super();

        this.x = x;
        this.y = y;
        //this.width = width;
        //this.height = height;
        _color = color;
        _alpha = alpha;
        this.graphics.beginFill(color, alpha);
        this.graphics.drawRect(0, 0, width, height);
        this.graphics.endFill();

        _container = new Vector.<ListItem>();
        _list = new Sprite();
        _list.x = 0;
        _list.y = 0;
        //_list.width = this.width;
        //_list.height = this.height;
        _list.graphics.beginFill(0xFFFFFF, 0);
        _list.graphics.drawRect(0, 0, this.width, this.height);
        _list.graphics.endFill();
        _list.scrollRect = new Rectangle(0, 0, this.width, this.height);

        _list.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
        _list.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, false, 0, true);

        this.addChild(_list);

        _header = null;
        _scrollBar = null;

        _order = null;
        _filters = null;
        _clickFilters = null;
    }

    public function sort(f:Function = null):void {
        if (f != null && f.length == 2) {
            _container.sort(f);
        }
    }

    public function filter(filters:Vector.<Function> = null) {
        var height:Number = 0;
        if (filters != null) {
            for (var i:int = 0; i < _container.length; i++) {
                var filter:Boolean = true;
                var item:ListItem = _container[i];
                for (var j:int = 0; j < filters.length; j++) {
                    var f:Function = filters[j];
                    if (f.length == 1) {
                        filter = filter && (f(item) as Boolean);
                    } else if (f.length == 0) {
                        filter = filter && f();
                    } else {
                        filter = false;
                        break;
                    }
                }
                if (filter) {
                    item.visible = true;
                    item.y = height;
                    height += item.getHeight();
                } else {
                    item.visible = false;
                }
            }
        } else {
            for (var i:int = 0; i < _container.length; i++) {
                var item:ListItem = _container[i];
                item.visible = true;
                item.y = height;
                height += item.getHeight();
            }
        }
        drawScrollBar();
    }

    public function addItem(item:ListItem):void {
        item.x = 0;
        item.y = getHeight();
        _container.push(item);
        _list.addChild(item);

        sort(_order);
        filter(_filters);

        drawScrollBar();
    }

    public function getItemIndex(item:ListItem):int {
        return _container.indexOf(item);
    }

    public function getItem(index:int):ListItem {
        return _container[index];
    }

    /*
     public function changeItem(index:int, item:ListItem) {
     removeIndex(index);
     _list.addChildAt(item, index);
     var h:Number = 0;
     for(var i:int=0; i<_list.numChildren; i++) {
     var it:ListItem = (_list.getChildAt(i) as ListItem);
     if((it as DynamicListItem).hasContent && i!=index) {
     (it as DynamicListItem).changeState();
     }
     it.y = h;
     h += it.height;
     }
     drawScrollBar();
     }
     */
    public function removeItem(item:ListItem):void {
        _container.splice(_container.indexOf(item), 1);
        _list.removeChild(item);

        filter(_filters);

        drawScrollBar();
    }

    public function removeIndex(index:int):void {
        _container.splice(index, 1);
        _list.removeChildAt(index);

        filter(_filters);

        drawScrollBar();
    }

    public function removeAllItem():void {
        while (_container.length > 0) {
            _container.splice(0, 1);
            _list.removeChildAt(0);
        }
        drawScrollBar();
    }

    public function resize(w:Number, h:Number):void {
        //var heightDiff:Number = h - this.height;

        this.graphics.clear();
        this.graphics.beginFill(_color, _alpha);
        this.graphics.drawRect(0, 0, w, h);
        this.graphics.endFill();

        if (hasHeader()) {
            _header.setWidth(w);
        }
        if (hasScrollBar()) {
            _scrollBar.x = w - 6;
            drawScrollBar();
        }

        _list.graphics.clear();
        _list.graphics.beginFill(0xFFFFFF, 0);
        _list.graphics.drawRect(0, 0, w, h);
        _list.graphics.endFill();

        var rect:Rectangle = _list.scrollRect;
        rect.width = w;
        rect.height = (hasHeader()) ? h - _header.getHeight() : h;
        _list.scrollRect = rect;
        scrollBox(0);

        filter(_filters);
        /*
         for(var i:int=0; i<_container.length; i++) {
         _container[i].setWidth(w);
         }
         */
    }

    public function addHeader(header:ListHeader):void {
        _header = header;
        _header.x = 0;
        _header.y = 0;
        this.addChildAt(_header, 0);
        _list.y = _header.getHeight();
        _list.scrollRect = new Rectangle(0, 0, _list.width, _list.height - _list.y);
    }

    public function addScrollBar():void {
        _scrollBar = new Sprite();
        _scrollBar.x = this.width - 6;
        this.addChildAt(_scrollBar, this.numChildren);
        drawScrollBar();
    }

    public function scrollTo(y:Number):void {
        var rect:Rectangle = _list.scrollRect;
        var height:Number = getHeight();
        if (rect.height < height) {
            if (y < 0) {
                rect.y = 0;
            } else if (y > (height - rect.height)) {
                rect.y = height - rect.height;
            } else {
                rect.y = y;
            }

            if (hasScrollBar()) {
                _scrollBar.y = _list.y + rect.height * (rect.y / height);
            }
        } else {
            rect.y = 0;

            if (hasScrollBar()) {
                _scrollBar.y = 0;
                _scrollBar.graphics.clear();
            }
        }
        _list.scrollRect = rect;
    }

    public function scrollBox(dy:Number):void {
        var y:Number = _list.scrollRect.y + dy;
        scrollTo(y);
    }

    public function scrollToTop():void {
        scrollTo(0);
    }

    public function getHeight():int {
        return getHeightUnderIndex(_container.length);
    }

    public function getHeightUnderIndex(index:int):Number {
        var result:int = 0;
        for (var i:int = 0; i < index; i++) {
            if (_container[i].visible) {
                result += _container[i].getHeight();
            }
        }
        return result;
    }

    public function get list():Sprite {
        return _list;
    }

    public function get length():int {
        return _container.length;
    }

    public function get header():ListHeader {
        return _header;
    }

    public function set order(order:Function):void {
        _order = order;
    }

    public function get order():Function {
        return _order;
    }

    public function get color():uint {
        return _color;
    }

    public function setFilters(filters:Vector.<Function>):void {
        _filters = filters;
    }

    public function getFilters():Vector.<Function> {
        return _filters;
    }

    public function setClickFilters(filters:Vector.<Class>):void {
        this._clickFilters = filters;
    }

    public function getClickFilters():Vector.<Class> {
        return _clickFilters;
    }

    private function drawScrollBar() {
        if (_scrollBar != null) {
            var listHeight:Number = getHeight();
            var rectHeight:Number = _list.scrollRect.height;
            if (listHeight > rectHeight) {
                var height:Number = rectHeight * (rectHeight / listHeight);

                _scrollBar.graphics.clear();
                _scrollBar.graphics.beginFill(0x0E0E0E, 0.5);
                _scrollBar.graphics.drawRoundRect(0, 0, 6, height, 6);
                _scrollBar.graphics.endFill();

                _scrollBar.y = _list.y + rectHeight * (_list.scrollRect.y / listHeight);
            } else {
                _scrollBar.graphics.clear();
            }
        }
    }

    private function mouseDownHandler(e:MouseEvent):void {
        if (_clickFilters != null) {
            for (var i:int = 0; i < _clickFilters.length; i++) {
                if (e.target is _clickFilters[i]) {
                    return;
                }
            }
        }
        this.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true);
        this.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
        _dragPoint = new Point(e.stageX, e.stageY);

        dispatchEvent(new AppClick(e.target));
    }

    private function mouseMoveHandler(e:MouseEvent):void {
        var currentPoint:Point = new Point(e.stageX, e.stageY);
        var dy:Number = _dragPoint.y - currentPoint.y;
        scrollBox(dy);
        _dragPoint = currentPoint;
    }

    private function mouseUpHandler(e:MouseEvent):void {
        this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
        this.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
    }

    private function mouseWheelHandler(e:MouseEvent):void {
        var delta:Number = -e.delta * 2;
        if (Statuses.isWindows()) {
            delta *= 4;
        }
        scrollBox(delta);
    }

    private function hasHeader():Boolean {
        return (_header != null);
    }

    private function hasScrollBar():Boolean {
        return (_scrollBar != null);
    }
}
}
