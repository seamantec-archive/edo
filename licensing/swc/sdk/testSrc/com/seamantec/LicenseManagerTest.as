/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.12.06.
 * Time: 14:31
 * To change this template use File | Settings | File Templates.
 */
package com.seamantec {
import flash.data.EncryptedLocalStore;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.utils.Timer;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertNotNull;
import org.flexunit.asserts.assertNull;
import org.flexunit.asserts.assertTrue;
import org.flexunit.async.Async;

public class LicenseManagerTest {

    public function LicenseManagerTest() {

    }

    public var commercial_hobby_trial_license:String = "TEv8WLAxGhlQczrZY87pODJV7s4weILI2io2ovLFTrE=$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";
    public var commercila_hobby_trial_serial:String = "0e265-fbb65-3c154-2a480"
    public var hobby_trial_exp_license:String = "kMYevErCRqO+XEy3AP7u/u171Eaosf8ItiqbjSlvA94=$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";
    public var hobby_trial_exp_serial:String = "b3951-2d2d2-7aedb-b67a7";
    public var commercial_hobby_license:String = "k/meQDYhcxc9ZIA7Pafoxiayk+cy+mXBPOZSS7vblXo=$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";
    public var commercial_hobby_serial:String = "99db0-4235f-b6ea7-7716e";
    public var demo_hobby_license:String = "E8CFxrtwaR2XSK1v1EEWC6NTmaOWoo0ctgSA6TTHnik=$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";
    public var demo_hobby_exp_license:String = "gPOZeBelDp4gnuFWtRNONrQr/zpcQoXw/KX/Wingz6o=$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";
    public var demo_hobby_exp_serial:String = "ce31b-d5ef9-3ee53-8b4f1";
    public var commercial_pro_trial_license:String = "qPBov8R49fF0u1bG69KWBFKMVEELMaohJqgYAdCJcnI=$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";
    public var com_pro_trial_serial:String = "77eec-347b0-d0918-bdfcb"
    public var commercial_pro_license:String = "Q5R6q6bCmKkWbJbUlnJfOfvvgVi2q0tR00KtOgr/T4c=$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";
    public var com_pro_serial:String = "400e2-fe7a0-a213e-51779";
    public var demo_por_license:String = "BQrAsiZS4sAVFi74Mq1wlXFeVUhXkodw6gPLWhkXaqk=$4UTIKgHkTsvTzhxSwjS6whVlATPlX8Dnl0n/CmzsQlwWFjVfqasIx/t4Y8L7yEntY0Bn0EYZO7XRS6en3kRaaxr32y4gnDRObpSB6r+67+E0hL89yglo+Eaj0QUu/H4Y6p1IFOMfoXdRsDwv3XK7VHM71oD6N9NOm+OksPX1kBaIAk36lyeB8oHTs1l68xrdkUFhgS/C8yfKVcwHkmOSoohkFAecsnNwRyJaT6dnm8FsGfzUjfbU5xBBsf8F8D6KkQIrantNJ2npjNZd4jlEfd4OgiewQuV6crJPeIYt3kIsEJrGYvKdjkNy00BvgGTmpkkBCr/au+5v0RF343pv1KEBrQkLfkukhoOk7xiE9IwRblsJiT5Rtb7SfOtCzMZmbhqNKssVh/4BJK/zsN9NgSeirNMCD4G3EatLKdKhalJ4r5+/5lLg4mB2EFGz6ahlFgHYu6pKo0l99DX6RwH6cJmx8whQxBpzuHfxsEwts7jA0mUgTyCWcvIrOI05ZoPoNi1D6xpcQR5Aexz6OccY4DHc0hNe9mTkpUsWc4xwC57eSb8yX+gNDR0b1XgFlLOP2iiJxtM6dqKrBo0Eo41u5zvNF8p4U625Z9ViUMRjjrV+2mKjf13FGuZnw8S5/JXhRUEtpKO9+Ynw0+jxY99QGY81pYidzEQilscsRfzWCCkAESqGdxkG2O0un4J9KhQMrUTsAm44Txm9dD93/hWtow2KcFrg358YhsjdfAQ1Y/qti3QzDIsKhR3Oaa5ae1Tx46kyjWrgMHulO/oaecvPDF3gEC7ViITFidsB9DlJAZrxZ+fFtJtTAYraKPjdZp9YCSasY4ubZYr/Csw5czyNWrLOLSCPfcsv0eUZ4In0ZSo9S8PLw4asaDtyoxU+bhQeY72t02cIX4WpRyRh79dwOtKPPuT4P02pAPxz/rUYqN/HN44rQa/6CM3QiXw7aWEhNvnxupg/aU1rbD8ffMswyPxCJqjn0V8bxpE5ZoTR+BFNPGaP6N0C5JklOGWSOaedqY3HggqFKbyYzfe4Q188tKevuhQmaN8ng+xRfs0Y/UJE+dDhV/M+ySqJLEoLGvGJ+xET0ihJ0OZyMY03NusQriuATjiDhQFW1LWDyfS+x+iyenYIbVBR6i1CYhFLZf+bUu8DPbx5+Waj6b0fD3Kinob7YwiF85u+XJMN/u05VKfwzgNauHiErj6hRvLl+nlrnUXK4LIbR274zLqxN9DxiEWCdF3aomKDIkBqK8k0kesAzW8lyUXEYezYQI2kKrXn9NiRhtXoPW4TWu5hun2jTysMxJcYt4OX8LXK97TPUGxRXaojxx1SVyzVdB4zyrTnD39pZ1XImdgz+w/xJ6QznmUodbRay6X/dFsKqLbt/LVSld+Vj/YP5OjWTln0ArNkcZ3R57nuHUyAkg8NRsz6xJBVm4GBFWS/DCcuLcYroasprFBIkqjtofO0zlgVcPKGIIGNZDEXJeMKSIPWllLaOnwwgXuJa3KSXBayNWVrlGHx6/sy+190v5UnXZb2iaQauyzsoSNKfxw30X6KmQ/uya8lThNjy7zXi0jBKAkz13XJGYiCeJ/CPA+3RiH2yD81svmt2TZZScinqxcS46qUOHsJEt2+C/sCxjq7cM1WA5bCP0WyPZGChgVIw4ojU+LfTEEdAsJq1lHZjPETP+h+FgmIFQCRBr8KrQmLUZheTblYnT+2KAykuPYfRu97JuRCi2YleQPrHYZrYzNeWf1yeAwWZGgoaMRbBjCOalsmHqa3J/16SuAfr90olVNknF9J7PZKc/raCXa2YFKi6hvZpIFjPFiB+R3KSHr5MDJoRfgSMXpuvoGvYBaFHNqdpk6DOWXXy6vv366JAlEvhXV2dqFlkteAc+1uURkCUpr4uQyckb+vLPrgkxcaqs+VE/6uFQmuLoqX1rtaVCVsMeCwzPScfPjqCIHWumbRcvTg9eBlXTqf0XDvwCeu6w9ibNv0X7IL88hbGPI12AVF1mJyT75eU6KKXQhmTDybemYo9KU1nrXNiiZWRUmsH5XbujNKZ/IJsEs0PHk7/wJNvkeYV1eKv4zutMCk0GL0kzchg367c9mfB3w8HHYSz4wE9dSBLOAJC79gbnWbsVMP+0hCEFcpNR3C+NkKu4pbZ1qYdYHowVY/nc61OE+hUgXuoqMI7QyadaZeRuEDrlWpLSd4YIuhGAhyir3M0vGBrypr/niXsqS1Ne96TG/OfBqxP8NjQXu34QRMjCwnUYsuupshMXP2eC/p2Jkbc580bxDjO4w=";
    public var demo_pro_serial:String = "82fd2-d94ea-58c8d-fcefb";


    //License order
    //Test response messages
    //SERVER SIDE CANT create more trial for one email

    //SET GPS DATE checker


//    [Rule]
//    public var expectEvent:EventRule = new EventRule();

    private var lm:LicenseManager

    [Before]
    public function setUp():void {
        EncryptedLocalStore.reset();
        lm = new LicenseManager();
        lm.tempEmail = "kis@bela.hu";

    }

    [Test]
    public function loadCommercialHobby():void {
        lm.tempSerial = "99db0-4235f-b6ea7-7716e"
        lm.loadLicenseData(commercial_hobby_license);
        var license:License = lm.getLicenseByName("commercial_hobby");
        assertNotNull(license);
        assertTrue(lm.hasValidComHobby);
    }

    [Test]
    public function hasDemoHobbyLoadComHobby():void {
        lm.tempSerial = "c9196-4994e-32f43-cbb5c"
        lm.loadLicenseData(demo_hobby_license);
        var demoLic:License = lm.getLicenseByName("demo_hobby");
        assertTrue(demoLic.isLicenseValid());
        lm.tempSerial = "99db0-4235f-b6ea7-7716e"
        lm.loadLicenseData(commercial_hobby_license);
        demoLic = lm.getLicenseByName("demo_hobby");
        assertNull(demoLic)
        var comHobby:License = lm.getComHobby();
        assertTrue(comHobby.isLicenseValid());
    }

    [Test]
    public function hasOldDemoLoadNewOne():void {
        var license:License = new License(lm, demo_hobby_exp_license, new Date(), "kis@bela.hu", demo_hobby_exp_serial);
        license.activate();
        lm.licenses.push(license);
        var demoLicExp:License = lm.getLicenseByName("demo_hobby");
        assertNotNull(demoLicExp);
        lm.tempSerial = "c9196-4994e-32f43-cbb5c"
        lm.loadLicenseData(demo_hobby_license);
        assertTrue(lm.getLicenseByName("demo_hobby") != license);
        assertTrue(lm.getLicenseByName("demo_hobby").expireAt > license.expireAt);
        assertTrue(lm.licenses.length === 1);
    }

    [Test]
    public function hasDemoTryToLoadExpiredDemo():void {
        lm.tempSerial = "c9196-4994e-32f43-cbb5c"
        lm.loadLicenseData(demo_hobby_license);
        var demoLic:License = lm.getLicenseByName("demo_hobby");
        assertTrue(demoLic.isLicenseValid());
        lm.tempSerial = demo_hobby_exp_serial
        lm.loadLicenseData(demo_hobby_exp_license);
        assertTrue(lm.licenses.length === 1);
        assertTrue(lm.getLicenseByName("demo_hobby").isLicenseValid());
    }

    [Test]
    public function hasTrialLoadCommercialHobby():void {
        lm.tempSerial = commercila_hobby_trial_serial
        lm.loadLicenseData(commercial_hobby_trial_license);
        var trialLic:License = lm.getLicenseByName("trial_hobby");
        assertTrue(trialLic.isLicenseValid());
        assertTrue(lm.hasValidTrialHobby());
        assertTrue(lm.licenses.length === 1);
        lm.tempSerial = commercial_hobby_serial;
        lm.loadLicenseData(commercial_hobby_license);
        var comLic:License = lm.getLicenseByName("commercial_hobby");
        assertTrue(comLic.isLicenseValid());
        assertTrue(lm.hasValidComHobby());
        assertTrue(lm.licenses.length === 1);
    }


    [Test]
    public function hasTrialLoadCommercialPro():void {
        lm.tempSerial = com_pro_trial_serial
        lm.loadLicenseData(commercial_pro_trial_license);
        var trialLic:License = lm.getLicenseByName("trial_pro");
        assertTrue(trialLic.isLicenseValid());
        assertTrue(lm.hasValidTrialPro());
        assertTrue(lm.licenses.length === 1);
        lm.tempSerial = com_pro_serial;
        lm.loadLicenseData(commercial_pro_license);
        var comLic:License = lm.getLicenseByName("commercial_pro");
        assertTrue(comLic.isLicenseValid());
        assertTrue(lm.hasValidComPro());
        assertTrue(lm.licenses.length === 1);
    }

    [Test]
    public function hasDemoLoadTrialLoadCommercialHobbyThanPro():void {
        lm.tempSerial = "c9196-4994e-32f43-cbb5c"
        lm.loadLicenseData(demo_hobby_license);
        var demoLic:License = lm.getLicenseByName("demo_hobby");
        assertTrue(demoLic.isLicenseValid());
        assertTrue(lm.licenses.length === 1);
        assertTrue(lm.hasValidDemoHobby())
        lm.tempSerial = demo_pro_serial
        lm.loadLicenseData(demo_por_license);
        var demoLicPro:License = lm.getLicenseByName("demo_pro");
        assertTrue(demoLicPro.isLicenseValid());
        assertTrue(lm.licenses.length === 2);
        assertTrue(lm.hasValidDemoPro());
        lm.tempSerial = commercila_hobby_trial_serial
        lm.loadLicenseData(commercial_hobby_trial_license);
        var trialLicHobby:License = lm.getLicenseByName("trial_hobby");
        assertNull(lm.getDemoHobby());
        assertTrue(trialLicHobby.isLicenseValid());
        assertTrue(lm.hasValidTrialHobby());
        assertTrue(lm.licenses.length === 2);

        lm.tempSerial = com_pro_trial_serial
        lm.loadLicenseData(commercial_pro_trial_license);
        var trialLic:License = lm.getLicenseByName("trial_pro");
        assertTrue(trialLic.isLicenseValid());
        assertTrue(lm.hasValidTrialPro());
        assertTrue(lm.licenses.length === 2);
        assertNull(lm.getDemoPro());


        lm.tempSerial = commercial_hobby_serial;
        lm.loadLicenseData(commercial_hobby_license);
        var comLichobby:License = lm.getLicenseByName("commercial_hobby");
        assertTrue(comLichobby.isLicenseValid());
        assertTrue(lm.hasValidComHobby());
        assertTrue(lm.licenses.length === 2);
        assertNull(lm.getDemoHobby());
        assertNull(lm.getTrialHobby());

        lm.tempSerial = com_pro_serial;
        lm.loadLicenseData(commercial_pro_license);
        var comLic:License = lm.getLicenseByName("commercial_pro");
        assertTrue(comLic.isLicenseValid());
        assertTrue(lm.hasValidComPro());
        assertTrue(lm.licenses.length === 1);

        assertNull(lm.getDemoPro());
        assertNull(lm.getTrialPro());
    }


    [Test]
    public function testDaysRemaining():void {


    }

    [Test]
    public function testActivateLicense():void {

    }


    [Test]
    public function testGetHwKey():void {
        var serial:String = lm.getHwKey()
        trace(serial);
        var serial:String = lm.getHwKey()
        trace(serial);
        var serial:String = lm.getHwKey()
        trace(serial);
        var serial:String = lm.getHwKey()
        trace(serial);
        var serial:String = lm.getHwKey()
        trace(serial);
        var serial:String = lm.getHwKey()
        trace(serial);
    }

    [Test]
    public function testIsLicenseValid():void {

    }

    [Test(async, timeout=60000)]
    public function testDecryptLicense():void {
        asyncWaiter(10000, function (event:Event, passThroughData:Object) {
            var license:License = lm.getLicenseByName("demo.lic");
            var xml:XML = new XML();
            if (license != null) {
                xml = license.decryptLicense();
            }
            assertNotNull(xml.signiture);
        }, handleTimeout, onTimer);
        lm.getLicenseFromServer("john@gmail.com", "32868-8e60a-0c186-baf3a")

    }

    [Test(async, timeout=60000)]
    public function testGetLicenseFromServer():void {
        asyncWaiter(10000, function (event:Event, passThroughData:Object) {
            assertTrue(lm.licenses.length > 0);
            var lm2:LicenseManager = new LicenseManager();

        }, handleTimeout, onTimer);
        lm.getLicenseFromServer("john@gmail.com", "52f0a-852a5-3ba04-4b161")
    }


    [Test]
    public function testAesEncDec():void {
        var decrypted:String = AES.decrypt("aIeH2P8UTFAsf1z/qv4sxYjYYHn53ogwTCawy5nOkcY=$QzpL2eFOb8zO4cE=", "8bb6dc49d207513a4c41b35cb985b71c");
        assertEquals("get_license", decrypted)
        trace(decrypted)
    }


    [Test]
    public function testLoadLicenseFromFile():void {
        var licenseFile:File = new File(File.applicationDirectory.nativePath + "/../../../sdk/testdatas/edo_instruments.lic");
        assertTrue(licenseFile.exists);
        lm.getLicenseFromFile(licenseFile, "john@gmail.com", "7f17b-5857f-663d8-8ca3e");
        var trialLic:License = lm.getLicenseByName("trial_hobby");
        assertTrue(trialLic.isLicenseValid());
        assertTrue(lm.hasValidTrialHobby());
        assertTrue(lm.licenses.length === 1);
        assertNotNull(lm.getTrialHobby());
    }

    private function asyncWaiter(timeout:int, handleRead:Function, handleTimeout:Function, onTimer:Function):void {
        var timer:Timer = new Timer(100, Math.round(timeout / 100));
        timer.addEventListener(TimerEvent.TIMER, onTimer)
        timer.addEventListener(TimerEvent.TIMER_COMPLETE, Async.asyncHandler(this, handleRead, timeout, timer, handleTimeout), false, 0, true);
        timer.start();
    }

    protected function onTimer(event:TimerEvent):void {
        if (lm.getLicenseByName("demo.lic") != null) {
            var timer:Timer = (event.currentTarget as Timer);
            timer.dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
            timer.stop();
        }
    }


    protected function handleTimeout(passThroughData:Object):void {
        assertTrue("License file not found. Timeout error", false)

    }
}
}
