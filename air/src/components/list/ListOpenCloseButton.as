/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 18/12/13
 * Time: 15:07
 * To change this template use File | Settings | File Templates.
 */
package components.list {
import flash.display.Bitmap;
import flash.display.Sprite;

public class ListOpenCloseButton extends Sprite {

    [Embed(source="../../../assets/images/ais/closeState.png")]
    private static var closeState:Class;
    private var closeBitmap:Bitmap = new closeState();

    [Embed(source="../../../assets/images/ais/openState.png")]
    private static var openState:Class;
    private var openBitmap:Bitmap = new openState();

    private var _isOpen:Boolean = false

    public function ListOpenCloseButton() {
        this.addChild(closeBitmap);
        this.addChild(openBitmap);
        resetStates()
    }

    public function get isOpen():Boolean {
        return _isOpen;
    }

    public function set isOpen(value:Boolean):void {
        _isOpen = value;
        resetStates();
    }

    private function resetStates():void {
        if(_isOpen) {
            closeBitmap.visible = false;
            openBitmap.visible = true;
        } else {
            closeBitmap.visible = true;
            openBitmap.visible = false;
        }
    }
}
}
