package flexUnitTests
{
import com.loggers.LogRegister;
import com.utils.GraphDataHandler;

import flash.filesystem.File;

public class GraphDataHandlerTest
	{		
		static var tempFile:File;
		static var testDatasDirectory:File;
		static var testLog:File = new File("/Users/pepusz/Documents/munka/vitorlas/GPSGATE_log/Norvik/Log 2012-05-21 161506.nmea");
		private static var logEntry:Object;
		private static var graphDataHandler:GraphDataHandler;
		[Before]
		public function setUp():void
		{			
			
		}
		
		[After]
		public function tearDown():void
		{
			//tempFile.deleteFile();
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
			try{
				new File("/Users/pepusz/Library/Application Support/FlexUnitApplication/Local Store/Log 2012-05-21 161506.nmea_graphCache.db").deleteFile();
			}catch(e:Error){
				
			}
			testDatasDirectory = new File(File.applicationDirectory.nativePath + "/../testDatas/");
			var logfile:File = testDatasDirectory.resolvePath("logregister.db");
			tempFile =  testDatasDirectory.resolvePath("logregister_temp.db");
			logfile.copyTo(tempFile, true);
			new LogRegister(tempFile.nativePath);
			logEntry= LogRegister.instance.getLogEntry(testLog);
			graphDataHandler = new GraphDataHandler();
			graphDataHandler.openLogEntry(logEntry);
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test]
		public function copyAllATimestampTable():void{
			//graphDataHandler.copyAllTimestamps();			
			var graphCacheEntry:Object = LogRegister.instance.getGraphCacheEntry(logEntry.id);			
			assertEquals(graphCacheEntry.last_timestamp, logEntry.last_timestamp);
		}
		
		[Test]
		public function copyAllDataForVhw():void{
			graphDataHandler.importDataForTable("vhw_waterHeadingMagnetic");
			graphDataHandler.importDataForTable("vhw_waterHeadingTrue");
		}
		
		[Test]
		public function copyAllDataFormwv():void{
			graphDataHandler.importDataForTable("mwv_windSpeedKnots");
		}
		
		
		
	}
}