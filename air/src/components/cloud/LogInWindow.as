/**
 * Created by seamantec on 12/02/15.
 */
package components.cloud {
import com.events.CloudEvent;
import com.ui.controls.AlarmDownBtn;
import com.harbor.CloudHandler;
import com.utils.FontFactory;

import components.windows.FloatWindow;

import flash.display.Bitmap;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldType;

public class LogInWindow extends FloatWindow {

    [Embed(source="../../../assets/images/inputfield.png")]
    public static var inputfield:Class;

    private static const EMAIL_REGEXP:RegExp = /^[\w.-]+@\w[\w.-]+\.[\w.-]*[a-z][a-z]$/i;

    private static var _emailLabel:TextField;
    private static var _emailInput:TextField;
    private static var _passwordLabel:TextField;
    private static var _passwordInput:TextField;

    private static var _errorLabel:TextField;

    private static var _signButton:AlarmDownBtn;

    private static var _bitmap1:Bitmap = new inputfield();
    private static var _bitmap2:Bitmap = new inputfield();

//    private var _loggedIn:Boolean;
    private var _x:Number;

    public function LogInWindow() {
        super("Log in");

        CloudHandler.instance.addEventListener(CloudEvent.SIGNIN_COMPLETE, onSignInComplete, false, 0, true);
        CloudHandler.instance.addEventListener(CloudEvent.SIGNIN_ERROR, onSignInError, false, 0, true);

        createContent();

        _signButton = this.addDownButton(2, "Log in", buttonHandler);

        _emailInput.text = "";
        _passwordInput.text = "";

        this.resizeable = false;
        this.resize(_w, _h*0.6);
        this.width = _w;
        this.height = _h;
        this.repositionElements();

        stage.addEventListener(KeyboardEvent.KEY_UP, keyboardHandler, false, 0, true);
    }

    private function createContent():void {
        _x = ((this.width - _frame.getWidthAndContentDiff())/2) - (_bitmap1.width/2);

        _bitmap1.x = _x;
        _bitmap1.y = 69;
        _content.addChild(_bitmap1);
        _bitmap2.x = _x;
        _bitmap2.y = 119;
        _content.addChild(_bitmap2);

        addError();
        addEmailAndPassword();
    }

    private function addError():void {
        if(_errorLabel==null) {
            _errorLabel = FontFactory.getCustomFont({color: 0xff0000, size: 12, bold: true, width: _bitmap1.width - 2});
            _errorLabel.x = _x + 1;
            _errorLabel.y = 8;
            _errorLabel.height = 50;
            _errorLabel.multiline = true;
            _errorLabel.wordWrap = true;
        }
        _errorLabel.visible = false;
        _content.addChild(_errorLabel);
    }

    private function addEmailAndPassword():void {
        if(_emailLabel==null) {
            _emailLabel = FontFactory.getCustomFont({size: 14, bold: true, color: 0xFFFFFF, width: _bitmap1.width - 2});
            _emailLabel.text = "Email";
            _emailLabel.x = _x;
            _emailLabel.y = 50;
        }
        _content.addChild(_emailLabel);

        if(_emailInput==null) {
            _emailInput = FontFactory.getCustomFont({size: 12, selectable: true, color: 0x000000});
            _emailInput.width = _bitmap1.width - 2;
            _emailInput.height = _bitmap1.height - 2;
            _emailInput.x = _x + 1;
            _emailInput.y = 70 + 1;
            _emailInput.textColor = 0x000000;
            _emailInput.type = TextFieldType.INPUT;
            _emailInput.tabIndex = 0;
        }
        _content.addChild(_emailInput);

        stage.focus = _emailInput;

        if(_passwordLabel==null) {
            _passwordLabel = FontFactory.getCustomFont({size: 14, bold: true, color: 0xFFFFFF});
            _passwordLabel.text = "Password";
            _passwordLabel.x = _x;
            _passwordLabel.y = 100;
        }
        _content.addChild(_passwordLabel);

        if(_passwordInput==null) {
            _passwordInput = FontFactory.getCustomFont({size: 12, selectable: true, color: 0x000000});
            _passwordInput.width = _bitmap2.width - 2;
            _passwordInput.height = _bitmap2.height - 2;
            _passwordInput.x = _x + 1;
            _passwordInput.y = 120 + 1;
            _passwordInput.textColor = 0x000000;
            _passwordInput.type = TextFieldType.INPUT;
            _passwordInput.displayAsPassword = true;
        }
        _content.addChild(_passwordInput);
    }

    private function buttonHandler(event:MouseEvent):void {
        signIn();
    }

    private function onSignInComplete(event:CloudEvent):void {
        this.close();
    }

    private function onSignInError(event:CloudEvent):void {
        signedError(event.data as Array);
    }

    private function keyboardHandler(event:KeyboardEvent):void {
        if(event.charCode==9) {
            if(stage.focus==_emailInput) {
                stage.focus = _passwordInput;
            } else if(stage.focus==_passwordInput) {
                stage.focus = _emailInput;
            }
        } else if(event.charCode==13) {
            signIn();
        }
    }

    private function signIn():void {
        var errors:Array = new Array();
        if(_emailInput.text.length==0 || !EMAIL_REGEXP.test(_emailInput.text.replace(/\s/g, ""))) {
            errors.push("The email address is not valid.\n");
        }
        if(_passwordInput.text.length<8) {
            errors.push("The minimum password length is 8.\n");
        }
        if(errors.length==0) {
            CloudHandler.instance.signIn(_emailInput.text, _passwordInput.text);
        } else {
            signedError(errors);
        }
    }

    private function signedOut():void {
        _errorLabel.visible = false;
    }

    private function signedError(errors:Array):void {
        _errorLabel.visible = true;

        var error:String = "";
        if(errors!=null) {
            var length:int = errors.length;
            for (var i:int = 0; i < length; i++) {
                error += errors[i] as String;
            }
        }
        _errorLabel.text = error;
    }
}
}
