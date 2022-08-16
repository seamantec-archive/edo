/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 19/11/13
 * Time: 12:35
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.socket {

public class ScannerPort {

    public var type:String;
    public var ip:String;
    public var port:uint;
    public var name:String;
    public var baud:uint;

    public function ScannerPort(type:String, ip:String = null,  port:uint = 0, name:String = null, baud:uint = 0) {
        this.type = type;
        this.ip = ip;
        this.port = port;
        this.name = name;
        this.baud = baud;
    }
}
}
