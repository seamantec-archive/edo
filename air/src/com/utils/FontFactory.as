/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.07.
 * Time: 13:28
 * To change this template use File | Settings | File Templates.
 */
package com.utils {
import flash.text.AntiAliasType;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

public class FontFactory {

//    [Embed(source="../../../assets/fonts/Arial.ttf",
//            fontFamily="Arial",
//            mimeType="application/x-font",
//            fontWeight="normal",
//            fontStyle="normal",
//            advancedAntiAliasing="true",
//            embedAsCFF="false")]
//    private static var Arial:Class;
//    Font.registerFont(Arial);

    [Embed(source="../../../assets/fonts/Amble-Regular.ttf",
            fontFamily="ArialX",
            mimeType="application/x-font",
            fontWeight="normal",
            fontStyle="normal",
            advancedAntiAliasing="true",
            embedAsCFF="false")]
    private static var Arial2:Class;
    Font.registerFont(Arial2);

    [Embed(source="../../../assets/fonts/Amble-Bold.ttf",
            fontFamily="ArialX",
            mimeType="application/x-font",
            fontWeight="bold",
            fontStyle="normal",
            advancedAntiAliasing="true",
            embedAsCFF="false")]
    private static var Arial2Bold:Class;
    Font.registerFont(Arial2Bold);

    [Embed(source="../../../assets/fonts/digital_edo_pr.ttf",
            fontFamily="digitalx",
            mimeType="application/x-font",
            fontWeight="normal",
            fontStyle="normal",
            advancedAntiAliasing="true",
            embedAsCFF="false")]
    private static var digitalFont:Class;
    Font.registerFont(digitalFont);

    public static var leftFormatter:TextFormat;
    public static var leftBlackFormatter:TextFormat;
    public static var centerFormatter:TextFormat;
    public static var rightFormatter:TextFormat;
    public static var rightBlackFormatter:TextFormat;
    public static var leftDigitalFormatter:TextFormat;
    public static var left8BlackFormatter:TextFormat;
    public static var center10BlackFormatter:TextFormat;
    public static var dataAxisFormatter:TextFormat;
    public static var timeAxisFormatter:TextFormat;
    public static var alarmTitleFormatter:TextFormat;
    public static var alarmRedFormatter:TextFormat;
    public static var alarmBlackFormatter:TextFormat;
    public static var centerGraphLabelFormatter:TextFormat;
    public static var shipInfo:TextFormat;
    public static var nmeaMSGformatter:TextFormat;
    public static var logFilenameFormatter:TextFormat;

    public static var arialText:String = "ArialX";
    public static var arialBoldText:String = "ArialX";

    private static function initformatters():void {
        if (leftFormatter == null) {
            leftFormatter = new TextFormat();
            leftFormatter.align = TextFormatAlign.LEFT;
            leftFormatter.font = arialText;
            leftFormatter.size = 12;
            leftFormatter.color = 0xFFFFFF;
        }
        if (leftBlackFormatter == null) {
            leftBlackFormatter = new TextFormat();
            leftBlackFormatter.align = TextFormatAlign.LEFT;
            leftBlackFormatter.font = arialText;
            leftBlackFormatter.size = 12;
            leftBlackFormatter.color = 0x000000;
        }
        if (left8BlackFormatter == null) {
            left8BlackFormatter = new TextFormat();
            left8BlackFormatter.align = TextFormatAlign.LEFT;
            left8BlackFormatter.font = arialText;
            left8BlackFormatter.size = 8;
            left8BlackFormatter.color = 0x000000;
        }
        if (rightFormatter == null) {
            rightFormatter = new TextFormat();
            rightFormatter.align = TextFormatAlign.RIGHT;
            rightFormatter.font = arialText;
            leftBlackFormatter.size = 12;
            rightFormatter.color = 0xFFFFFF;
        }
        if (rightBlackFormatter == null) {
            rightBlackFormatter = new TextFormat();
            rightBlackFormatter.align = TextFormatAlign.RIGHT;
            rightBlackFormatter.font = arialText;
            rightBlackFormatter.color = 0x000000;
        }
        if (centerFormatter == null) {
            centerFormatter = new TextFormat();
            centerFormatter.align = TextFormatAlign.CENTER;
            centerFormatter.font = arialText;
            centerFormatter.color = 0x000000;
        }
        if (centerGraphLabelFormatter == null) {
            centerGraphLabelFormatter = new TextFormat();
            centerGraphLabelFormatter.align = TextFormatAlign.CENTER;
            centerGraphLabelFormatter.font = arialText;
            leftBlackFormatter.size = 14;
            centerGraphLabelFormatter.color = 0xffffff;
        }
        if (leftDigitalFormatter == null) {
            leftDigitalFormatter = new TextFormat();
            leftDigitalFormatter.align = TextFormatAlign.LEFT;
            leftDigitalFormatter.font = "digitalx";
            leftDigitalFormatter.color = 0x000000;
        }

        if (center10BlackFormatter == null) {
            center10BlackFormatter = new TextFormat();
            center10BlackFormatter.align = TextFormatAlign.CENTER;
            center10BlackFormatter.font = arialText;
            center10BlackFormatter.size = 10;
            center10BlackFormatter.color = 0x000000;
        }
        if (dataAxisFormatter == null) {
            dataAxisFormatter = new TextFormat();
            dataAxisFormatter.align = TextFormatAlign.RIGHT;
            dataAxisFormatter.font = arialText;
            dataAxisFormatter.size = 12;
            dataAxisFormatter.color = 0xffffff;
        }
        if (timeAxisFormatter == null) {
            timeAxisFormatter = new TextFormat();
            timeAxisFormatter.align = TextFormatAlign.CENTER;
            timeAxisFormatter.font = arialText;
            timeAxisFormatter.size = 12;
            timeAxisFormatter.color = 0xffffff;
        }
        if (alarmTitleFormatter == null) {
            alarmTitleFormatter = new TextFormat();
            alarmTitleFormatter.align = TextFormatAlign.CENTER;
            alarmTitleFormatter.font = arialText;
            alarmTitleFormatter.size = 16;
            alarmTitleFormatter.color = 0x000000;
            alarmTitleFormatter.bold = false;
        }
        if (alarmRedFormatter == null) {
            alarmRedFormatter = new TextFormat();
            alarmRedFormatter.align = TextFormatAlign.RIGHT;
            alarmRedFormatter.font = arialText;
            alarmRedFormatter.size = 13;
            alarmRedFormatter.color = 0xff0000;
            alarmRedFormatter.bold = false;
        }
        if (alarmBlackFormatter == null) {
            alarmBlackFormatter = new TextFormat();
            alarmBlackFormatter.align = TextFormatAlign.RIGHT;
            alarmBlackFormatter.font = arialText;
            alarmBlackFormatter.size = 13;
            alarmBlackFormatter.color = 0x000000;
            alarmBlackFormatter.bold = false;
        }
        if (shipInfo == null) {
            shipInfo = new TextFormat();
            shipInfo.align = TextFormatAlign.LEFT;
            shipInfo.font = arialText;
            shipInfo.size = 13;
            shipInfo.color = 0x000000;
            shipInfo.bold = false;
        }

        if (nmeaMSGformatter == null) {
            nmeaMSGformatter = new TextFormat();
            nmeaMSGformatter.align = TextFormatAlign.LEFT;
            nmeaMSGformatter.font = arialText;
            nmeaMSGformatter.size = 13;
            nmeaMSGformatter.color = 0x000000;
            nmeaMSGformatter.bold = true;
        }
        if (logFilenameFormatter == null) {
            logFilenameFormatter = new TextFormat();
            logFilenameFormatter.align = TextFormatAlign.CENTER;
            logFilenameFormatter.font = arialText;
            logFilenameFormatter.size = 10;
            logFilenameFormatter.color = 0xffffff;
            logFilenameFormatter.bold = false;
            logFilenameFormatter.leftMargin = 0;
            logFilenameFormatter.rightMargin = 0;
        }
    }


    public static function getLeftTextField():TextField {
        initformatters();
        var tf:TextField = new TextField();
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.selectable = false;
        tf.background = false;
        tf.defaultTextFormat = leftFormatter;
        tf.antiAliasType = AntiAliasType.ADVANCED;
        tf.embedFonts = true;
        return tf
    }

    public static function getLeftBlackTextField():TextField {
        initformatters();
        var tf:TextField = new TextField();
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.selectable = false;
        tf.background = false;
        tf.defaultTextFormat = leftBlackFormatter;
        tf.antiAliasType = AntiAliasType.ADVANCED;
        tf.embedFonts = true;
        return tf
    }

    public static function getLeft8BlackTextField():TextField {
        initformatters();
        var tf:TextField = new TextField();
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.selectable = false;
        tf.background = false;
        tf.defaultTextFormat = left8BlackFormatter;
        tf.embedFonts = true;
        return tf
    }

    public static function getRightTextField():TextField {
        initformatters();
        var tf:TextField = new TextField();
        tf.autoSize = TextFieldAutoSize.RIGHT;
        tf.selectable = false;
        tf.background = false;
        tf.defaultTextFormat = rightFormatter;
        tf.embedFonts = true;
        return tf
    }

    public static function getRightBlackTextField():TextField {
        initformatters();
        var tf:TextField = new TextField();
        tf.autoSize = TextFieldAutoSize.RIGHT;
        tf.selectable = false;
        tf.background = false;
        tf.defaultTextFormat = rightBlackFormatter;
        tf.embedFonts = true;
        return tf
    }

    public static function getCenterTextField():TextField {
        initformatters();
        var tf:TextField = new TextField();
        tf.autoSize = TextFieldAutoSize.CENTER;
        tf.selectable = false;
        tf.background = false;
        tf.defaultTextFormat = centerFormatter;
        tf.embedFonts = true;
        return tf
    }

    public static function getCenterGraphLabelTextField():TextField {
        initformatters();
        var tf:TextField = new TextField();
        tf.autoSize = TextFieldAutoSize.CENTER;
        tf.selectable = false;
        tf.background = false;
        tf.defaultTextFormat = centerGraphLabelFormatter;
        tf.embedFonts = true;
        return tf
    }

    public static function getCenter10BlackTextField():TextField {
        initformatters();
        var tf:TextField = new TextField();
        tf.autoSize = TextFieldAutoSize.CENTER;
        tf.selectable = false;
        tf.background = false;
        tf.defaultTextFormat = center10BlackFormatter;
        tf.embedFonts = true;
        return tf
    }

    public static function getLeftDigitalTextField():TextField {
        initformatters();
        var tf:TextField = new TextField();
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.selectable = false;
        tf.background = false;
        tf.defaultTextFormat = leftDigitalFormatter;
        tf.embedFonts = true;
        tf.antiAliasType = AntiAliasType.ADVANCED;
        return tf
    }

    public static function getAlarmTitleTextField():TextField {
        initformatters();
        var tf:TextField = new TextField();
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.selectable = false;
        tf.background = false;
        tf.defaultTextFormat = alarmTitleFormatter;
        tf.embedFonts = true;
        tf.antiAliasType = AntiAliasType.ADVANCED;
        return tf
    }


    public static function getCustomFont(options = null):TextField {
        var tformat:TextFormat = new TextFormat();
        tformat.font = arialText;
        if (options["align"]) tformat.align = options["align"];
        tformat.color = options["color"];
        tformat.size = options["size"];
        tformat.underline = options["underline"] == null ? false : options["underline"];
        tformat.italic = options["italic"] == null ? false : options["italic"];
        tformat.bold = options["bold"] == null ? false : options["bold"];
        tformat.leading = options["leading"]
        var tf:TextField = new TextField();
        if (options["autoSize"]) tf.autoSize = options["autoSize"];
        tf.selectable = options["selectable"] == null ? false : options["selectable"];

        tf.background = false;
        tf.defaultTextFormat = tformat;
        options["width"] != null ? tf.width = options["width"] : 0;
        options["height"] != null ? tf.height = options["height"] : 0;
        tf.embedFonts = true;
        tf.antiAliasType = AntiAliasType.ADVANCED;
        tf.alpha = options.hasOwnProperty("alpha") ? options["alpha"] : 1.0;

        return tf
    }

    public static function getCustomDigital(options = null):TextField {
        var tformat:TextFormat = new TextFormat();
        tformat.font = "digitalx";
        if (options["align"]) tformat.align = options["align"];
        tformat.color = options["color"];
        tformat.size = options["size"];
        tformat.underline = options["underline"] == null ? false : options["underline"];
        tformat.italic = options["italic"] == null ? false : options["italic"];
        tformat.bold = options["bold"] == null ? false : options["bold"];
        var tf:TextField = new TextField();
        if (options["autoSize"]) tf.autoSize = options["autoSize"];
        tf.selectable = false;
        tf.background = false;
        tf.defaultTextFormat = tformat;
        if (options["width"] != null)tf.width = options["width"];
        if (options["height"] != null)tf.height = options["height"];
        tf.embedFonts = true;
        tf.antiAliasType = AntiAliasType.ADVANCED;

        return tf
    }


    public static function getDataAxisFont():TextField {
        initformatters();
        var tf:TextField = new TextField();
        tf.autoSize = TextFieldAutoSize.RIGHT;
        tf.selectable = false;
        tf.background = false;
        tf.defaultTextFormat = dataAxisFormatter;
        tf.embedFonts = true;
        tf.mouseWheelEnabled = false;
        tf.mouseEnabled = false;
        tf.tabEnabled = false;
        tf.doubleClickEnabled = false;
        tf.antiAliasType = AntiAliasType.ADVANCED;
        return tf
    }

    public static function getTimeAxisFont():TextField {
        initformatters();
        var tf:TextField = new TextField();
        tf.autoSize = TextFieldAutoSize.CENTER;
        tf.selectable = false;
        tf.background = false;
        tf.defaultTextFormat = timeAxisFormatter;
        tf.embedFonts = true;
        tf.mouseWheelEnabled = false;
        tf.mouseEnabled = false;
        tf.tabEnabled = false;
        tf.doubleClickEnabled = false;
        tf.antiAliasType = AntiAliasType.ADVANCED;
        return tf
    }

    public static function getShipInfoFont():TextField {
        initformatters();
        var tf:TextField = new TextField();
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.selectable = false;
        tf.background = true;
        tf.backgroundColor = 0xffffff;
        tf.defaultTextFormat = shipInfo;
        tf.multiline = true;
        tf.wordWrap = true;
        tf.embedFonts = true;
        tf.antiAliasType = AntiAliasType.ADVANCED;
        return tf
    }

    public static function nmeaMSGfont():TextField {
        initformatters();
        var tf:TextField = new TextField();
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.selectable = false;
        tf.background = false;
        tf.defaultTextFormat = nmeaMSGformatter;
        tf.multiline = false;
        tf.wordWrap = false;
        tf.embedFonts = true;
        tf.antiAliasType = AntiAliasType.ADVANCED;
        return tf
    }

    public static function getRedFont():TextField {
        initformatters();
        var tf:TextField = new TextField();
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.selectable = false;
        tf.background = false;
        tf.defaultTextFormat = alarmRedFormatter;
        tf.multiline = false;
        tf.wordWrap = false;
        tf.embedFonts = true;
        tf.height = 25;
        tf.antiAliasType = AntiAliasType.ADVANCED;
        return tf
    }

    public static function getLogFileNameFont():TextField {
        initformatters();
        var tf:TextField = new TextField();
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.selectable = false;
        tf.background = false;
//        tf.backgroundColor = 0x000000;

        tf.defaultTextFormat = logFilenameFormatter;
        tf.multiline = false;
        tf.wordWrap = false;
        tf.embedFonts = true;
        tf.height = 25;
        tf.antiAliasType = AntiAliasType.ADVANCED;
        return tf
    }

    public static function replaceAccents(value:String):String {
        return value.replace()
    }
}
}
