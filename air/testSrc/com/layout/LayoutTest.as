/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.06.17.
 * Time: 10:17
 * To change this template use File | Settings | File Templates.
 */
package com.layout {
import com.common.AppProperties;
import com.sailing.WindowsHandler;

import flash.filesystem.File;

import org.flexunit.asserts.assertEquals;


import org.flexunit.asserts.assertTrue;



public class LayoutTest {
    public function LayoutTest() {
    }

    [Before]
    public function setUp():void {
        AppProperties.screenWidth = 1440;
        AppProperties.screenHeight = 824;
        var mockApp:Object = {};
        mockApp["addElement"] = function(){};
        mockApp["setStyle"] = function(){};
        mockApp["nativeWindow"] = {};
        mockApp["nativeWindow"]["alwaysInFront"] = false;
        WindowsHandler.instance.application = mockApp;
        LayoutHandler.instance.activeLayout = LayoutHandler.instance.layoutContainer["usr1"];
    }


    [After]
    public function tearDown():void {
        //File.applicationStorageDirectory.deleteDirectory(true);
    }

    [Test]
    public function testOpenLayoutFile():void {
        AppProperties.screenWidth = 1440;
        AppProperties.screenHeight = 824;
        var layout:Layout = new Layout("ship");
        assertTrue(layout.layoutFile.exists);
        assertEquals(layout.layoutFile.nativePath, File.applicationStorageDirectory.nativePath + "/layouts/1440_824/ship.layout")
    }


    [Test]
    public function testOpenSmallerLayoutFile():void {
        AppProperties.screenWidth = 1440;
        AppProperties.screenHeight = 300;
        var layout:Layout = new Layout("ship");
        layout.activate();
        assertEquals(layout.windows.length, 3);
    }


    //TODO olyan file betoltese ami nincs a mappaban es nem usr



}
}
