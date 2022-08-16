package {

import com.seamantec.LicenseManager;

import flash.display.Sprite;
import flash.text.TextField;

public class Swc extends Sprite {
    public function Swc() {
        //var licenseManager:LicenseManager = new LicenseManager()
        var textField:TextField = new TextField();
        textField.text = "Hello, World";
        addChild(textField);
    }
}
}
