/**
 * Created by seamantec on 07/05/14.
 */
package com.common {
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

public class SysConfig {

    private static var _container:Object = null;
    private static var _childContainer:Object = null;
    private static var _item:Object = null;
    private static var _childIitem:Object = null;

    private static var _wasLoad:Boolean = false;

    public static function load(file:File = null):void {
        _wasLoad = true;
        if(file==null) {
            file = File.applicationDirectory.resolvePath("configs/sys.xml");
        }
        if(file.exists) {
            var fileStream:FileStream = new FileStream();
            fileStream.open(file, FileMode.READ);
            fileStream.position = 0;
            var config:XML = new XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
            if(config.name().toString()=="config") {
                _container = parseNode(config);
            } else {
                _container = null;
            }
        } else {
            _container = null;
        }
    }

    private static function parseNode(node:XML):Object {
        var result:Object = new Object();

        var nodes:XMLList = node.elements();
        for(var i=0; i<nodes.length(); i++) {
            var item:XML = nodes[i];
            var key:String = item.name();
            if(item.elements().length()==0) {
                setResult(result, key, item, true);
            } else {
                var data:Object = parseNode(item);
                setResult(result, key, data);
            }
            //trace(key, ":", result[key]);
        }

        return result;
    }

    private static function setResult(result:Object, key:String, item:Object, toString:Boolean = false):void {
        if(result.hasOwnProperty(key)) {
            var value:Object = result[key];
            if(value is Array) {
                (value as Array).push((toString) ? item.toString() : item);
            } else {
                result[key] = new Array((toString) ? value.toString() : value, (toString) ? item.toString() : item);
            }
        } else {
            result[key] = (toString) ? item.toString() : item;
        }
    }

    private static function getObject(node:Object, keys:String):Object {
        if(!_wasLoad) {
            load();
            node = _container;
        }

        if(node==null) {
            return null;
        }

        var p:Array = keys.split(".");
        var key:String = p[0];
        if(key=="*") {
            return node;
        } else {
            if(node.hasOwnProperty(key)) {
                if(p.length>1) {
                    return getObject(node[key], keys.replace(key + ".", ""));
                } else {
                    return node[key];
                }
            }
        }
        return null;
    }

    public static function get container():Object {
        return _container;
    }

    public static function set childContainer(data:Object):void {
        _childContainer = data;
    }

    public static function get childContainer():Object {
        return _childContainer;
    }

    public static function get item():Object {
        return _item;
    }

    public static function get childItem():Object {
        return _childIitem;
    }

    public static function isNull(keys:String):Boolean {
        return (_item = getObject(_container, keys))==null;
    }

    public static function getBoolean(keys:String = ""):Boolean {
        return Boolean((keys.length==0) ? _item : getObject(_container, keys));
    }

    public static function getNumber(keys:String = ""):Number {
        return Number((keys.length==0) ? _item : getObject(_container, keys));
    }

    public static function getInt(keys:String = ""):int {
        return int((keys.length==0) ? _item : getObject(_container, keys));
    }

    public static function getUint(keys:String = ""):uint {
        return uint((keys.length==0) ? _item : getObject(_container, keys));
    }

    public static function getString(keys:String = ""):String {
        return String((keys.length==0) ? _item : getObject(_container, keys));
    }

    public static function getArray(keys:String = ""):Array {
        return ((keys.length==0) ? _item : getObject(_container, keys)) as Array;
    }

    public static function getObjects(keys:String = ""):Object {
        return ((keys.length==0) ? _item : getObject(_container, keys));
    }

    public static function childIsNull(keys:String):Boolean {
        return (_childIitem = getObject(_childContainer, keys))==null;
    }

    public static function childGetBoolean(keys:String = ""):Boolean {
        return Boolean((keys.length==0) ? _childIitem : getObject(_childContainer, keys));
    }

    public static function childGetNumber(keys:String = ""):Number {
        return Number((keys.length==0) ? _childIitem : getObject(_childContainer, keys));
    }

    public static function childGetInt(keys:String = ""):int {
        return int((keys.length==0) ? _childIitem : getObject(_childContainer, keys));
    }

    public static function childGetUint(keys:String = ""):uint {
        return uint((keys.length==0) ? _childIitem : getObject(_childContainer, keys));
    }

    public static function childGetString(keys:String = ""):String {
        return String((keys.length==0) ? _childIitem : getObject(_childContainer, keys));
    }

    public static function childGetArray(keys:String = ""):Array {
        return ((keys.length==0) ? _childIitem : getObject(_childContainer, keys)) as Array;
    }
}
}
