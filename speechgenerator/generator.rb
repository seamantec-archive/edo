
segments = [
  "0"  ,
  "1"  ,
  "2"  ,
  "3"  ,
  "4"  ,
  "5"  ,
  "6"  ,
  "7"  ,
  "8"  ,
  "9"  ,
  "10" ,
  "11" ,
  "12" ,
  "13" ,
  "14" ,
  "15" ,
  "16" ,
  "17" ,
  "18" ,
  "19" ,
  "20" ,
  "30" ,
  "40" ,
  "50" ,
  "60" ,
  "70" ,
  "80" ,
  "90" ,
  "100",
  "200",
  "300",
  "400",
  "500",
  "600",
  "700",
  "800",
  "900",
  "wind speed is ",
  "water depth is ",
  "water temperature is ",
  "boat speed is ",
  "current depth is ", 
  "ship is too close ",
  "wind angle is ",
  "knots",
  "miles per hour",
  "kilometer per hour",
  "meter per secundum",
  "nautical miles",
  "beaufort",
  "miles",
  "kilometers",
  "meters",
  "degree",
  "feets",
  "fathom",
  "points",
  "celsius",
  "fahrenheit",
  "kevlin",
  "percent",
  "water depth changed dramatically",
  "wind changed dramatically",
  "water temperature changed dramatically",
  "no connection",
  "no data",
  "not valid",
  "cross track error is",
  "minus",
  "anchor",
  "wind direction shift is",
  "waypoint distance is",
  "AIS Vessel will be in",
  "off course is",
  "performance is"
  ]
  
output_dir = "/Users/pepusz/Documents/munka/vitorlas/src/generated_speeches"  
aiff_dir = "/Users/pepusz/desktop/speech/aiffs"
speech_container_file = "/Users/pepusz/Documents/munka/vitorlas/src/air/src/com/alarm/speech/SpeechContainer_generated.as"
if File.exist?(speech_container_file )
  File.delete(speech_container_file )
end

file = File.new(speech_container_file, File::RDWR|File::CREAT, 0777)

embed_vars = ""
container_var =" public static var container:Object = {"
segments_length = segments.length-1
segments.each_with_index do |s, i|
 `say #{s} -o #{aiff_dir}/#{s.gsub(" ", "_")}.aiff`
 `lame -m m #{aiff_dir}/#{s.gsub(" ", "_")}.aiff #{output_dir}/#{s.gsub(" ", "_")}.mp3`
 
 embed_vars = embed_vars + "[Embed(source=\"../../../../assets/speech/#{s.gsub(" ", "_")}.mp3\")] \n private static var _#{s.gsub(" ", "_")}:Class;\n"
 
 container_var = container_var + "\"#{s.gsub(" ", "")}\": new _#{s.gsub(" ", "_")}() as Sound#{i!=segments_length ? "," : ""}\n"
end
container_var = container_var+ "}"
file.puts "/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.14.
 * Time: 17:03
 * To change this template use File | Settings | File Templates.
 */
package com.alarm.speech {
import flash.media.Sound;
import flash.utils.Dictionary;

public class SpeechContainer {
"

file.puts(embed_vars)
file.puts("\n")
file.puts("\n")
file.puts("\n")
file.puts("\n")
file.puts(container_var)


file.puts "    }
}
"

file.close
