/**
 * Created by pepusz on 2014.01.07..
 */
package components.windows {
import flash.display.Bitmap;
import flash.display.Sprite;

public class WindowFrame extends Sprite {
    public static const LEFT_VISIBLE_WIDTH:uint = 6;
    public static const RIGHT_VISIBLE_WIDTH:uint = 6;
    public static const TOP_VISIBLE_HEIGHT:uint = 27;
    public static const BOTTOM_VISIBLE_HEIGHT:uint = 43;
    public static const CONTENT_TOP_X_ZERO:uint = 17;
    public static const CONTENT_TOP_Y_ZERO:uint = 35;
    public static const RIGHT_EDGE_WIDTH:uint = 23;


    [Embed(source="../../../assets/images/alarmlist/window_top.png")]
    private static var windowTopP:Class;
    [Embed(source="../../../assets/images/alarmlist/window_bottom.png")]
    private static var windowBottomP:Class;
    [Embed(source="../../../assets/images/alarmlist/window_left.png")]
    private static var windowLeftP:Class;
    [Embed(source="../../../assets/images/alarmlist/window_right.png")]
    private static var windowRightP:Class;
    [Embed(source="../../../assets/images/alarmlist/window_topleft.png")]
    private static var windowTopLeftP:Class;
    [Embed(source="../../../assets/images/alarmlist/window_topright.png")]
    private static var windowTopRightP:Class;
    [Embed(source="../../../assets/images/alarmlist/window_bottomleft.png")]
    private static var windowBottomLeftP:Class;
    [Embed(source="../../../assets/images/alarmlist/window_bottomright.png")]
    private static var windowBottomRightP:Class;


    protected var windowTopLeft:Bitmap;
    protected var windowTopRight:Bitmap;
    protected var windowBottomLeft:Bitmap;
    protected var windowBottomRight:Bitmap;
    public static var windowTopPBitmap:Bitmap = new windowTopP();
    public static var windowBottomPBitmap:Bitmap = new windowBottomP();
    public static var windowLeftPBitmap:Bitmap = new windowLeftP();
    public static var windowRightPBitmap:Bitmap = new windowRightP();
    protected var windowTopSprite:Sprite;
    private var _windowBottomSprite:Sprite;
    protected var windowLeftSprite:Sprite;
    protected var windowRightSprite:Sprite;

    public function WindowFrame(w:uint, h:uint) {
        super();

        drawFrame(w, h);
    }


    public function getSideFramesWidth():uint {
        return LEFT_VISIBLE_WIDTH + RIGHT_VISIBLE_WIDTH;
    }

    public function getWidthAndContentDiff():uint {
        return CONTENT_TOP_X_ZERO + RIGHT_EDGE_WIDTH;
    }

    public function getTopBottomFramesHeight():uint {
        return TOP_VISIBLE_HEIGHT + BOTTOM_VISIBLE_HEIGHT;
    }

    public function getHeightAndContentDiff():uint {
        return CONTENT_TOP_Y_ZERO + 62;
    }

//    public function getSidesRealWidth():uint{
//        return windowRightPBitmap.width+windowLeftPBitmap.width;
//    }
//
//    public function getTopBottomRealHeight():uint{
//        return windowTopPBitmap.height+windowBottomPBitmap.height;
//    }

    public function repositionElements(_w:uint, _h:uint):void {
        windowTopRight.x = _w - 28;
        windowBottomRight.x = _w - 28;
        windowBottomRight.y = _h - 67;
        windowBottomLeft.y = _h - 67;
        drawTopSprite(_w);
        drawBottomSprite(_w);
        _windowBottomSprite.y = _h - 67;
        drawLeftSprite(_h);
        windowRightSprite.x = _w - 28;
        drawRightSprite(_h);
    }


    public function get windowBottomSprite():Sprite {
        return _windowBottomSprite;
    }


    private function drawFrame(width:uint, height:uint):void {
        windowTopLeft = new windowTopLeftP();
        windowTopLeft.x = -2;
        windowTopLeft.y = -3;

        windowTopRight = new windowTopRightP();
        windowTopRight.x = width - windowTopRight.width + 2;
        windowTopRight.y = -3;


        windowBottomLeft = new windowBottomLeftP();
        windowBottomLeft.x = -2;
        windowBottomLeft.y = height - windowBottomLeft.height;

        windowBottomRight = new windowBottomRightP();
        windowBottomRight.x = width - windowBottomRight.width + 2;
        windowBottomRight.y = height - windowBottomRight.height;

        windowTopSprite = new Sprite();
        windowTopSprite.x = windowTopLeft.width - 2;
        windowTopSprite.y = -3;
        drawTopSprite(width);
        windowLeftSprite = new Sprite();
        windowLeftSprite.x = -2;
        windowLeftSprite.y = windowTopLeft.height - 3;
        drawLeftSprite(height);
        windowRightSprite = new Sprite();
        windowRightSprite.x = width - 28;
        windowRightSprite.y = windowTopLeft.height - 3;
        drawRightSprite(height);
        _windowBottomSprite = new Sprite();
        _windowBottomSprite.x = windowBottomLeft.width - 2;
        _windowBottomSprite.y = height - windowBottomLeft.height;
        drawBottomSprite(width);
        this.addChild(windowTopLeft);
        this.addChild(windowTopSprite);
        this.addChild(windowTopRight);
        this.addChild(windowLeftSprite);
        this.addChild(windowRightSprite);
        this.addChild(windowBottomLeft);
        this.addChild(_windowBottomSprite);
        this.addChild(windowBottomRight);
        this.cacheAsBitmap = true;
    }

    private function drawBottomSprite(width:uint):void {
        _windowBottomSprite.graphics.clear();
        _windowBottomSprite.graphics.beginBitmapFill(windowBottomPBitmap.bitmapData);
        _windowBottomSprite.graphics.drawRect(0, 0, width - windowTopLeft.width - windowTopRight.width + 4, windowBottomPBitmap.height);
        _windowBottomSprite.graphics.endFill();
    }

    private function drawRightSprite(height:uint):void {
        windowRightSprite.graphics.clear();
        windowRightSprite.graphics.beginBitmapFill(windowRightPBitmap.bitmapData);
        windowRightSprite.graphics.drawRect(0, 0, windowRightPBitmap.width, height - windowTopRight.height - windowBottomRight.height + 3);
        windowRightSprite.graphics.endFill();
    }

    private function drawLeftSprite(height:uint):void {
        windowLeftSprite.graphics.clear();
        windowLeftSprite.graphics.beginBitmapFill(windowLeftPBitmap.bitmapData);
        windowLeftSprite.graphics.drawRect(0, 0, windowLeftPBitmap.width, height - windowTopLeft.height - windowBottomLeft.height + 3);
        windowLeftSprite.graphics.endFill();
    }

    private function drawTopSprite(width:uint):void {
        windowTopSprite.graphics.clear();
        windowTopSprite.graphics.beginBitmapFill(windowTopPBitmap.bitmapData);
        windowTopSprite.graphics.drawRect(0, 0, width - windowTopLeft.width - windowTopRight.width + 4, windowTopPBitmap.height);
        windowTopSprite.graphics.endFill();
    }
}
}
