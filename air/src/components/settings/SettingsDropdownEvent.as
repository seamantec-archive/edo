/**
 * Created by seamantec on 25/02/14.
 */
package components.settings {
import flash.events.Event;

public class SettingsDropdownEvent extends Event {

    public static const SELECT:String = "selectItem";

    public var data:Number;

    public function SettingsDropdownEvent(data:Number) {
        super(SELECT);
        this.data = data;
    }
}
}
