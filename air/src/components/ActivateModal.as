/**
 * Created by pepusz on 2014.01.07..
 */
package components {
public class ActivateModal extends SpriteVisualElement {
    public function ActivateModal() {
        super();
        drawModal();
    }

    public function drawModal() {
        this.graphics.clear();
        this.graphics.beginFill(0xffffff, 0.9);
       // this.graphics.drawRect(0, 0, AppProperties.screenWidth, AppProperties.screenHeight);

    }
}
}
