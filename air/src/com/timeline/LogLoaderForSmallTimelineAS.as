/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.07.08.
 * Time: 12:04
 * To change this template use File | Settings | File Templates.
 */
package com.timeline {
import com.ui.TopBar;

import flash.display.Bitmap;

import flash.display.Sprite;
import flash.geom.Rectangle;

public class LogLoaderForSmallTimelineAS extends Sprite {

    [Embed(source='../../../assets/images/Layout pngs/timeline.png')]
    var timelinePNG:Class;
    [Embed(source='../../../assets/images/Layout pngs/timeline_start.png')]
    var timelineStartPNG:Class;
    [Embed(source='../../../assets/images/Layout pngs/timeline_end.png')]
    var timelineEndPNG:Class;

    private const WIDTH:Number = TopBar.logReplayWidth - LogReplayControlsAS.controllsWidth + 3;

    private var _currentState:String = "not_loading";

    public function LogLoaderForSmallTimelineAS() {
        this.alpha = 0.5;

        var bg:Sprite = new Sprite();
        bg.graphics.beginBitmapFill((new timelinePNG() as Bitmap).bitmapData);
        bg.graphics.drawRect(0, 0, WIDTH - 18, 9);
        bg.graphics.endFill();
        bg.x = 9;

        var bgBegin:Bitmap = new Bitmap((new timelineStartPNG() as Bitmap).bitmapData);
        bgBegin.width = 9;
        bgBegin.height = 9;

        var bgEnd:Bitmap = new Bitmap((new timelineEndPNG() as Bitmap).bitmapData);
        bgEnd.x = WIDTH - 9;
        bgEnd.width = 9;
        bgEnd.height = 9;

        this.addChild(bgBegin);
        this.addChild(bg);
        this.addChild(bgEnd);

        this.cacheAsBitmap = true;
        this.scrollRect = new Rectangle(0,0, 0,9);
    }

    public function setProgress(percent:Number):void {
        this.scrollRect = new Rectangle(0,0, percent*WIDTH,9);
    }

    public  function setCurrentState(state:String):void {
        _currentState = state;
        if (state == "not_loading") {
            this.visible = false;
        } else if (state == "bg_loading" || state == "loading") {
            this.visible = true;
        }
    }

    public  function set currentState(state:String):void {
        setCurrentState(state);
    }

    public  function get currentState():String {
        return _currentState;
    }
}
}
