/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.12.07.
 * Time: 15:42
 * To change this template use File | Settings | File Templates.
 */
package com.seamantec {
import by.blooddy.crypto.MD5;

import com.hurlant.crypto.Crypto;
import com.hurlant.crypto.symmetric.ICipher;
import com.hurlant.crypto.symmetric.IVMode;
import com.hurlant.util.Base64;
import com.hurlant.util.Hex;

import flash.utils.ByteArray;

public class AES {
    /**
     * For Encryption:
     Input is expected to be plain, normal human readable text.
     The key is expected to be plain, normal human readable text.
     The IV is expected to be in plain, normal human readable text.

     Output data is base64. Why base64?  Base64 is a form of encoding that can be sent over
     the wire so to speak, so typically you see output and input of cryptographic operations
     as b64 so it can travel across networks, between technologies.

     Output IV is also base64.
     If you are using an IV, it's common practice to send the IV along with the encrypted data.
     */
    public static function encrypt(_InPlainData:String, key:String, iv:String):Vector.<String> {

        var keyBa:ByteArray = new ByteArray();
        keyBa.writeUTFBytes(key);
        var ivdata:ByteArray = Base64.decodeToByteArray(iv);
        // encrypt the data. simple-aes-cbc is equiv. to aes-256-cbc in openssl/ruby, if your key is
        // long enough (an MD5 is 32 bytes long)
        var data:ByteArray = Hex.toArray(Hex.fromString(_InPlainData));
        var mode:ICipher = Crypto.getCipher("aes-256-ofb", keyBa);
        if (mode is IVMode) {
            var ivmode:IVMode = mode as IVMode;
            // Just remember this is just a cast. The IV is still being set on the mode variable.
            ivmode.IV = ivdata
        }
        mode.encrypt(data);
        var returnIVandData:Vector.<String> = new Vector.<String>();
        returnIVandData.push(ivdata);
        returnIVandData.push(Base64.encodeByteArray(data));
        return returnIVandData;
    }

    /**
     For Decryption:
     Input is expected to be base 64 encoded.
     The key is expected to be plain, normal human readable text.
     The IV is expected to be base 64 encoded.

     Decrypted output is plain, normal human readable text.
     */
    public static function decrypt(_data:String, key:String):String {
        var dataAndIv:Array = _data.split("$")
        var keyBa:ByteArray = new ByteArray();
        keyBa.writeUTFBytes(key);
        var data:ByteArray = Base64.decodeToByteArray(dataAndIv[1]);
        var mode:ICipher = Crypto.getCipher("aes-256-ofb", keyBa);
        var ivdata:ByteArray = Base64.decodeToByteArray(dataAndIv[0]);

        if (mode is IVMode) {
            var ivmode:IVMode = mode as IVMode;
            // Just remember this is just a cast. The IV is still being set on the mode variable.
            ivmode.IV = ivdata
        }
        mode.decrypt(data)
        return Hex.toString(Hex.fromArray(data));;
    }
}
}
