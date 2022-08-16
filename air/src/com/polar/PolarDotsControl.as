/**
 * Created by seamantec on 07/07/14.
 */
package com.polar {

import com.common.AppProperties;
import com.sailing.split;
import com.harbor.CloudHandler;
import com.seamantec.LicenseEvent;
import com.utils.StringUtils;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.net.FileFilter;

public class PolarDotsControl {

    public static const MIN_WIND:uint = 1;

    private var _instrument:MovieClip;
    private var _dish:PolarDotsDish;

    private var _windSpeed:Number = 0;
    private var _prevWindSpeed:Number = 0;

    // 0 - nincs load
    // 1 - éppen load
    // 2 - van load
    private var _load:int = 0;
    private var _hasCloud = false;

    public function PolarDotsControl(instrument:MovieClip, dish:PolarDotsDish) {
        _instrument = instrument;
        _dish = dish;

        toLabel(PolarContainer.instance.polarTableName);
        setChangedText();
        _instrument.load_label.mouseEnabled = false;
        disableButtons();

        _dish.activateAll();
        buttonEnable(_instrument.auto_btn, false);
        buttonEnable(_instrument.down_btn, false);

        setPolarSaveButton();

        _instrument.auto_btn.addEventListener(MouseEvent.CLICK, autoBtnHandler, false, 0, true);
        _instrument.down_btn.addEventListener(MouseEvent.CLICK, downBtnHandler, false, 0, true);
        _instrument.up_btn.addEventListener(MouseEvent.CLICK, upBtnHandler, false, 0, true);

        _instrument.load_polar.addEventListener(MouseEvent.CLICK, loadPolarBtnHandler, false, 0, true);
        _instrument.save_polar.addEventListener(MouseEvent.CLICK, savePolarBtnHandler, false, 0, true);

        _instrument.load_label.addEventListener(MouseEvent.CLICK, loadCloudBtnHandler, false, 0, true);
        _instrument.PC_load.addEventListener(MouseEvent.CLICK, loadCloudBtnHandler, false, 0, true);
        _instrument.PC_save.addEventListener(MouseEvent.CLICK, saveCloudBtnHandler, false, 0, true);
        _instrument.PC_clear.addEventListener(MouseEvent.CLICK, clearCloudBtnHandler, false, 0, true);

        PolarContainer.instance.addEventListener(PolarEvent.POLAR_EVENT, enableLiveDataHandler, false, 0, true);
        PolarContainer.instance.addEventListener(PolarEvent.POLAR_FILE_LOADED, polarReadyHandler, false, 0, true);
        PolarContainer.instance.addEventListener("enablePolar", enablePolarHandler, false, 0, true);
        PolarContainer.instance.addEventListener("disablePolar", disablePolarHandler, false, 0, true);
        PolarContainer.instance.addEventListener("savePolar", savePolarHandler, false, 0, true);
        PolarContainer.instance.addEventListener(PolarCloudLoadEvent.POLAR_CLOUD_LOAD, loadPolarCloudHandler, false, 0, true);

        AppProperties.licenseManager.addEventListener(LicenseEvent.ACTIVATED, licenceManagerHandler, false, 0, true);
        AppProperties.licenseManager.addEventListener(LicenseEvent.DEACTIVATED, licenceManagerHandler, false, 0, true);
    }

    private function setFilter(all:Boolean):void {
        if (_windSpeed != _prevWindSpeed) {
            if(all) {
                _dish.activateAll();
                _instrument.maxWind.digi_a.text = "--";
            } else {
                _dish.setFilter(_windSpeed);
                _instrument.maxWind.digi_a.text = split.withValue(_windSpeed).a02;
            }
            _prevWindSpeed = _windSpeed;
        }
    }

    private function autoBtnHandler(event:MouseEvent):void {
        if(_load==0) {
            _dish.removeForceDotsAtLayer();
        } else if(_windSpeed!=0) {
            _dish.autoArrange();
        }
    }

    private function downBtnHandler(event:MouseEvent):void {
        if (_windSpeed > 0) {
            _windSpeed--;
            setFilter(_windSpeed==0);
            buttonEnable(_instrument.auto_btn, _windSpeed!=0);
            buttonEnable(_instrument.down_btn, _windSpeed!=0);
            buttonEnable(_instrument.up_btn, true);
        }
    }

    private function upBtnHandler(event:MouseEvent):void {
        if (_windSpeed < (PolarTable.MAX_WINDSPEED - 1)) {
            _windSpeed++;
            setFilter(false);
            buttonEnable(_instrument.auto_btn, true);
            buttonEnable(_instrument.down_btn, true);
            buttonEnable(_instrument.up_btn, _windSpeed!=(PolarTable.MAX_WINDSPEED - 1));
        }
    }

    private function loadPolarBtnHandler(event:MouseEvent):void {
        PolarContainer.instance.loadFromFile();
    }

    private function savePolarBtnHandler(event:MouseEvent):void {
        if(_instrument.save_polar.enabled) {
            PolarContainer.instance.exportToFile();
        }
    }

    private function loadCloudBtnHandler(event:MouseEvent):void {
        if(_load!=1) {
            var doc:File = File.desktopDirectory;
            doc.browseForOpen("Open polar cloud", [new FileFilter("Polar cloud", "*.flh;*.nmea;*.txt;*.*")]);
            doc.addEventListener(Event.SELECT, docSelectHandler, false, 0, true);
        }
    }

    private function saveCloudBtnHandler(event:MouseEvent):void {
        if(_instrument.PC_save.enabled) {
            PolarContainer.instance.dataContainer.saveToFile();
        }
    }

    private function clearCloudBtnHandler(event:MouseEvent):void {
        if(_instrument.PC_clear.enabled) {
            PolarContainer.instance.resetContainer();
            _load = 0;
            _hasCloud = false;
        }
    }

    private function docSelectHandler(event:Event):void {
        var file:File = event.target as File;
        if (file.extension===PolarDataContainer.FILE_EXTENSION) {
            PolarContainer.instance.dataContainer.loadFile(file);
        } else {
            PolarContainer.instance.loadFromNmea(file);
        }
    }

    private function polarReadyHandler(event:PolarEvent):void {
        toLabel(PolarContainer.instance.polarTableName);
        setChangedText();
    }

    private function disablePolarHandler(e:Event) {
        disableButtons();
    }

    private function savePolarHandler(e:Event) {
        toLabel(PolarContainer.instance.polarTableName);
    }

    private function disableButtons():void {
        disableSaveAndClear();
        _instrument.load_label.text = "Load";
    }

    private function enableLiveDataHandler(e:Event) {
        _hasCloud = true;
    }

    private function enablePolarHandler(e:Event) {
        if(_load!=1) {
            if(_hasCloud) {
                enableSaveAndClear();
                _instrument.load_label.text = "Merge";
            } else {
                _instrument.load_label.text = "Load";
            }
        }
    }

    private function disableSaveAndClear():void {
        buttonEnable(_instrument.PC_save, false);
        buttonEnable(_instrument.PC_clear, false);
    }

    private function enableSaveAndClear():void {
        buttonEnable(_instrument.PC_save, true);
        buttonEnable(_instrument.PC_clear, true);
    }

    private function loadPolarCloudHandler(e:PolarCloudLoadEvent):void {
        switch(e.getType()) {
            case 0:
                _load = 1;
                var value:String = Math.floor(e.getData()) + "%";
                if (value.length == 2) {
                    value = "  " + value;
                } else if (value.length == 3) {
                    value = " " + value;
                }
                buttonEnable(_instrument.PC_load, false);
                _instrument.load_label.text = value;
                disableSaveAndClear();
                break;
            case 1:
                if(e.getData()==0) {
                    PolarContainer.instance.dispatchEvent(new Event("polar-cloud-empty"));
                    buttonEnable(_instrument.PC_load, true);
                    if(_hasCloud) {
                        _instrument.load_label.text = "Merge";
                        enableSaveAndClear();
                        _load = 2;
                    } else {
                        _instrument.load_label.text = "Load";
                        _load = 0;
                    }
                } else {
                    _load = 2;
                    _hasCloud = true;
                    buttonEnable(_instrument.PC_load, true);
                    _instrument.load_label.text = "Merge";
                    enableSaveAndClear();
                }
                break;
            default:
                break;
        }
    }

    private function licenceManagerHandler(event:LicenseEvent):void {
        setPolarSaveButton();
    }

    private function setPolarSaveButton():void {
        buttonEnable(_instrument.save_polar, AppProperties.hasComHobbyLicense())
    }

    private function toLabel(text:String):void {
        text = StringUtils.replace(text);
        _instrument.polar_name.text = "";
        var width:Number = 0;
        for(var i:int=1; i<=text.length; i++) {
            _instrument.polar_name.text = text.substr(0, i);
            if(_instrument.polar_name.textWidth==width) {
                _instrument.polar_name.text = text.substr(0, i-4) + "...";
                return;
            }
            width = _instrument.polar_name.textWidth;
        }
    }

    private function buttonEnable(button:Object, enable:Boolean):void {
        button.enabled = enable;
        button.alpha = (enable) ? 1 : 0.25;
    }

    private function setChangedText():void {
        if(PolarContainer.instance.isChanged) {
            _instrument.polar_name.text += "*";
        }
    }
}
}
