/**
 * Created by seamantec on 21/02/14.
 */
package components.settings {
import com.events.AppClick;
import com.events.UnitChangedEvent;
import com.sailing.WindowsHandler;
import com.sailing.units.Depth;
import com.sailing.units.Direction;
import com.sailing.units.Distance;
import com.sailing.units.SmallDistance;
import com.sailing.units.Speed;
import com.sailing.units.Temperature;
import com.sailing.units.UnitHandler;
import com.sailing.units.WindSpeed;
import com.ui.controls.LongDropDownButton;
import com.ui.controls.ShortDropDownButton;
import com.utils.FontFactory;

import components.list.DynamicListItem;
import components.list.List;

import flash.text.TextField;

public class UnitSettings extends DynamicListItem {

    [Embed(source="../../../assets/images/msglist/closedlist_element.png")]
    private static var closed:Class;

    private static var _distanceLabel:TextField;
    private static var _distanceDropDown:SettingsDropdown;
    private static var _smallDistanceLabel:TextField;
    private static var _smallDistanceDropDown:SettingsDropdown;
    private static var _depthLabel:TextField;
    private static var _depthDropDown:SettingsDropdown;
    private static var _speedLabel:TextField;
    private static var _speedDropDown:SettingsDropdown;
    private static var _windLabel:TextField;
    private static var _windDropDown:SettingsDropdown;
    private static var _temperatureLabel:TextField;
    private static var _temperatureDropDown:SettingsDropdown;
    private static var _directionLabel:TextField;
    private static var _directionDropDown:SettingsDropdown;
    private static var _directionInfoLabel:TextField;

    public function UnitSettings(list:List) {
        super(SettingsWindow.WIDTH, SettingsWindow.ITEM_HEIGHT, list);

        this.graphics.beginBitmapFill(new closed().bitmapData);
        this.graphics.drawRect(0, 0, SettingsWindow.WIDTH, SettingsWindow.ITEM_HEIGHT);
        this.graphics.endFill();

        addLabel("Units", FontFactory.nmeaMSGfont(), 2, 2);

        createContent();
        initUnits();

        UnitHandler.instance.addEventListener(UnitChangedEvent.CHANGE, unitChangeHandler, false, 0, true);
        WindowsHandler.instance.application.addEventListener(AppClick.APP_CLICK, appClickHandler, false, 0, true);
        list.addEventListener(AppClick.APP_CLICK, appClickHandler, false, 0, true);
    }

    private function createContent():void {
        addDistance();
        addSmallDistance();
        addDepth();
        addSpeed();
        addWind();
        addTemperature();
        addDirection();
        _content.graphics.beginFill(0x3c3c3c);
        _content.graphics.drawRect(0, 0, this.width, this.height);
        _content.graphics.endFill();
    }

    private function initUnits():void {
        setDistanceUnit();
        setSmallDistanceUnit();
        setDepthUnit();
        setSpeedUnit();
        setWindUnit();
        setTemperatureUnit();
        setDirectionUnit();
    }

    private function addDistance():void {
        if (_distanceLabel == null) {
            _distanceLabel = FontFactory.getRightTextField();
            _distanceLabel.x = 95;
            _distanceLabel.y = 20;
            _distanceLabel.text = "Distance";
        }
        addContentChild(_distanceLabel);

        if (_distanceDropDown == null) {
            _distanceDropDown = new SettingsDropdown(SettingsDropdown.TYPE_LONG, this, 4);
            _distanceDropDown.x = 110;
            _distanceDropDown.y = 20;
            _distanceDropDown.addElement("nautical mile (nm)", Distance.NM);
            _distanceDropDown.addElement("statute mile (mi)", Distance.MILE);
            _distanceDropDown.addElement("kilometer (km)", Distance.KM);
            _distanceDropDown.addElement("meter (m)", Distance.METER);
            _distanceDropDown.addEventListener(SettingsDropdownEvent.SELECT, distanceHandler, false, 0, true);
        }
        addContentChild(_distanceDropDown);
    }


    private function distanceHandler(event:SettingsDropdownEvent):void {
        UnitHandler.instance.distance = event.data;
        setDistanceUnit();
    }

    private function setDistanceUnit():void {
        switch (UnitHandler.instance.distance) {
            case Distance.NM:
                _distanceDropDown.label = "nautical mile (nm)";
                break;
            case Distance.MILE:
                _distanceDropDown.label = "statute mile (mi)";
                break;
            case Distance.KM:
                _distanceDropDown.label = "kilometer (km)";
                break;
            case Distance.METER:
                _distanceDropDown.label = "meter (m)";
                break;
            default:
                UnitHandler.instance.distance = Distance.NM;
                _distanceDropDown.label = "nautical mile (nm)";
                break;
        }
    }

    private function addSmallDistance():void {
        if (_smallDistanceLabel == null) {
            _smallDistanceLabel = FontFactory.getRightTextField();
            _smallDistanceLabel.x = 95;
            _smallDistanceLabel.y = 50;
            _smallDistanceLabel.text = "Small Distance";
        }
        addContentChild(_smallDistanceLabel);

        if (_smallDistanceDropDown == null) {
            _smallDistanceDropDown = new SettingsDropdown(SettingsDropdown.TYPE_LONG, this, 2);
            _smallDistanceDropDown.x = 110;
            _smallDistanceDropDown.y = 50;
            _smallDistanceDropDown.addElement("meter (m)", SmallDistance.METER);
            _smallDistanceDropDown.addElement("foot (ft)", SmallDistance.FEET);
            _smallDistanceDropDown.addEventListener(SettingsDropdownEvent.SELECT, smallDistanceHandler, false, 0, true);
        }
        addContentChild(_smallDistanceDropDown);
    }

    private function smallDistanceHandler(event:SettingsDropdownEvent):void {
        UnitHandler.instance.smallDistance = event.data;
        setSmallDistanceUnit();
    }

    private function setSmallDistanceUnit():void {
        switch (UnitHandler.instance.smallDistance) {
            case SmallDistance.METER:
                _smallDistanceDropDown.label = "meter (m)";
                break;
            case Distance.FEET:
                _smallDistanceDropDown.label = "foot (ft)";
                break;

            default:
                UnitHandler.instance.smallDistance = SmallDistance.METER;
                _smallDistanceDropDown.label = "meter (m)";
                break;
        }
    }

    private function addDepth():void {
        if (_depthLabel == null) {
            _depthLabel = FontFactory.getRightTextField();
            _depthLabel.x = 95;
            _depthLabel.y = 80;
            _depthLabel.text = "Water depth";
        }
        addContentChild(_depthLabel);

        if (_depthDropDown == null) {
            _depthDropDown = new SettingsDropdown(SettingsDropdown.TYPE_LONG, this, 3);
            _depthDropDown.x = 110;
            _depthDropDown.y = 80;
            _depthDropDown.addElement("meter (m)", Depth.METER);
            _depthDropDown.addElement("foot (ft)", Depth.FEET);
            _depthDropDown.addElement("fathom (ftm)", Depth.FATHOM);
            _depthDropDown.addEventListener(SettingsDropdownEvent.SELECT, depthHandler, false, 0, true);
        }
        addContentChild(_depthDropDown);
    }

    private function depthHandler(event:SettingsDropdownEvent):void {
        UnitHandler.instance.depth = event.data;
        setDepthUnit();
    }

    private function setDepthUnit():void {
        switch (UnitHandler.instance.depth) {
            case Depth.METER:
                _depthDropDown.label = "meter (m)";
                break;
            case Depth.FEET:
                _depthDropDown.label = "foot (ft)";
                break;
            case Depth.FATHOM:
                _depthDropDown.label = "fathom (ftm)";
                break;
            default:
                UnitHandler.instance.depth = Depth.METER;
                _depthDropDown.label = "meter (m)";
                break;
        }
    }

    private function addSpeed():void {
        if (_speedLabel == null) {
            _speedLabel = FontFactory.getRightTextField();
            _speedLabel.x = 95;
            _speedLabel.y = 110;
            _speedLabel.text = "Boat speed";
        }
        addContentChild(_speedLabel);

        if (_speedDropDown == null) {
            _speedDropDown = new SettingsDropdown(SettingsDropdown.TYPE_LONG, this, 4);
            _speedDropDown.x = 110;
            _speedDropDown.y = 110;
            _speedDropDown.addElement("knot (kn)", Speed.KTS);
            _speedDropDown.addElement("miles per hour (mph)", Speed.MPH);
            _speedDropDown.addElement("kilometers per hour (km/h)", Speed.KMH);
            _speedDropDown.addElement("meter per second (m/s)", Speed.MS);
            _speedDropDown.addEventListener(SettingsDropdownEvent.SELECT, speedHandler, false, 0, true);
        }
        addContentChild(_speedDropDown);
    }

    private function speedHandler(event:SettingsDropdownEvent):void {
        UnitHandler.instance.speed = event.data;
        setSpeedUnit();
    }

    private function setSpeedUnit():void {
        switch (UnitHandler.instance.speed) {
            case Speed.KTS:
                _speedDropDown.label = "knot (kn)";
                break;
            case Speed.MPH:
                _speedDropDown.label = "miles per hour (mph)";
                break;
            case Speed.KMH:
                _speedDropDown.label = "kilometers per hour (km/h)";
                break;
            case Speed.MS:
                _speedDropDown.label = "meter per second (m/s)";
                break;
            default:
                UnitHandler.instance.speed = Speed.KTS;
                _speedDropDown.label = "knot (kn)";
                break;
        }
    }

    private function addWind():void {
        if (_windLabel == null) {
            _windLabel = FontFactory.getRightTextField();
            _windLabel.x = 95;
            _windLabel.y = 140;
            _windLabel.text = "Wind speed";
        }
        addContentChild(_windLabel);

        if (_windDropDown == null) {
            _windDropDown = new SettingsDropdown(SettingsDropdown.TYPE_LONG, this, 5);
            _windDropDown.x = 110;
            _windDropDown.y = 140;
            _windDropDown.addElement("knot (kn)", WindSpeed.KTS);
            _windDropDown.addElement("miles per hour (mph)", WindSpeed.MPH);
            _windDropDown.addElement("kilometers per hour (km/h)", WindSpeed.KMH);
            _windDropDown.addElement("meter per second (m/s)", WindSpeed.MS);
            _windDropDown.addElement("beaufort (bft)", WindSpeed.BF);
            _windDropDown.addEventListener(SettingsDropdownEvent.SELECT, windHandler, false, 0, true);
        }
        addContentChild(_windDropDown);
    }

    private function windHandler(event:SettingsDropdownEvent):void {
        UnitHandler.instance.windSpeed = event.data;
        setWindUnit();
    }

    private function setWindUnit():void {
        switch (UnitHandler.instance.windSpeed) {
            case WindSpeed.KTS:
                _windDropDown.label = "knot (kn)";
                break;
            case WindSpeed.MPH:
                _windDropDown.label = "miles per hour (mph)";
                break;
            case WindSpeed.KMH:
                _windDropDown.label = "kilometers per hour (km/h)";
                break;
            case WindSpeed.MS:
                _windDropDown.label = "meter per second (m/s)";
                break;
            case WindSpeed.BF:
                _windDropDown.label = "Beaufort (bft)";
                break;
            default:
                UnitHandler.instance.windSpeed = WindSpeed.KTS;
                _windDropDown.label = "knot (kn)";
                break;
        }
    }

    private function addTemperature():void {
        if (_temperatureLabel == null) {
            _temperatureLabel = FontFactory.getRightTextField();
            _temperatureLabel.x = 95;
            _temperatureLabel.y = 170;
            _temperatureLabel.text = "Temperature";
        }
        addContentChild(_temperatureLabel);

        if (_temperatureDropDown == null) {
            _temperatureDropDown = new SettingsDropdown(SettingsDropdown.TYPE_LONG, this, 2);
            _temperatureDropDown.x = 110;
            _temperatureDropDown.y = 170;
            _temperatureDropDown.addElement("Celsius (°C)", Temperature.CELSIUS);
            _temperatureDropDown.addElement("Fahrenheit (°F)", Temperature.FAHRENHEIT);
            _temperatureDropDown.addEventListener(SettingsDropdownEvent.SELECT, temperatureHandler, false, 0, true);
        }
        addContentChild(_temperatureDropDown);
    }

    private function temperatureHandler(event:SettingsDropdownEvent):void {
        UnitHandler.instance.temperature = event.data;
        setTemperatureUnit();
    }

    private function setTemperatureUnit():void {
        switch (UnitHandler.instance.temperature) {
            case Temperature.CELSIUS:
                _temperatureDropDown.label = "Celsius (°C)";
                break;
            case Temperature.FAHRENHEIT:
                _temperatureDropDown.label = "Fahrenheit (°F)";
                break;
            default:
                UnitHandler.instance.temperature = Temperature.CELSIUS;
                _temperatureDropDown.label = "Celsius (°C)";
                break;
        }
    }

    private function addDirection():void {
        if (_directionLabel == null) {
            _directionLabel = FontFactory.getRightTextField();
            _directionLabel.x = 95;
            _directionLabel.y = 200;
            _directionLabel.text = "North reference";
        }
        addContentChild(_directionLabel);

        if (_directionDropDown == null) {
            _directionDropDown = new SettingsDropdown(SettingsDropdown.TYPE_LONG, this, 2);
            _directionDropDown.x = 110;
            _directionDropDown.y = 200;
            _directionDropDown.addElement("True", Direction.TRUE);
            _directionDropDown.addElement("Magnetic", Direction.MAGNETIC);
            _directionDropDown.addEventListener(SettingsDropdownEvent.SELECT, directionHandler, false, 0, true);
        }
        addContentChild(_directionDropDown);

        if (_directionInfoLabel == null) {
            _directionInfoLabel = FontFactory.getCustomFont({ color: 0xff0000, size: 12, bold: true });
            _directionInfoLabel.x = 40;
            _directionInfoLabel.y = 230;
            _directionInfoLabel.height = 20;
            _directionInfoLabel.text = "";
        }
        _directionInfoLabel.visible = (UnitHandler.instance.direction == Direction.FORCED_MAGNETIC);
        addContentChild(_directionInfoLabel);
    }

    private function directionHandler(event:SettingsDropdownEvent):void {
        UnitHandler.instance.direction = event.data;
        Direction.checkVariation();
        setDirectionUnit();
    }

    private function setDirectionUnit():void {
        switch (UnitHandler.instance.direction) {
            case Direction.TRUE:
                _directionDropDown.label = "True";
                _directionDropDown.color = 0xc9c9c9;
                _directionInfoLabel.visible = false;
                break;
            case Direction.MAGNETIC:
                _directionDropDown.label = "Magnetic";
                _directionDropDown.color = 0xc9c9c9;
                _directionInfoLabel.visible = false;
                break;
            case Direction.FORCED_MAGNETIC:
                _directionDropDown.label = "Magnetic";
                _directionDropDown.color = 0xff0000;
                _directionInfoLabel.visible = true;
                break;
            default:
                UnitHandler.instance.direction = Direction.MAGNETIC;
                _directionDropDown.label = "Magnetic";
                _directionDropDown.color = 0xc9c9c9;
                _directionInfoLabel.visible = false;
                break;
        }
    }

    private function unitChangeHandler(e:UnitChangedEvent):void {
        if (e.typeKlass == Direction) {
            setDirectionUnit();
        }
    }

    public function hideLists():void {
        _distanceDropDown.hideList();
        _depthDropDown.hideList();
        _speedDropDown.hideList();
        _windDropDown.hideList();
        _temperatureDropDown.hideList();
        _directionDropDown.hideList();
    }

    private function appClickHandler(event:AppClick):void {
        if (!(event.prevTarget is ShortDropDownButton) && !(event.prevTarget is LongDropDownButton) && !(event.prevTarget is SettingsDropdownItem) && !(event.prevTarget.parent is SettingsDropdownItem)) {
            hideLists();
        }
        isParent(event.prevTarget);
    }

    private function isParent(target:Object):void {
        while (target.parent != null) {
            if (target.parent is LogbookSettings) {
                (_list.getItem(1) as UnitSettings).hideLists();
                break;
            }
            if (target.parent is UnitSettings) {
                (_list.getItem(5) as LogbookSettings).hideLists();
                break;
            }
            target = target.parent;
        }
    }

}
}
