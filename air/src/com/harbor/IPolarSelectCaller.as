/**
 * Created by pepusz on 2014.02.06..
 */
package com.harbor {
public interface IPolarSelectCaller {
    function gotSelectResult(entries:Vector.<PolarFile>):void
    function gotAfterInsertResult(entry:PolarFile):void
}
}
