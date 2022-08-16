package com.sailing.datas {
import com.sailing.units.Direction;
import com.sailing.units.Humidity;
import com.sailing.units.Pressure;
import com.sailing.units.Temperature;
import com.sailing.units.Unit;
import com.sailing.units.WindSpeed;

public class Mda  extends BaseSailData{
    public var barometricPressure:Pressure = new Pressure();
    public var airTemp:Temperature = new Temperature();
    public var waterTemp:Temperature = new Temperature();
    public var relativeHumidity:Humidity = new Humidity();
    public var absoluteHumidity:Humidity = new Humidity();
    public var dewPoint:Temperature = new Temperature();
    public var windDirection:Direction = new Direction();
    public var windSpeed:WindSpeed = new WindSpeed();

    public function Mda() {
        super();
        _paramsDisplayName["barometricPressure"] = { displayName: "Barometric pressure", order: 0 };
        _paramsDisplayName["airTemp"] = { displayName: "Air temperature", order: 1 };
        _paramsDisplayName["waterTemp"] = { displayName: "Water temperature", order: 2 };
        _paramsDisplayName["relativeHumidity"] = { displayName: "Relative humidity", order: 3 };
        _paramsDisplayName["absoluteHumidity"] = { displayName: "Absolute humidity", order: 4 };
        _paramsDisplayName["dewPoint"] = { displayName: "Dew point", order: 5 };
        _paramsDisplayName["windDirection"] = { displayName: "Wind direction", order: 6 };
        _paramsDisplayName["windSpeed"] = { displayName: "Wind speed", order: 7 };
    }

    public override function get displayName():String {
        return "Meteorological Composite (MDA)";
    }
}
}