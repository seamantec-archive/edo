/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 19/11/13
 * Time: 12:29
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.socket {
import flash.net.Socket;

public class ScannerSocket {
    public var socket:Socket;
    public var status:Boolean;
    public var sendCounter:uint;

    public function ScannerSocket(socket:Socket,  status:Boolean = true, counter:uint = 0) {
        this.socket = socket;
        this.status = status;
        this.sendCounter = counter;
    }
}
}
