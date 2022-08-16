/**
 * Created by seamantec on 06/03/14.
 */
package com.utils {
import flash.filesystem.File;
import flash.utils.ByteArray;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertNotNull;
import org.flexunit.asserts.assertNull;

public class EdoLocalStoreTest {

    public function EdoLocalStoreTest() {
    }

    [Test]
    public function getItemTest():void {
        assertNull(EdoLocalStore.getItem("blabla"));
    }

    [Test]
    public function setGetItemTest():void {
        trace("setGetItemTest");
        var dataSet:ByteArray = new ByteArray();
        dataSet.writeObject({ a: 1, b: 2, c: 3 });
        EdoLocalStore.setItem("test", dataSet);

        var dataGet:ByteArray = EdoLocalStore.getItem("test");
        assertNotNull(dataGet);
        if (dataGet!=null) {
            var object:Object = dataGet.readObject();
            assertEquals(object.a, 1);
            assertEquals(object.b, 2);
            assertEquals(object.c, 3);
        }
    }

    [Test]
    public function editExistsObjectTest():void {
        trace("editExistsObjectTest");
        var dataGet:ByteArray = EdoLocalStore.getItem("test");
        var object:Object = dataGet.readObject();
        object.c = 4;

        var dataSet:ByteArray = new ByteArray();
        dataSet.writeObject(object);
        EdoLocalStore.setItem("test", dataSet);

        var dataGet:ByteArray = EdoLocalStore.getItem("test");
        var object:Object = dataGet.readObject();
        assertEquals(object.a, 1);
        assertEquals(object.b, 2);
        assertEquals(object.c, 4);
    }

    [Test]
    public function addToExistsObjectTest():void {
        trace("addToExistsObjectTest");
        var dataGet:ByteArray = EdoLocalStore.getItem("test");
        var object:Object = dataGet.readObject();
        object.d = 5;

        var dataSet:ByteArray = new ByteArray();
        dataSet.writeObject(object);
        EdoLocalStore.setItem("test", dataSet);

        var dataGet:ByteArray = EdoLocalStore.getItem("test");
        var object:Object = dataGet.readObject();
        assertEquals(object.a, 1);
        assertEquals(object.b, 2);
        assertEquals(object.c, 4);
        assertEquals(object.d, 5);
    }

    [Test]
    public function addToNewObjectTest():void {
        trace("addToNewObjectTest");
        var dataSet:ByteArray = new ByteArray();
        dataSet.writeObject({ e: 6, f: 7, g: 8 });
        EdoLocalStore.setItem("test2", dataSet);

        var dataGet:ByteArray = EdoLocalStore.getItem("test2");
        var object:Object = dataGet.readObject();
        assertEquals(object.e, 6);
        assertEquals(object.f, 7);
        assertEquals(object.g, 8);
    }

    [Test]
    public function modifieObjectTest():void {
        trace("modifieObjectTest");
        var dataSet:ByteArray = new ByteArray();
        dataSet.writeObject({ x: 11, y: 12, z: 13 });
        EdoLocalStore.setItem("test2", dataSet);

        var dataGet:ByteArray = EdoLocalStore.getItem("test2");
        var object:Object = dataGet.readObject();
        assertNull(object.e);
        assertNull(object.f);
        assertNull(object.g);

        assertEquals(object.x, 11);
        assertEquals(object.y, 12);
        assertEquals(object.z, 13);
    }

    [Test]
    public function badFileTest():void {
        EdoLocalStore.storageDirectory = File.applicationDirectory;
        assertNull(EdoLocalStore.getItem("test2"));
    }
}
}
