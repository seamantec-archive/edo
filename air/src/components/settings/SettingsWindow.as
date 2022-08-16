/**
 * Created by seamantec on 21/02/14.
 */
package components.settings {
import com.events.AppClick;
import com.logbook.LogBookDataHandler;
import com.loggers.LogRegister;
import com.notification.NotificationHandler;
import com.notification.NotificationTypes;
import com.store.SettingsConfigs;
import com.ui.controls.AlarmDownBtn;
import com.ui.controls.Knob;

import components.list.List;
import components.windows.FloatWindow;

import flash.desktop.NativeApplication;
import flash.events.MouseEvent;
import flash.filesystem.File;

public class SettingsWindow extends FloatWindow {

    public static var WIDTH:Number;
    public static var HEIGHT:Number;
    public static const ITEM_HEIGHT:Number = 24;

    private static var _list:List;
    private static var _connectionSettings:ConnectionSettings;
    private static var _unitSettings:UnitSettings;
    private static var _logbookSettings:LogbookSettings;
    private static var _performanceSettings:PerformanceSettings;
    private static var _windCorrectionSettings:WindCorrectionSettings;
    private static var _generalSettings:GeneralSettings;
//    private static var _polarSettings:PolarSettings;

    public function SettingsWindow() {
        super("Settings");
        this.resizeable = false;

        this.addDownButton(2, "Close", okButtonHandler);
        this.addDownButton(1, "Reset", resetClickHandler);

        WIDTH = this.width - _frame.getWidthAndContentDiff();
        HEIGHT = this.height - _frame.getHeightAndContentDiff();

        if (_list == null) {
            _list = new List(0, 0, WIDTH, HEIGHT, 0xaaaaaa, 1);
            _list.addScrollBar();

            var clickFilters:Vector.<Class> = new Vector.<Class>();
            clickFilters.push(Knob);
            clickFilters.push(AlarmDownBtn);
            _list.setClickFilters(clickFilters);

            if (_connectionSettings == null) {
                _connectionSettings = new ConnectionSettings(_list);
                _list.addItem(_connectionSettings);
            }
            if (_unitSettings == null) {
                _unitSettings = new UnitSettings(_list);
                _list.addItem(_unitSettings);
            }
            if (_performanceSettings == null) {
                _performanceSettings = new PerformanceSettings(_list);
                _list.addItem(_performanceSettings);
            }
            if (_windCorrectionSettings == null) {
                _windCorrectionSettings = new WindCorrectionSettings(_list);
                _list.addItem(_windCorrectionSettings);
            }
            if (_generalSettings == null) {
                _generalSettings = new GeneralSettings(_list);
                _list.addItem(_generalSettings);
            }
            if (_logbookSettings == null) {
                _logbookSettings = new LogbookSettings(_list);
                _list.addItem(_logbookSettings);
            }
//            if(_polarSettings==null) {
//                _polarSettings = new PolarSettings(_list);
//                _list.addItem(_polarSettings);
//            }

        } else {
            setConnectionSettings();
            enableLLN();
        }

        _content.addChild(_list);

        this.addEventListener(AppClick.APP_CLICK, appClickHandler, false, 0, true);
    }

    private function okButtonHandler(event:MouseEvent) {
        SettingsConfigs.saveInstance();
        this.close();
    }

    private function appClickHandler(event:AppClick):void {
        _unitSettings.hideLists();
        _logbookSettings.hideLists();
    }

    public function setConnectionSettings():void {
        _connectionSettings.isDemoVersion();
    }

    public function enableLLN():void {
        _performanceSettings.enableLLN();
    }

    private function resetClickHandler(event:MouseEvent):void {
        NotificationHandler.createAlert(NotificationTypes.RESET_EVERYTHING, NotificationTypes.RESET_EVERYTHING_TEXT, 1, reset);
    }

    private function reset():void {
        LogBookDataHandler.instance.closeDb();
        LogRegister.instance.closeDb();
        var file:File = File.applicationStorageDirectory;
      var files:Array =  file.getDirectoryListing()
        for (var i:int = 0; i < files.length; i++) {
            var actualFile:File = files[i];
            if(actualFile.isDirectory){
                actualFile.deleteDirectory(true);
            }else{
                actualFile.deleteFile();
            }
        }
        NativeApplication.nativeApplication.exit();
    }
}
}
