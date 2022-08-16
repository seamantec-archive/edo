/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.27.
 * Time: 15:14
 * To change this template use File | Settings | File Templates.
 */
package components.alarm {
import com.alarm.Alarm;
import com.alarm.AlarmHandler;
import com.ui.controls.AlarmListSmallBtn;
import com.ui.controls.Knob;

import components.ToggleButton;
import components.list.List;

import flash.events.Event;

public class AlarmList extends List {

    private var _activeFilter:Vector.<Function>;
    private var _clickFilters:Vector.<Class>;

    public function AlarmList() {
        super(0,0, AlarmWindow.WIDTH,AlarmWindow.HEIGHT);
        this.addScrollBar();

        _activeFilter = new Vector.<Function>();
        _activeFilter.push(activeFilter);

        _clickFilters = new Vector.<Class>();
        _clickFilters.push(AlarmListSmallBtn);
        _clickFilters.push(Knob);
        _clickFilters.push(ToggleButton);
        this.setClickFilters(_clickFilters);
    }


    public function addView(view:AlarmView):void {
        this.addItem(view);
    }

    public function activeAlarms(toTop:Boolean = true):void {
        this.setFilters(_activeFilter);
        this.filter(_activeFilter);
        if(toTop) {
            this.scrollToTop();
        } else {
            this.scrollBox(0);
        }
    }

    public function allAlarms():void {
        this.setFilters(null);
        this.filter(null);
        this.scrollToTop();
    }

    public function refreshList():void {
        this.removeAllItem();
        addAlarmList();
        if(!isActiveState()) {
            allAlarms();
        } else {
            activeAlarms();
        }
    }

    private function addAlarmList() {
        for (var i:int = 0; i < AlarmHandler.instance.alarmsSize; i++) {
            var alarm:Alarm = AlarmHandler.instance.alarms[AlarmHandler.instance.orderedAlarms[i]] as Alarm;
            addView(new AlarmView(alarm.toString()));
        }
    }

    public function isActiveState():Boolean {
        return this.getFilters()!=null;
    }


    public function resizeList(w:Number, h:Number):void {
        super.resize(w, h);

        for(var i:int=0; i<this.length; i++) {
            (getItem(i) as AlarmView).externalResize(w);
        }
    }


    private function activeFilter(item:AlarmView):Boolean {
        return item.enabled();
    }

    public function startCustomResize():void {
        dispatchEvent(new Event("startResize"));
    }

    public function stopResize():void {
        dispatchEvent(new Event("stopResize"));
    }

}
}
