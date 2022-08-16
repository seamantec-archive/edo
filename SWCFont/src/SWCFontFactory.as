/**
 * Created by seamantec on 20/01/14.
 */
package {

import flash.display.MovieClip;
import flash.text.AntiAliasType;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFormat;

public class SWCFontFactory {
    [Embed(source="../assets/fonts/Amble-Regular.ttf",
            fontFamily="Amble",
            mimeType="application/x-font",
            fontWeight="normal",
            fontStyle="normal",
            advancedAntiAliasing="true",
            embedAsCFF="false")]
    private static var Amble:Class;
    Font.registerFont(Amble);

    [Embed(source="../assets/fonts/Amble-Bold.ttf",
            fontFamily="Amble",
            mimeType="application/x-font",
            fontWeight="bold",
            fontStyle="normal",
            advancedAntiAliasing="true",
            embedAsCFF="false")]
    private static var AmbleBold:Class;
    Font.registerFont(AmbleBold);

    [Embed(source="../assets/fonts/Amble-Italic.ttf",
            fontFamily="Amble",
            mimeType="application/x-font",
            fontWeight="normal",
            fontStyle="italic",
            advancedAntiAliasing="true",
            embedAsCFF="false")]
    private static var AmbleItalic:Class;
    Font.registerFont(AmbleItalic);

    [Embed(source="../assets/fonts/Amble-BoldItalic.ttf",
            fontFamily="Amble",
            mimeType="application/x-font",
            fontWeight="bold",
            fontStyle="italic",
            advancedAntiAliasing="true",
            embedAsCFF="false")]
    private static var AmbleBoldItalic:Class;
    Font.registerFont(AmbleBoldItalic);

    [Embed(source="../assets/fonts/LiberationSans-Regular.ttf",
            fontFamily="LiberationSans",
            mimeType="application/x-font",
            fontWeight="normal",
            fontStyle="normal",
            advancedAntiAliasing="true",
            embedAsCFF="false")]
    private static var LiberationSans:Class;
    Font.registerFont(LiberationSans);

    [Embed(source="../assets/fonts/LiberationSans-Bold.ttf",
            fontFamily="LiberationSans",
            mimeType="application/x-font",
            fontWeight="bold",
            fontStyle="normal",
            advancedAntiAliasing="true",
            embedAsCFF="false")]
    private static var LiberationSansBold:Class;
    Font.registerFont(LiberationSansBold);

    [Embed(source="../assets/fonts/LiberationSans-Italic.ttf",
            fontFamily="LiberationSans",
            mimeType="application/x-font",
            fontWeight="normal",
            fontStyle="italic",
            advancedAntiAliasing="true",
            embedAsCFF="false")]
    private static var LiberationSansItalic:Class;
    Font.registerFont(LiberationSansItalic);

    [Embed(source="../assets/fonts/LiberationSans-BoldItalic.ttf",
            fontFamily="LiberationSans",
            mimeType="application/x-font",
            fontWeight="bold",
            fontStyle="italic",
            advancedAntiAliasing="true",
            embedAsCFF="false")]
    private static var LiberationSansBoldItalic:Class;
    Font.registerFont(LiberationSansBoldItalic);

    [Embed(source="../assets/fonts/Sansation_Regular.ttf",
            fontFamily="Sansation",
            mimeType="application/x-font",
            fontWeight="normal",
            fontStyle="normal",
            advancedAntiAliasing="true",
            embedAsCFF="false")]
    private static var Sansation:Class;
    Font.registerFont(Sansation);

    [Embed(source="../assets/fonts/Sansation_Bold.ttf",
            fontFamily="Sansation",
            mimeType="application/x-font",
            fontWeight="bold",
            fontStyle="normal",
            advancedAntiAliasing="true",
            embedAsCFF="false")]
    private static var SansationBold:Class;
    Font.registerFont(SansationBold);

    [Embed(source="../assets/fonts/Sansation_Italic.ttf",
            fontFamily="Sansation",
            mimeType="application/x-font",
            fontWeight="normal",
            fontStyle="italic",
            advancedAntiAliasing="true",
            embedAsCFF="false")]
    private static var SansationItalic:Class;
    Font.registerFont(SansationItalic);

    [Embed(source="../assets/fonts/Sansation_Bold_Italic.ttf",
            fontFamily="Sansation",
            mimeType="application/x-font",
            fontWeight="bold",
            fontStyle="italic",
            advancedAntiAliasing="true",
            embedAsCFF="false")]
    private static var SansationBoldItalic:Class;
    Font.registerFont(SansationBoldItalic);

    [Embed(source="../assets/fonts/digital_regular.ttf",
            fontFamily="digitalx",
            mimeType="application/x-font",
            fontWeight="normal",
            fontStyle="normal",
            advancedAntiAliasing="true",
            embedAsCFF="false")]
    private static var Digital:Class;
    Font.registerFont(Digital);


    public static function setEDOFont1(field:TextField, instrument:MovieClip):TextField {
        return setCustomFont(field, getFont("Amble", getOptions(field, field.getTextFormat())), instrument);
    }

    public static function setEDOFont2(field:TextField, instrument:MovieClip):TextField {
        return setCustomFont(field, getFont("LiberationSans", getOptions(field, field.getTextFormat())), instrument);
    }

    public static function setEDOFont3(field:TextField, instrument:MovieClip):TextField {
        return setCustomFont(field, getFont("Sansation", getOptions(field, field.getTextFormat())), instrument);
    }

    public static function setEDOFont4(field:TextField, instrument:MovieClip):TextField {
        return setCustomFont(field, getFont("digitalx", getOptions(field, field.getTextFormat())), instrument);
    }

    public static function setCustomFont(field:TextField, newField:TextField, instrument:MovieClip):TextField {
        field.visible = false;
        var x:Number = field.x;
        var y:Number = field.y;
        field = newField;
        field.x = x;
        field.y = y;
        instrument.addChild(field);

        return field;
    }

    private static function getFont(font:String, options:Object):TextField {
        var format:TextFormat = new TextFormat();
        format.font = font;
        if(options.hasOwnProperty("align")) format.align = options["align"];
        if(options.hasOwnProperty("color")) format.color = options["color"];
        if(options.hasOwnProperty("size")) format.size = options["size"];
        if(options.hasOwnProperty("underline")) format.underline = options["underline"];
        if(options.hasOwnProperty("italic")) format.italic = options["italic"];
        if(options.hasOwnProperty("bold")) format.bold = options["bold"];
        if(options.hasOwnProperty("leading")) format.leading = options["leading"];
        if(options.hasOwnProperty("leftMargin")) format.leftMargin = options["leftMargin"];
        if(options.hasOwnProperty("rightMargin")) format.rightMargin = options["rightMargin"];
        if(options.hasOwnProperty("letterSpacing")) format.letterSpacing = options["letterSpacing"];

        var field:TextField = new TextField();
        field.selectable = false;
        field.background = false;
        field.defaultTextFormat = format;
        field.embedFonts = true;
        field.antiAliasType = AntiAliasType.ADVANCED;
        if(options.hasOwnProperty("align")) field.autoSize = options["align"];
        if(options.hasOwnProperty("width")) field.width = options["width"];
        if(options.hasOwnProperty("height")) field.height = options["height"];

        return field;
    }

    private static function getOptions(field:TextField, format:TextFormat):Object {
        return {
            width: field.width,
            height: field.height,
            align: format.align,
            color: format.color,
            size: format.size,
            underline: format.underline,
            italic: format.italic,
            bold: format.bold,
            leading: format.leading,
            leftMargin: format.leftMargin,
            rightMargin: format.rightMargin,
            letterSpacing: format.letterSpacing
        }
    }
}
}
