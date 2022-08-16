/*******************************************************************************************************************************************
 * This is an automatically generated class. Please do not modify it since your changes may be lost in the following circumstances:
 *     - Members will be added to this class whenever an embedded worker is added.
 *     - Members in this class will be renamed when a worker is renamed or moved to a different package.
 *     - Members in this class will be removed when a worker is deleted.
 *******************************************************************************************************************************************/

package {

import flash.utils.ByteArray;

public class Workers {
    private static var com_workers_ZoomLevelCalulator_ByteClass:Class;
    private static var com_workers_ParserWorker_ByteClass:Class;
    private static var com_workers_NmeaLogReader_ByteClass:Class;

    [Embed(source="../workerswfs/com/workers/ParserWorker.swf", mimeType="application/octet-stream")]
    private static var parserWorker:Class;

    [Embed(source="../workerswfs/com/workers/NmeaLogReader.swf", mimeType="application/octet-stream")]
    private static var nmeaLogReader:Class;
    [Embed(source="../workerswfs/com/workers/PolarWorker.swf", mimeType="application/octet-stream")]
    private static var PolarWorker:Class;
//		[Embed(source="../workerswfs/com/workers/ZoomLevelCalulator.swf", mimeType="application/octet-stream")]
//		private static var zoomLevelCalulator:Class;
    public static function get com_workers_ParserWorker():ByteArray {
        return new parserWorker();

    }

    public static function get com_workers_NmeaLogReader():ByteArray {
        return new nmeaLogReader();
    }

    public static function get com_workers_PolarWorker():ByteArray {
        return new PolarWorker();
    }


}
}
