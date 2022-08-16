package flexUnitTests
{
import com.sailing.datas.Gsa;
import com.sailing.datas.Gsv;
import com.sailing.datas.Hcc;
import com.sailing.datas.Hcd;
import com.sailing.datas.Htc;
import com.sailing.datas.Mda;
import com.sailing.datas.Mwd;
import com.sailing.datas.Rmb;
import com.sailing.datas.Rotnmea;
import com.sailing.datas.Vdr;
import com.sailing.datas.Vpw;
import com.sailing.datas.Vtg;
import com.sailing.datas.Vwt;
import com.sailing.datas.Xte;
import com.sailing.datas.Zda;
import com.sailing.nmeaParser.utils.NmeaInterpreter;
import com.sailing.nmeaParser.utils.NmeaPacketer;

public class NmeaMessagesTest
	{		
		/*[Before]
		public function setUp():void
		{
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		*/
		[Test]
		public function testGsa():void
		{
			var message:String = "$IIGSA,,3,27,04,12,30,14,02,29,09,,,,,,1,*7F\r\n";
			var packeter:NmeaPacketer = new NmeaPacketer();
			message = packeter.newReadPacket(message)[0];
			var parsedMessage:* = NmeaInterpreter.processWithMessageCode(message);
			assertTrue(parsedMessage.data is Gsa);
			assertEquals(parsedMessage.key, "gsa");
			assertEquals(parsedMessage.data.mode, "3D");
			
		}
		
		[Test]
		public function testGsv():void
		{
			var message:String = "$IIGSV,2,1,24,12,74,323,47,09,57,134,47,27,49,135,44,30,42,276,43*6A\r\n";
			var packeter:NmeaPacketer = new NmeaPacketer();
			message = packeter.newReadPacket(message)[0];
			var parsedMessage:* = NmeaInterpreter.processWithMessageCode(message);
			
			
			assertTrue(parsedMessage.data is Gsv);
			assertEquals(parsedMessage.key, "gsv");
			assertEquals(parsedMessage.data.totalNumberOfSentences, 2);
			assertEquals(parsedMessage.data.sv4[3], 276);
			assertEquals(parsedMessage.data.sv2_3, 135);
			
		}
		
		[Test]
		public function testMwd():void
		{
			var message:String = "$IIMWD,321.0,T,320.0,M,8.7,N,4.5,M*4B\r\n";
			var packeter:NmeaPacketer = new NmeaPacketer();
			message = packeter.newReadPacket(message)[0];
			var parsedMessage:* = NmeaInterpreter.processWithMessageCode(message);
			
			
			assertTrue(parsedMessage.data is Mwd);
			assertEquals(parsedMessage.key, "mwd");
			assertEquals(parsedMessage.data.windDirectionTrue, 321);
			assertEquals(parsedMessage.data.windDirectionMagnetic, 320);
			assertEquals(parsedMessage.data.windSpeed, 8.7);
			
		}
		
		[Test]
		public function testMwdWithoutKnots():void
		{
			var message:String = "$IIMWD,321.0,T,320.0,M,,,4.5,M*24\r\n";
			var packeter:NmeaPacketer = new NmeaPacketer();
			message = packeter.newReadPacket(message)[0];
			var parsedMessage:* = NmeaInterpreter.processWithMessageCode(message);
			
			
			assertTrue(parsedMessage.data is Mwd);
			assertEquals(parsedMessage.key, "mwd");
			assertEquals(parsedMessage.data.windDirectionTrue, 321);
			assertEquals(parsedMessage.data.windDirectionMagnetic, 320);
			assertEquals(parsedMessage.data.windSpeed, 8.747300205);
			
		}
	
		
		[Test]
		public function testRmb():void
		{
			var message:String = "$RMB missing message";
			var packeter:NmeaPacketer = new NmeaPacketer();
			message = packeter.newReadPacket(message)[0];
			var parsedMessage:* = NmeaInterpreter.processWithMessageCode(message);
			
			
			assertTrue(parsedMessage.data is Rmb);
			assertEquals(parsedMessage.key, "rmb");
			//TODO more asserts
			
		}
		
		[Test]
		public function testRot():void
		{
			var message:String = "$ROT missing message";
			var packeter:NmeaPacketer = new NmeaPacketer();
			message = packeter.newReadPacket(message)[0];
			var parsedMessage:* = NmeaInterpreter.processWithMessageCode(message);
			
			
			assertTrue(parsedMessage.data is Rotnmea);
			assertEquals(parsedMessage.key, "rot");
			//TODO more asserts
			
		}
		
		[Test]
		public function testVdr():void
		{
			var message:String = "$VDR missing message";
			var packeter:NmeaPacketer = new NmeaPacketer();
			message = packeter.newReadPacket(message)[0];
			var parsedMessage:* = NmeaInterpreter.processWithMessageCode(message);
			
			
			assertTrue(parsedMessage.data is Vdr);
			assertEquals(parsedMessage.key, "vdr");
			//TODO more asserts
			
		}
		
		[Test]
		public function testVpw():void
		{
			var message:String = "$IIVPW,6.48,N,3.34,M*5C";
			var packeter:NmeaPacketer = new NmeaPacketer();
			message = packeter.newReadPacket(message)[0];
			var parsedMessage:* = NmeaInterpreter.processWithMessageCode(message);
			
			
			assertTrue(parsedMessage.data is Vpw);
			assertEquals(parsedMessage.key, "vpw");
			//TODO more asserts
			
		}
		
		[Test]
		public function testVtg():void
		{
			var message:String = "$IIVTG,007.0,T,006.0,M,7.6,N,14.1,K*6D";
			var packeter:NmeaPacketer = new NmeaPacketer();
			message = packeter.newReadPacket(message)[0];
			var parsedMessage:* = NmeaInterpreter.processWithMessageCode(message);
			
			
			assertTrue(parsedMessage.data is Vtg);
			assertEquals(parsedMessage.key, "vtg");
			assertEquals(parsedMessage.data.courseOverGroundTrue, 007);

			//TODO more asserts
			
		}
		
		[Test]
		public function testZda():void
		{
			var message:String = "$IIZDA,145615,06,07,2010,,*5F";
			var packeter:NmeaPacketer = new NmeaPacketer();
			message = packeter.newReadPacket(message)[0];
			var parsedMessage:* = NmeaInterpreter.processWithMessageCode(message);
			
			
			assertTrue(parsedMessage.data is Zda);
			assertEquals(parsedMessage.key, "zda");
			assertEquals(parsedMessage.data.utc.toString(), new Date(2010,06,06,14,56,15).toString());

			//TODO more asserts
			
		}
		
		[Test]
		public function testHcc():void
		{
			var message:String = "$HCC";
			var packeter:NmeaPacketer = new NmeaPacketer();
			message = packeter.newReadPacket(message)[0];
			var parsedMessage:* = NmeaInterpreter.processWithMessageCode(message);
			
			
			assertTrue(parsedMessage.data is Hcc);
			assertEquals(parsedMessage.key, "hcc");
			assertEquals(parsedMessage.data.compassHeading, 1235);

			//TODO more asserts
			
		}
		
		[Test]
		public function testHcd():void
		{
			var message:String = "$HCD";
			var packeter:NmeaPacketer = new NmeaPacketer();
			message = packeter.newReadPacket(message)[0];
			var parsedMessage:* = NmeaInterpreter.processWithMessageCode(message);
			
			
			assertTrue(parsedMessage.data is Hcd);
			assertEquals(parsedMessage.key, "hcd");
			assertEquals(parsedMessage.data.compassHeading, 1235);

			//TODO more asserts
			
		}
		
		[Test]
		public function testHtc():void
		{
			var message:String = "$IIHTC,001.0,T*24";
			var packeter:NmeaPacketer = new NmeaPacketer();
			message = packeter.newReadPacket(message)[0];
			var parsedMessage:* = NmeaInterpreter.processWithMessageCode(message);
			
			
			assertTrue(parsedMessage.data is Htc);
			assertEquals(parsedMessage.key, "htc");
			assertEquals(parsedMessage.data.headingTrue, 001);

			//TODO more asserts
			
		}
		
		[Test]
		public function testMda():void
		{
			var message:String = "MDA";
			var packeter:NmeaPacketer = new NmeaPacketer();
			message = packeter.newReadPacket(message)[0];
			var parsedMessage:* = NmeaInterpreter.processWithMessageCode(message);
			
			
			assertTrue(parsedMessage.data is Mda);
			assertEquals(parsedMessage.key, "mda");
			assertEquals(parsedMessage.data.headingTrue, 001);

			//TODO more asserts
			
		}
		
		[Test]
		public function testVwt():void
		{
			var message:String = "$IIVWT,052.5,L,11.4,N,5.9,M,21.1,K*59";
			var packeter:NmeaPacketer = new NmeaPacketer();
			message = packeter.newReadPacket(message)[0];
			var parsedMessage:* = NmeaInterpreter.processWithMessageCode(message);
			
			
			assertTrue(parsedMessage.data is Vwt);
			assertEquals(parsedMessage.key, "vwt");
			assertEquals(parsedMessage.data.relativeWindAngleToVessel, 52.5);

			//TODO more asserts
			
		}
		
		[Test]
		public function testXte():void
		{
			var message:String = "$IIXTE,A,A,0.00,R,N,A*0A";
			var packeter:NmeaPacketer = new NmeaPacketer();
			message = packeter.newReadPacket(message)[0];
			var parsedMessage:* = NmeaInterpreter.processWithMessageCode(message);
			
			
			assertTrue(parsedMessage.data is Xte);
			assertEquals(parsedMessage.key, "xte");
			assertEquals(parsedMessage.data.xteMagnitude, 0.0);

			//TODO more asserts
			
		}

		
		
	}
}