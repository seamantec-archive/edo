/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.11.
 * Time: 11:33
 * To change this template use File | Settings | File Templates.
 */
package com.utils {
public class HeadingUtil {
    private static 	var regexpForKey:RegExp = new RegExp(/vhw/);  //|hdg

    public static function isKeyInRegexp(key:String):Boolean{
        return key.match(regexpForKey);
    }

}
}
