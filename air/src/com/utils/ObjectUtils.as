/**
 * Created by pepusz on 2014.06.23..
 */
package com.utils {
import flash.utils.describeType;

public class ObjectUtils {

    public static function getProperties(_obj:*):Array {
        var _properties:Array = new Array();
        try {
            var _description:XMLList = describeType(_obj).variable;
            for (var i:int = _description.length() - 1; i >= 0; i--) {
                _properties.push(_description[i].@name.toString())

            }
            _description = null;
        } catch (e:Error) {
            trace(e.getStackTrace())
        }

        return _properties;
    }

}
}
