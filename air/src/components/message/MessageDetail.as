/**
 * Created by pepusz on 2015. 04. 16..
 */
package components.message {
import flash.text.TextField;

public class MessageDetail {
    public var key:String;
    public var label:TextField;
    public var value:TextField;


    public function MessageDetail(key:String, label:TextField, value:TextField) {
        this.key = key;
        this.label = label;
        this.value = value;
    }
}
}
