/**
 * Created by pepusz on 2014.05.26..
 */
package com.sailing.nmeaParser.messages {
import com.sailing.datas.Dbt;
import com.sailing.nmeaParser.utils.NmeaInterpreter;
import com.sailing.nmeaParser.utils.NmeaPacketer;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertNull;

public class NmeaDbtMessageTest {

    var testString:String = "$IIDBT,,f,,M,,F*3F\n$IIDBT,,f,,M,,F*3F\n$IIDBT,232.6,f,70.91,M,38.76,F*11\n"
    var testString2:String = "$IIDBT,232.6,f,70.91,M,38.76,F*11\n$IIDBT,,f,,M,,F*3F\n$IIDBT,,f,,M,,F*3F\n"

    public function NmeaDbtMessageTest() {
    }


    [Test]
    public function testEmptyDbt():void {
        var packeter:NmeaPacketer = new NmeaPacketer();
        var messages:Array = packeter.newReadPacket(testString);
        assertEquals(3, messages.length);
        for (var i:int = 0; i < messages.length; i++) {
            var object:Object = NmeaInterpreter.processWithMessageCode(messages[i]);
            if (i === 0) {
                assertNull(object)
            } else if (i === 1) {
                assertNull(object)
            } else if (i === 2) {
                assertEquals(70.91, (object.data as Dbt).waterDepth.getPureData())
            }

        }
    }
}
}
