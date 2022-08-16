/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 11/6/13
 * Time: 1:11 PM
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.socket {
public class PortScannerTest {
    private var scanner:PortScanner;

    public function PortScannerTest() {
        scanner = PortScanner.getInstance();
    }

    [Test]
    public function scanTest():void {
        scanner.scan();
        for each(var port in scanner.hosts) {
            trace(port);
        }
    }

    [Test]
    public function getHostsTest():void {
        for each(var address in scanner.getHosts()) {
            trace(address);
        }
    }
}
}
