/**
 * Created by pepusz on 2014.02.08..
 */
package components.logBook {
import com.logbook.LogBookDataHandler;
import com.logbook.LogBookDataHandlerEvent;
import com.logbook.LogBookEntry;
import com.notification.NotificationHandler;
import com.notification.NotificationTypes;
import com.ui.controls.AlarmDownBtn;
import com.utils.FontFactory;

import components.list.List;
import components.windows.FloatWindow;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;

public class LogBookWindow extends FloatWindow {
    private static var _list:List;
    private var _exportBtn:AlarmDownBtn;
    private var _counterTxt:TextField;
    //TODO export
    public function LogBookWindow() {
        super("Logbook");
        if (_list === null) {
            _list = new List(0, 0, this.width - _frame.getWidthAndContentDiff(), this.height - _frame.getHeightAndContentDiff())
            _list.order = sortListByTimestamp
            _list.addScrollBar();
        }
        _exportBtn = this.addDownButton(1, "Export", exportHandler);
        _exportBtn = this.addDownButton(2, "Clear All", clearAllHandler);
        LogBookDataHandler.instance.addEventListener(LogBookDataHandlerEvent.READY_ENTRIES, logbook_entries_readyHandler, false, 0, true);
        LogBookDataHandler.instance.addEventListener(LogBookDataHandlerEvent.START_SELECT_ENTRIES, logbook_entries_start_selectHandler, false, 0, true);
        LogBookDataHandler.instance.addEventListener(LogBookDataHandlerEvent.INSERT_READY, logbook_event_insert_readyHandler, false, 0, true);
        LogBookDataHandler.instance.addEventListener(LogBookDataHandlerEvent.DELETED_ALL_DEMO, logbook_event_deleted_all_demoHandler, false, 0, true);
        LogBookDataHandler.instance.addEventListener(LogBookDataHandlerEvent.COUNTER_CHANGED, logbook_event_counter_changedHandler, false, 0, true);
        _content.addChild(_list);
        initCounterText();
        LogBookDataHandler.instance.getLogBookEntries();
        LogBookDataHandler.instance.countAllElements()

        this.resizeable = false;
        this.addEventListener(Event.CLOSE, closeHandler, false, 0, true);


    }

    protected function initCounterText():void {
        _counterTxt = FontFactory.getLeftBlackTextField();
        _counterTxt.x = 0;
        _counterTxt.y = 20;
        //_frame.windowBottomSprite.addChild(_counterTxt)
    }

    private function exportHandler(event:MouseEvent):void {
        LogBookDataHandler.instance.openSaveFile();
    }

    private function sortListByTimestamp(a:LogBookListItem, b:LogBookListItem) {
        if (a.logBookEntry.timestamp.time < b.logBookEntry.timestamp.time) {
            return -1
        } else if (a.logBookEntry.timestamp.time > b.logBookEntry.timestamp.time) {
            return 1;
        } else {
            return 0
        }
    }


    private function logbook_entries_readyHandler(event:LogBookDataHandlerEvent):void {
        for (var i:int = 0; i < LogBookDataHandler.instance.lastLogBookEntries.length; i++) {
            var i1:LogBookEntry = LogBookDataHandler.instance.lastLogBookEntries[i];
            var listItem:LogBookListItem = new LogBookListItem(i1, _list);

            _list.addItem(listItem);
        }
        setCounterText();
    }

    protected function setCounterText():void {
        _counterTxt.text = "Last " + LogBookDataHandler.instance.lastLogBookEntries.length + " items from " + LogBookDataHandler.instance.allCounter;
    }

    private function logbook_entries_start_selectHandler(event:LogBookDataHandlerEvent):void {
        _list.removeAllItem();
    }

    private function closeHandler(event:Event):void {
        LogBookDataHandler.instance.removeEventListener(LogBookDataHandlerEvent.READY_ENTRIES, logbook_entries_readyHandler);
        LogBookDataHandler.instance.removeEventListener(LogBookDataHandlerEvent.START_SELECT_ENTRIES, logbook_entries_start_selectHandler);
        LogBookDataHandler.instance.removeEventListener(LogBookDataHandlerEvent.INSERT_READY, logbook_event_insert_readyHandler);
        LogBookDataHandler.instance.removeEventListener(LogBookDataHandlerEvent.DELETED_ALL_DEMO, logbook_event_deleted_all_demoHandler);
        LogBookDataHandler.instance.removeEventListener(LogBookDataHandlerEvent.COUNTER_CHANGED, logbook_event_counter_changedHandler);

    }

    private function logbook_event_insert_readyHandler(event:LogBookDataHandlerEvent):void {
        LogBookDataHandler.instance.getLogBookEntries();
        LogBookDataHandler.instance.countAllElements();
    }

    private function logbook_event_deleted_all_demoHandler(event:LogBookDataHandlerEvent):void {
        LogBookDataHandler.instance.getLogBookEntries();
        LogBookDataHandler.instance.countAllElements();

    }

    private function logbook_event_counter_changedHandler(event:LogBookDataHandlerEvent):void {
        setCounterText();
    }

    private function clearAllHandler(event:MouseEvent):void {
        if (LogBookDataHandler.instance.lastLogBookEntries.length > 0) {
            NotificationHandler.createAlert(NotificationTypes.LOGBOOK_CLEAR, NotificationTypes.CLEAR_LOGBOOK, 0, clearAll);
        }

    }

    private function clearAll():void {
        LogBookDataHandler.instance.clearAll()
    }
}
}
