/**
 * Created by pepusz on 2014.07.17..
 */
package components.graph.custom {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;

public class GraphFrame extends Sprite {
    [Embed(source="../../../../assets/images/alarmlist/graphw_top.png")]
    protected static var windowTopP:Class;
    [Embed(source="../../../../assets/images/alarmlist/graphw_bottom.png")]
    protected static var windowBottomP:Class;
    [Embed(source="../../../../assets/images/alarmlist/graphw_left.png")]
    protected static var windowLeftP:Class;
    [Embed(source="../../../../assets/images/alarmlist/graphw_right.png")]
    protected static var windowRightP:Class;
    [Embed(source="../../../../assets/images/alarmlist/graphw_topleft.png")]
    protected static var windowTopLeftP:Class;
    [Embed(source="../../../../assets/images/alarmlist/graphw_topright.png")]
    protected static var windowTopRightP:Class;
    [Embed(source="../../../../assets/images/alarmlist/graphw_bottomleft.png")]
    protected static var windowBottomLeftP:Class;
    [Embed(source="../../../../assets/images/alarmlist/graphw_bottomright.png")]
    protected static var windowBottomRightP:Class;


    protected static var bottomBitmapData:BitmapData


    private var _topFrameHeight:int = 0;
    private var _leftFrameWidth:int = 0;
    private var _rightFrameWidth:int = 0;
    protected var bottomFrameHeight:int = 0;


    protected var windowTopLeft:Bitmap;
    protected var windowTopRight:Bitmap;
    protected var windowBottomLeft:Bitmap;
    protected var windowBottomRight:Bitmap;
    protected var windowTopSprite:Sprite;
    protected var windowBottomSprite:Sprite;
    protected var windowLeftSprite:Sprite;
    protected var windowRightSprite:Sprite;
    private var _originWidth:int;
    private var _originHeight:int;

    public function GraphFrame() {
        super();
        initFrameSizes()
    }

    protected function initFrameSizes():void {
        bottomFrameHeight = new windowBottomP().height;
        _topFrameHeight = new windowTopP().height;
        _leftFrameWidth = new windowLeftP().width;
        _rightFrameWidth = new windowRightP().width;
        bottomBitmapData = (new windowBottomP as Bitmap).bitmapData;
    }


    public function get topFrameHeight():* {
        return _topFrameHeight;
    }

    public function setWH(w:int, h:int):void {
        _originHeight = h;
        _originWidth = w;

        repositionElements();
    }

    public function createFrame(w:int, h:int):void {
        _originHeight = h;
        _originWidth = w;
        this.x = 0;
        this.y = 0;

        //corners
        windowTopLeft = new windowTopLeftP();
        windowTopLeft.x = 0;
        windowTopLeft.y = 0;

        windowTopRight = new windowTopRightP();
        windowTopRight.x = _originWidth - windowTopRight.width;
        windowTopRight.y = 0;

        windowBottomLeft = new windowBottomLeftP();
        windowBottomLeft.x = 0;
        windowBottomLeft.y = _originHeight - windowBottomLeft.height;

        windowBottomRight = new windowBottomRightP();
        windowBottomRight.x = _originWidth - windowBottomRight.width + 2;
        windowBottomRight.y = _originHeight - windowBottomRight.height;

        //edge fills

        windowTopSprite = new Sprite();
        windowTopSprite.x = windowTopLeft.width;
        windowTopSprite.y = 0;
        windowTopSprite.graphics.beginBitmapFill((new windowTopP as Bitmap).bitmapData);
        windowTopSprite.graphics.drawRect(0, 0, _originWidth - windowTopLeft.width - windowTopRight.width, topFrameHeight);
        windowTopSprite.graphics.endFill();

        windowLeftSprite = new Sprite();
        windowLeftSprite.x = 0;
        windowLeftSprite.y = windowTopLeft.height;
        windowLeftSprite.graphics.beginBitmapFill((new windowLeftP as Bitmap).bitmapData);
        windowLeftSprite.graphics.drawRect(0, 0, _leftFrameWidth, _originHeight - windowTopLeft.height - windowBottomLeft.height);
        windowLeftSprite.graphics.endFill();

        windowRightSprite = new Sprite();
        windowRightSprite.x = _originWidth - _rightFrameWidth;
        windowRightSprite.y = windowTopLeft.height;
        windowRightSprite.graphics.beginBitmapFill((new windowRightP as Bitmap).bitmapData);
        windowRightSprite.graphics.drawRect(0, 0, _rightFrameWidth, _originHeight - windowTopRight.height - windowBottomRight.height);
        windowRightSprite.graphics.endFill();

        windowBottomSprite = new Sprite();
        redrawBottomFrame();
        this.addChild(windowTopLeft);
        this.addChild(windowTopSprite);
        this.addChild(windowTopRight);
        this.addChild(windowLeftSprite);
        this.addChild(windowRightSprite);
        this.addChild(windowBottomLeft);
        this.addChild(windowBottomSprite);
        this.addChild(windowBottomRight);
        this.cacheAsBitmap = true;
    }

    protected function redrawBottomFrame():void {
        windowBottomSprite.x = windowBottomLeft.width;
        windowBottomSprite.y = _originHeight - bottomFrameHeight;
        windowBottomSprite.graphics.clear();
        windowBottomSprite.graphics.beginBitmapFill(bottomBitmapData);
        windowBottomSprite.graphics.drawRect(0, 0, _originWidth - windowBottomLeft.width - windowBottomRight.width, bottomFrameHeight);
        windowBottomSprite.graphics.endFill();
    }

    internal function repositionElements():void {
        windowTopRight.x = _originWidth - windowTopRight.width;
        windowBottomRight.x = _originWidth - windowBottomRight.width;
        windowBottomRight.y = _originHeight - windowBottomRight.height;
        windowBottomLeft.y = _originHeight - windowBottomLeft.height;
        windowTopSprite.width = _originWidth - windowTopLeft.width - windowTopRight.width;
        redrawBottomFrame();
        windowLeftSprite.height = _originHeight - windowTopLeft.height - windowBottomLeft.height;
        windowRightSprite.x = _originWidth - _rightFrameWidth;
        windowRightSprite.height = _originHeight - windowTopRight.height - windowBottomRight.height;
    }


    public function get leftFrameWidth():int {
        return _leftFrameWidth;
    }


    public function get rightFrameWidth():int {
        return _rightFrameWidth;
    }

}
}
