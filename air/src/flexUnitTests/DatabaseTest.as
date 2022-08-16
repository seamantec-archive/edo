package flexUnitTests
{
import com.events.UpdateNmeaDatasEvent;
import com.loggers.DataLogger;
import com.sailing.WindowsHandler;
import com.sailing.nmeaParser.utils.NmeaInterpreter;
import com.sailing.nmeaParser.utils.NmeaPacketer;

public class DatabaseTest
	{		
		var testData:Array;
		[Before]
		public function setUp():void
		{
			testData = [];
			testData.push("$IIVHW,004.5,T,003.5,M,8.67,N,16.06,K*6A");
			testData.push("$IIVHW,004.5,T,003.5,M,8.67,N,16.06,K*6A");
			testData.push("$IIVHW,004.5,T,003.5,M,8.67,N,16.06,K*6A");
			testData.push("$IIVHW,004.5,T,003.5,M,8.67,N,16.06,K*6A");
			testData.push("$IIVHW,004.5,T,003.5,M,8.67,N,16.06,K*6A");
			testData.push("$IIVHW,004.0,T,003.0,M,9.00,N,16.67,K*6D");
			testData.push("$IIVHW,004.0,T,003.0,M,8.73,N,16.17,K*6F");
			testData.push("$IIVHW,004.0,T,003.0,M,8.73,N,16.17,K*6F");
			testData.push("$IIVHW,004.0,T,003.0,M,8.73,N,16.17,K*6F");
			testData.push("$IIVHW,003.0,T,002.0,M,9.29,N,17.20,K*62");
			testData.push("$IIVHW,003.0,T,002.0,M,9.29,N,17.20,K*62");
			testData.push("$IIVHW,004.0,T,003.0,M,8.73,N,16.17,K*6F");
			testData.push("$IIVHW,003.0,T,002.0,M,9.29,N,17.20,K*62");
			DataLogger.instance.startLogging();
			
		}
		
		[Test]
		public function testInsert(){
			for(var i:Number = 0; i<testData.length;i++){
				//setTimeout(sendMessage(i), 1000);
				sendMessage(i)
			}
			
		}
		
		private function sendMessage(i:Number){
			var str = testData[i];
			var packeter = new NmeaPacketer();
			var packet_data: Array = packeter.newReadPacket(str);
			for each(var a:String in packet_data){
				var x:Object = NmeaInterpreter.processWithMessageCode(a);
				if(x != null){							
					WindowsHandler.instance.dispatchEvent(new UpdateNmeaDatasEvent(x));
				}else{
					trace("x is null", a);
					
				}
			}
			
		}
		
		
	}
}