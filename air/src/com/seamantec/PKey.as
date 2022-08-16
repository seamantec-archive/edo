/**
 * Created by pepusz on 2014.02.13..
 */
package com.seamantec {
public class PKey {
    static const pKeyDev:String = "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvNQSdnqY7uFJlf4uEuLc\nwj3RtWoyCYamnlW/gcAtdkrdSBStKnQjbBO4gyI8Ou7VxfAUMyEBIxcSn6xhpdkV\nFySk2Ejso/gcame/93fst0ohn76ctHMko/9R22eNXU3dY+2BdDgwtM+BqlBWMAHm\nMYQibEhfi0DkUpGdmMa8TG3IkWux5WREpSx1yAeUPHM4NdHGRsGtfNxdbT5VZuD6\nrk/vSg3WGiNmEXu+ainksn7cQ3AceWdSLo0KYgvqgiF79sLB7IOM3e8RPpKnV5ad\nuEC1HuVEhV6P9SzqswsmvKl0suE5koWbC09vCXGyQowFk65aK5F0PCvgzdiecWCd\n3wIDAQAB\n-----END PUBLIC KEY-----\n"
    static const pKeyProd:String = "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4BPBimaYhc6XzKO625kq\n5SlxLF0KuIYu6rIjYgwRirU/znpqkRMLjSKIvRBDuih56vfv9iz2f7Se0gpeHAR3\nQEaHM+a0G1i5rifPuU+nRrKbqTG9LTvxsF6MeJASTcAbtwR3ia3DIWP0e3/3lpCN\n7yxJvIiPRm+8Vv6MvuQ9OiGKh7mdh1JD9Qo7tXq5AUnvD/9w1I7Dv1BKGzpoj+14\noWmZ7uYwh5RgQJbC1uPKxkIdddrgnAYFUdU2kW7kwsFShq/Q89+fp8fO8LDGtcL8\nN587/9wQYI381rcRve0WwK9nfT+sagrQqYgo8BLs53ojWUv3E/bLDkZEh8diow9Q\nWwIDAQAB\n-----END PUBLIC KEY-----\n"
    static var _pKey:String = ""

    public static function setPKeyForEnv(env:String):void {
        if (env == "dev") {
            _pKey = pKeyDev
        } else if (env == "prod") {
            _pKey = pKeyProd;
        }
    }

    public static function get pKey():String {
        if (_pKey == "") {
            _pKey = pKeyDev;
        }
        return _pKey;
    }
}
}
