package components.list {
public class StaticListItem extends ListItem {

    public function StaticListItem(width:Number, height:Number, color:uint=0xFFFFFF, alpha:Number=1) {
        super(width,height, color,alpha);
    }

    override public function getHeight():Number {
        return this.height;
    }
}
}
