/**
 * Created by seamantec on 19/05/14.
 */
package com.alarm.speech {
import com.common.SysConfig;

import flash.filesystem.File;

public class SpeechContainerTest {
    public function SpeechContainerTest() {
        SysConfig.load(new File("/Users/seamantec/sailing/air/src/configs/sys.xml"));
    }

    [Test]
    public function testLoadConfigs():void {
        SpeechContainer.loadConfigs();
    }
}
}
