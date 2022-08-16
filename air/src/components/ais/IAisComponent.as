/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.13.
 * Time: 14:51
 * To change this template use File | Settings | File Templates.
 */
package components.ais {
import flash.geom.Rectangle;

public interface IAisComponent {
    function getParentBounds():Rectangle;
    function isEnoughSpaceOnTheLeft():Boolean;
    function isEnoughSpaceOnTheRight():Boolean;
    function get originWidth():Number;
    function get originHeight():Number;
}
}
