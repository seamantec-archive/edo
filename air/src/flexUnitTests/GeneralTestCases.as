package flexUnitTests
{
import com.utils.GeneralUtils;

public class GeneralTestCases
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
		}*/
		
		[Test]
		public function capitalizeString():void{
			var testSting:String = "vhw_waterHeadingMagnetic";
			var needResult:String = "Vhw Water Heading Magnetic";
			assertEquals(GeneralUtils.generateCapitalizedSentence(testSting), needResult);
		}
		
		
	}
}