package components.list {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;

public class DynamicListItem extends ListItem {

    protected var _content:Sprite;
    protected var _button:ListOpenCloseButton;
    protected var _downPoint:Point;
    protected var _list:List;

    public function DynamicListItem(width:Number, height:Number, list:List, color:uint = 0xFFFFFF, alpha:Number = 1) {
        super(width, height, color, alpha);
        this._list = list;
        _content = new Sprite();
        _content.y = height;
        _content.visible = false;
        addChild(_content);
        _downPoint = new Point();
        initOpenCloseButton();
        this.addEventListener(MouseEvent.MOUSE_UP, headerHandler, false, 0, true);
        this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
    }

    public function addContentChild(sprite:DisplayObject):void {
        _content.addChild(sprite);
        if (!this.contains(_button) && _content.height > 0) {
            addChild(_button);
        }
    }

    protected function initOpenCloseButton():void {
        _button = new ListOpenCloseButton();
        _button.x = this.width - 30;
        _button.y = (this.height-_button.height)/2;
        _button.addEventListener(MouseEvent.MOUSE_UP, buttonHandler, false, 0, true);
    }

    private function buttonHandler(event:MouseEvent):void {
        var p:Point = new Point(event.stageX, event.stageY);
        if (Math.abs(_downPoint.x - p.x) <= 3 && Math.abs(_downPoint.y - p.y) <= 3) {
            openContent();
        }
    }

    private function headerHandler(event:MouseEvent):void {
        var p:Point = new Point(event.stageX, event.stageY);
        var target:Sprite = event.target as Sprite;
//        if ((Math.abs(_downPoint.x - p.x) <= 3 && Math.abs(_downPoint.y - p.y) <= 3) && (isLabel(event.target) || (target != null && target.parent != this.content && target != _button))) {
        if ((Math.abs(_downPoint.x - p.x) <= 3 && Math.abs(_downPoint.y - p.y) <= 3) && (isLabel(event.target) || !isContent(event.target))) {
            openContent();
        }
    }

    private function isContent(target:Object):Boolean {
        var parent:DisplayObject = target as DisplayObject;
        while(parent!=this) {
            if(parent==_content || parent==_button) {
                return true;
            }
            parent = parent.parent;
        }
        return false;
    }

    private function isLabel(target:Object):Boolean {
        var l:Boolean = false;
        for(var i:int=0; i<_labels.length; i++) {
            l = l || (target==_labels[i]);
        }
        return l;
    }

    private function mouseDownHandler(event:MouseEvent):void {
        _downPoint = new Point(event.stageX, event.stageY);
    }

    protected function openContent():void {
        _button.isOpen = !_button.isOpen;
        stateChange();
        _list.filter(_list.getFilters());
        _list.scrollBox(0);
    }

    public function stateChange():void {
        _content.visible = !_content.visible;
    }

    public function open():void {
        _content.visible = true;
        _button.isOpen = true;
    }

    public function close():void {
        _content.visible = false;
        _button.isOpen = false;

    }

    override public function getHeight():Number {
        if (_content.visible) {
            return this.height;
        } else {
            return this.height - _content.height;
        }
    }

    public function set content(content:Sprite):void {
        _content = content;
    }

    public function get content():Sprite {
        return _content;
    }
}
}
