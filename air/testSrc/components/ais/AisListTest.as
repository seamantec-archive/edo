/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.10.11.
 * Time: 13:41
 * To change this template use File | Settings | File Templates.
 */
package components.ais {
import com.sailing.ais.AisContainer;
import com.sailing.ais.AisContainer;
import com.sailing.ais.Vessel;
import com.sailing.nmeaParser.utils.NmeaInterpreter;
import com.sailing.nmeaParser.utils.NmeaPacketer;

import flash.display.Sprite;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.getTimer;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertNotNull;

import org.flexunit.asserts.assertTrue;

public class AisListTest {
    var aisList:AisList
    var allShipSprite:Sprite
    var underway:Sprite
    private static var messages;

    public function AisListTest() {
    }

    [BeforeClass]
    public static function parseTestNmea():void {
        var logFile:File = new File(File.applicationDirectory.nativePath + "/../../../testDatas/aistest.txt");
        assertTrue(logFile.exists);
        var fileStream:FileStream = new FileStream();
        fileStream.open(logFile, FileMode.READ);
        fileStream.position = 0;
        var fileContent:* = fileStream.readUTFBytes(fileStream.bytesAvailable);
        var packeter:NmeaPacketer = new NmeaPacketer();
        messages = packeter.newReadPacket(fileContent, true);
        resetAisContainer();
    }

    private static function resetAisContainer():void {
        AisContainer.instance.deleteAllShip();
        for (var i:int = 0; i < messages.length; i++) {
            NmeaInterpreter.processWithMessageCode(messages[i]);
        }
    }

    [Before]
    public function setUp():void {
        AisContainer.instance.selectedShipMMSI = null;
        aisList = new AisList();
        aisList.isWindowOpen = true;
        allShipSprite = aisList.getChildAt(0) as Sprite;
        underway = aisList.getChildAt(1) as Sprite;
    }

    [After]
    public function tearDown():void {
        resetAisContainer();
    }


    [Test]
    public function testLoadShips():void {
        assertEquals(AisContainer.instance.shipInOrderedList.length, 7);
    }


    [Test]
    public function testOpenList():void {
        assertEquals("after open a list, all of 7 ships need to be loaded", aisList.allShipList.length, 7);
        assertEquals("after open a list, underway ships is 4", aisList.underwayList.length, 4);
    }


    [Test]
    public function testAfterOpenSelectAllShips():void {
        aisList.showAllVessel();
        assertEquals(aisList.numChildren, 2);
        assertEquals(allShipSprite.numChildren, 7);
        assertFalse(underway.visible);
        assertEquals(calcHeight(allShipSprite), 7 * AisListItem.HEADER_HEIGHT);
        assertEquals(calcHeight(allShipSprite), calcYs(allShipSprite) + AisListItem.HEADER_HEIGHT);
    }


    [Test]
    public function testAfterOpenOneItem():void {
        aisList.showAllVessel();
        assertEquals(aisList.numChildren, 2);
        AisContainer.instance.selectedShipMMSI = AisContainer.instance.shipInOrderedList[2];
        assertEquals(allShipSprite.numChildren, 7);
        assertFalse(underway.visible);
        assertEquals(calcHeight(allShipSprite), 7 * AisListItem.HEADER_HEIGHT + AisListItem.itemBgBitmap.height);
        assertEquals(calcHeight(allShipSprite), calcYs(allShipSprite) + AisListItem.HEADER_HEIGHT);
    }


    [Test]
    public function testAfterOpenOneItemAndCloseReOpenList():void {
        aisList.showAllVessel();
        assertEquals(aisList.numChildren, 2);
        AisContainer.instance.selectedShipMMSI = AisContainer.instance.shipInOrderedList[2];
        var heightBeforeclose:int = calcHeight(allShipSprite);
        var yBeforeclose:int = calcYs(allShipSprite);
        aisList.isWindowOpen = false;
        aisList.isWindowOpen = true;
        assertEquals(allShipSprite.numChildren, 7);
        assertFalse(underway.visible);
        assertEquals(calcHeight(allShipSprite), heightBeforeclose);
        assertEquals(yBeforeclose, calcYs(allShipSprite));
    }

    public function calcHeight(sprite:Sprite):int {
        var prevHeight:int = 0;
        for (var i:int = 0; i < sprite.numChildren; i++) {
            prevHeight += (sprite.getChildAt(i) as AisListItem).getCalcHeight();
        }
        return prevHeight;
    }

    public function calcYs(sprite:Sprite):int {
        var maxy:int = 0;
        for (var i:int = 0; i < sprite.numChildren; i++) {
            if (sprite.getChildAt(i).y > maxy) {
                maxy = sprite.getChildAt(i).y;
            }
        }
        return maxy;
    }


    [Test]
    public function testSwitchAllToUnderway():void {
        aisList.showAllVessel();
        aisList.showUnderwayShips();
        assertFalse(allShipSprite.visible);
        assertTrue(underway.visible);
        assertEquals(underway.numChildren, 4)
    }

    [Test]
    public function testSwitchAllToUnderwayWithOpenedItem():void {
        aisList.showAllVessel();
        AisContainer.instance.selectedShipMMSI = getOneUnderwayMMSI();
        aisList.showUnderwayShips();
        assertFalse(allShipSprite.visible);
        assertTrue(underway.visible);
        assertEquals(underway.numChildren, 4);
        assertEquals("check underway height", calcHeight(underway), 4 * AisListItem.HEADER_HEIGHT + AisListItem.itemBgBitmap.height);
        assertEquals("check underway ypositions", calcHeight(underway), calcYs(underway) + AisListItem.HEADER_HEIGHT);
    }


    [Test]
    public function testRemoveOneMMsi():void {
        aisList.showAllVessel();
        aisList.removeItem(getOneUnderwayMMSI());
        assertEquals(allShipSprite.numChildren, 6);
        assertEquals(aisList.allShipList.length, 6);
        assertEquals(calcHeight(allShipSprite), 6 * AisListItem.HEADER_HEIGHT);
        assertEquals(calcHeight(allShipSprite), calcYs(allShipSprite) + AisListItem.HEADER_HEIGHT);
    }

    [Test]
    public function testRemoveSelectedMMsi():void {
        aisList.showAllVessel();
        AisContainer.instance.selectedShipMMSI = getOneUnderwayMMSI();
        aisList.removeItem(AisContainer.instance.selectedShipMMSI);
        assertEquals(allShipSprite.numChildren, 6);
        assertEquals(aisList.allShipList.length, 6);
        assertEquals(calcHeight(allShipSprite), 6 * AisListItem.HEADER_HEIGHT);
        assertEquals(calcHeight(allShipSprite), calcYs(allShipSprite) + AisListItem.HEADER_HEIGHT);
    }

    [Test]
    public function testRemoveOneMMsiSwitchFilter():void {
        aisList.showAllVessel();
        aisList.removeItem(getOneUnderwayMMSI());
        aisList.showUnderwayShips();
        assertEquals(underway.numChildren, 3);
        assertEquals(aisList.allShipList.length, 6);
        assertEquals(calcHeight(underway), 3 * AisListItem.HEADER_HEIGHT);
        assertEquals(calcHeight(underway), calcYs(underway) + AisListItem.HEADER_HEIGHT);
    }


    [Test]
    public function testAddNewElement():void {
        var vessel:Vessel = new Vessel("123");
        vessel.lat = AisContainer.instance.ownShip.coordinate.lat + 0.057
        vessel.lon = AisContainer.instance.ownShip.coordinate.lon + 0.057
        AisContainer.instance.addShip(vessel);
        assertEquals(aisList.allShipList.length, 8);
        AisContainer.instance.removeShip(vessel.mmsi);
    }

    [Test]
    public function testAddNewElementSwitchLayout():void {
        var vessel:Vessel = new Vessel("123");
        vessel.lat = AisContainer.instance.ownShip.coordinate.lat + 0.057
        vessel.lon = AisContainer.instance.ownShip.coordinate.lon + 0.057
        vessel.speedOverGround = 12;
        AisContainer.instance.addShip(vessel);
        aisList.showUnderwayShips();
        assertEquals(aisList.allShipList.length, 8);
        assertEquals(underway.numChildren, 5);
        AisContainer.instance.removeShip(vessel.mmsi);
        assertEquals(aisList.allShipList.length, 7);
        assertEquals(underway.numChildren, 4);
    }

    [Test]
    public function testUpdateClosestAndCheckOrder():void {
        var vessel:Vessel = aisList.allShipList[0].vessel;
        vessel.lat = AisContainer.instance.ownShip.coordinate.lat + 0.800
        vessel.lon = AisContainer.instance.ownShip.coordinate.lon + 0.800
        vessel.speedOverGround = 12;
        AisContainer.instance.addShip(vessel);
        aisList.showAllVessel();
        assertEquals(vessel.mmsi, aisList.allShipList[6].vessel.mmsi);
    }


    private function getOneUnderwayMMSI():String {
        for (var i:int = 0; i < AisContainer.instance.shipInOrderedList.length; i++) {
            if ((AisContainer.instance.container[AisContainer.instance.shipInOrderedList[i]] as Vessel).isUnderWay()) {
                return AisContainer.instance.shipInOrderedList[i];
            }
        }
        return null
    }


    //close window, add, close remove elements, and after reopen

    [Test]
    public function testCloseAddRemoveReOpen():void {
        var mmsi:String = getOneUnderwayMMSI();
        var vessel:Vessel = new Vessel("123");
        vessel.lat = AisContainer.instance.ownShip.coordinate.lat + 0.057
        vessel.lon = AisContainer.instance.ownShip.coordinate.lon + 0.057
        vessel.speedOverGround = 25;
        var vessel2:Vessel = new Vessel("1233");
        vessel2.lat = AisContainer.instance.ownShip.coordinate.lat + 0.057
        vessel2.lon = AisContainer.instance.ownShip.coordinate.lon + 0.057
        vessel2.speedOverGround = 20;
        //CLOSE WINDOW
        aisList.isWindowOpen = false;
        AisContainer.instance.removeShip(mmsi);
        AisContainer.instance.addShip(vessel)
        AisContainer.instance.addShip(vessel2);
        aisList.isWindowOpen = true;
        assertEquals(8, aisList.allShipList.length);
        assertEquals(8, allShipSprite.numChildren);
        aisList.showUnderwayShips();
        assertEquals(underway.numChildren, 5);
    }


    //select one element, change filter view and should be open


    [Test]
    public function testSelectOneChangeFilterAndCheckOpen():void {
        aisList.showAllVessel();
        AisContainer.instance.selectedShipMMSI = getOneUnderwayMMSI();
        aisList.showUnderwayShips();
        for (var i:int = 0; i < underway.numChildren; i++) {
            var listItem:AisListItem = underway.getChildAt(i) as AisListItem;
            if (listItem.vessel.mmsi === AisContainer.instance.selectedShipMMSI) {
                assertTrue(listItem.isOpen());
                assertEquals(listItem.height - 1, AisListItem.HEADER_HEIGHT + AisListItem.itemBgBitmap.height);
            }
        }
    }

    [Test]
    public function testScrollYInAllVessel():void {
        aisList.showAllVessel();
        for (var i:int = 0; i < 100; i++) {
            var vessel:Vessel = new Vessel("1234" + i);
            vessel.lat = AisContainer.instance.ownShip.coordinate.lat + 0.057 * i
            vessel.lon = AisContainer.instance.ownShip.coordinate.lon + 0.057 * i
            vessel.speedOverGround = 25;
            AisContainer.instance.addShip(vessel)
        }
        assertEquals(0 + aisList.y, int(aisList.scrollBar.y));
        aisList.scrollTo(30);
        assertEquals(int(30 * aisList.scrollBar.getRatio()) + aisList.y, int(aisList.scrollBar.y));
        aisList.scrollTo(30);
        assertEquals(int(60 * aisList.scrollBar.getRatio()) + aisList.y, int(aisList.scrollBar.y));
        for (var i:int = 0; i < 100; i++) {
            AisContainer.instance.removeShip("1234" + i)
        }
    }

    [Test]
    public function testScrollYInAllVesselAfterChangeFilter():void {
        aisList.showAllVessel();
        for (var i:int = 0; i < 100; i++) {
            var vessel:Vessel = new Vessel("1234" + i);
            vessel.lat = AisContainer.instance.ownShip.coordinate.lat + 0.057 * i
            vessel.lon = AisContainer.instance.ownShip.coordinate.lon + 0.057 * i
            vessel.speedOverGround = 25;
            AisContainer.instance.addShip(vessel)
        }
        assertEquals(aisList.scrollBar.y, 0 + aisList.y);
        aisList.scrollTo(30);
        assertEquals(aisList.scrollBar.y, Math.round(30 * aisList.scrollBar.getRatio() * 10) / 10 + aisList.y);
        aisList.scrollTo(30);
        assertEquals(aisList.scrollBar.y, Math.round(60 * aisList.scrollBar.getRatio() * 10) / 10 + aisList.y);

        aisList.showUnderwayShips();
        assertEquals(aisList.scrollBar.y, 0 + aisList.y);
        aisList.scrollTo(30);
        assertEquals(aisList.scrollBar.y, Math.round(30 * aisList.scrollBar.getRatio() * 10) / 10 + aisList.y);
        aisList.scrollTo(30);
        assertEquals(aisList.scrollBar.y, Math.round(60 * aisList.scrollBar.getRatio() * 10) / 10 + aisList.y);

        aisList.showAllVessel();
        assertEquals(aisList.scrollBar.y, 0 + aisList.y);
        aisList.scrollTo(30);
        assertEquals(aisList.scrollBar.y, Math.round(30 * aisList.scrollBar.getRatio() * 10) / 10 + aisList.y);
        aisList.scrollTo(30);
        assertEquals(aisList.scrollBar.y, Math.round(60 * aisList.scrollBar.getRatio() * 10) / 10 + aisList.y);

        for (var i:int = 0; i < 100; i++) {
            AisContainer.instance.removeShip("1234" + i)
        }
    }

    [Test]
    public function testScrollYInAllVesselAfterChangeFilterAddRemoveItems():void {
        aisList.showAllVessel();
        for (var i:int = 0; i < 100; i++) {
            var vessel:Vessel = new Vessel("1234" + i);
            vessel.lat = AisContainer.instance.ownShip.coordinate.lat + 0.057 * i
            vessel.lon = AisContainer.instance.ownShip.coordinate.lon + 0.057 * i
            vessel.speedOverGround = 25;
            AisContainer.instance.addShip(vessel)
        }
        assertEquals(0 + aisList.y, aisList.scrollBar.y);
        aisList.scrollTo(30);
        assertEquals(aisList.scrollBar.y, Math.round(30 * aisList.scrollBar.getRatio() * 10) / 10 + aisList.y);
        aisList.scrollTo(30);
        assertEquals(aisList.scrollBar.y, Math.round(60 * aisList.scrollBar.getRatio() * 10) / 10 + aisList.y);

        for (var i:int = 0; i < 5; i++) {
            AisContainer.instance.removeShip("1234" + i)
        }

        aisList.showUnderwayShips();
        assertEquals(0 + aisList.y, aisList.scrollBar.y);
        aisList.scrollTo(30);
        assertEquals(Math.round(aisList.scrollBar.y * 10) / 10, Math.round(30 * aisList.scrollBar.getRatio() * 10) / 10 + aisList.y);
        aisList.scrollTo(30);
        assertEquals(Math.round(aisList.scrollBar.y * 10) / 10, Math.round(60 * aisList.scrollBar.getRatio() * 10) / 10 + aisList.y);
        aisList.showAllVessel();
        assertEquals(0 + aisList.y, aisList.scrollBar.y);
        aisList.scrollTo(30);
        assertEquals(Math.round(aisList.scrollBar.y*10)/10, Math.round(30 * aisList.scrollBar.getRatio() * 10) / 10 + aisList.y);
        aisList.scrollTo(30);
        assertEquals(Math.round(aisList.scrollBar.y*10)/10, Math.round(60 * aisList.scrollBar.getRatio() * 10) / 10 + aisList.y);

    }




    [Test]
    public function testUnderwayList():void {
        assertNotNull(aisList.underwayList)
    }

    [Test]
    public function testUnderwayListSizeAfterOpen():void {
        assertEquals(aisList.underwayList.length, 4);
    }


    [Test]
    public function testAddRemoveNewVessel():void {
        var vessel:Vessel = new Vessel("1234");
        vessel.lat = AisContainer.instance.ownShip.coordinate.lat + 0.057
        vessel.lon = AisContainer.instance.ownShip.coordinate.lon + 0.057
        vessel.speedOverGround = 25;
        AisContainer.instance.addShip(vessel)
        assertEquals(aisList.underwayList.length, 5);
        assertEquals(aisList.allShipList.length, 8);
        AisContainer.instance.removeShip("1234");
        assertEquals(aisList.underwayList.length, 4);
        assertEquals(aisList.allShipList.length, 7);
    }


    [Test]
    public function testStopStartVessel():void {
        var vessel:Vessel = new Vessel("1234");
        vessel.lat = AisContainer.instance.ownShip.coordinate.lat + 0.057
        vessel.lon = AisContainer.instance.ownShip.coordinate.lon + 0.057
        vessel.speedOverGround = 25;
        AisContainer.instance.addShip(vessel)
        assertEquals(aisList.underwayList.length, 5);
        assertEquals(aisList.allShipList.length, 8);
        vessel.speedOverGround = 0;
        vessel.navStatus = 1;
        AisContainer.instance.addShip(vessel);
        assertEquals(aisList.underwayList.length, 4);
        assertEquals(aisList.allShipList.length, 8);
        vessel.speedOverGround = 20;
        AisContainer.instance.addShip(vessel)
        assertEquals(aisList.underwayList.length, 5);
        assertEquals(aisList.allShipList.length, 8);
    }


    [Test]
    public function testCheckScrollBarHeight():void {
        aisList.showAllVessel();
        for (var i:int = 0; i < 20; i++) {
            var vessel:Vessel = new Vessel("1234" + i);
            vessel.lat = AisContainer.instance.ownShip.coordinate.lat + 0.057 * i
            vessel.lon = AisContainer.instance.ownShip.coordinate.lon + 0.057 * i
            vessel.speedOverGround = i % 3 === 0 ? 25 : 0;
            vessel.navStatus = i % 3 === 0 ? 1 : 0;
            AisContainer.instance.addShip(vessel)
        }
        AisContainer.instance.selectedShipMMSI = null;
        assertEquals(calcScrollbarHeight(aisList.allShipList.length), aisList.scrollBar.height)
        assertEquals(aisList.scrollBar.y, aisList.y)
        aisList.showUnderwayShips();
        assertEquals(calcScrollbarHeight(aisList.underwayList.length), aisList.scrollBar.height)
        assertEquals(aisList.scrollBar.y, aisList.y)
    }

    private function calcScrollbarHeight(numClosedElements:int):int {
        var height:int = aisList.scrollRect.height * (aisList.scrollRect.height / (numClosedElements * AisListItem.HEADER_HEIGHT));
        if (height > aisList.scrollRect.height) {
            height = aisList.scrollRect.height;
        }
        return height;

    }


    private function sleep(ms:int):void {
        var init:int = getTimer();
        while (true) {
            if (( getTimer() - init) >= ms) {
                break;
            }
        }
    }
}
}
