package components.graph {
import com.timeline.Marker;

public interface IGraph {
    function onOffLoading(type:String):void


    function updateDp(needRefresh:Boolean = false):void;

    function activateAfterLayoutChange():void;

    function setYMinMax():void;

    function get marker():Marker;

    function resetGraph(needUpdateDp:Boolean = true):void;

    function setMarkerTimeFromTimeline(time:Number, value:Number = NaN):void

    function gotNewLiveData():void;

    function get yData():String;
    function set yData(value:String):void;

    function unitChanged():void;

    function setFullZoomForLogReplay():void
    function setMarkerLabelAndScrollToEndInLiveMode():void;
}
}