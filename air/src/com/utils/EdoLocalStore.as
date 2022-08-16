/**
 * Created by seamantec on 06/03/14.
 */
package com.utils {
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

public class EdoLocalStore {

    public static var storageDirectory:File = File.applicationStorageDirectory;

    public function EdoLocalStore() {
    }

    public static function setItem(key:String, data:ByteArray):void {
        var object:Object = getObject();
        if(object==null) {
            object = new Object();
        }
        object[key] = data;
        var dataSet:ByteArray = new ByteArray();
        dataSet.writeObject(object);
        var stream:FileStream = new FileStream();
        stream.open(storageDirectory.resolvePath("store.edo"), FileMode.WRITE);
        stream.writeBytes(dataSet, 0, dataSet.length);
        stream.close();
    }

    public static function getItem(key:String):ByteArray {
        var object:Object = getObject();
        return (object!=null && object.hasOwnProperty(key)) ? object[key] : null;
    }

    private static function getObject():Object {
        var data:ByteArray = new ByteArray();
        if(storageDirectory.resolvePath("store.edo").exists) {
            var stream:FileStream = new FileStream();
            stream.open(storageDirectory.resolvePath("store.edo"), FileMode.READ);
            stream.readBytes(data);
            stream.close();
            try {
                return data.readObject();
            } catch(error:Error) {
                return null;
            }
        }
        return null;
    }
}
}
