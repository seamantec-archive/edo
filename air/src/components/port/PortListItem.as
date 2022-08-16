/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 09/12/13
 * Time: 12:43
 * To change this template use File | Settings | File Templates.
 */
package components.port {
import com.sailing.socket.ScannerPort;
import com.ui.controls.AlarmDownBtn;
import com.utils.FontFactory;

import components.list.StaticListItem;

public class PortListItem extends StaticListItem {

    private var _button:AlarmDownBtn;

    public function PortListItem(port:ScannerPort) {
        super(PortWindow.WIDTH,40);

        this.graphics.lineStyle(1, 0xCCCCCC);
        this.graphics.moveTo(0, 40);
        this.graphics.lineTo(PortWindow.WIDTH, 40);
        addLabel(port.type, FontFactory.getLeftBlackTextField(), 10,10);
        addLabel((port.type=="TCP") ? port.ip : port.name, FontFactory.getLeftBlackTextField(), 60,10);
        addLabel((port.type=="TCP") ? port.port.toString() : port.baud.toString(), FontFactory.getLeftBlackTextField(), 160,10);
        _button = new AlarmDownBtn("Connect");
        _button.x = PortWindow.WIDTH - _button.width - 5;
        _button.y = 4;
        addChild(_button);
    }

    public function get button():AlarmDownBtn {
        return _button;
    }
}
}
