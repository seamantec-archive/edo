/**
 * Created by seamantec on 09/03/15.
 */
package com.utils {

public class StringUtils {

    private static const a:RegExp = /[\u00e0-\u00e5]/g;
    private static const A:RegExp = /[\u00c0-\u00c5]/g;
    private static const e:RegExp = /[\u00e8-\u00eb]/g;
    private static const E:RegExp = /[\u00c0-\u00cb]/g;
    private static const i:RegExp = /[\u00ec-\u00ef]/g;
    private static const I:RegExp = /[\u00cc-\u00cf]/g;
    private static const o:RegExp = /[\u00f2-\u00f6]|\u014d|\u014f|\u0151/g;
    private static const O:RegExp = /[\u00d2-\u00d6]|\u014c|\u014e|\u0150/g;
    private static const u:RegExp = /[\u00f9-\u00fc]|\u0171/g;
    private static const U:RegExp = /[\u00d9-\u00dc]|\u0170/g;

    public static function replace(text:String):String {
        return text.replace(a, "a").replace(A, "A").replace(e, "e").replace(E, "E").replace(i, "i").replace(I, "I").replace(o, "o").replace(O, "O").replace(u, "u").replace(U, "U");
    }
}
}
