#!/bin/bash
#/cygdrive/c/
ACOMPC="/Users/pepusz/Dev_sdks/air_27/bin/acompc"
ADT="/Users/pepusz/Dev_sdks/air_27/bin/adt"

SWFVERSION=38

INCLUDE_CLASSES="com.seamantec.hwKeyAne.HwKeyAne"
NAME="HwKeyANE"

echo "GENERATING SWC"
$ACOMPC -source-path src/ -include-classes $INCLUDE_CLASSES -swf-version=$SWFVERSION -output $NAME.swc -debug=false
$ACOMPC -source-path src/ -include-classes $INCLUDE_CLASSES -swf-version=$SWFVERSION -output Windows-x86/win_$NAME.swc -debug=false
$ACOMPC -source-path src/ -include-classes $INCLUDE_CLASSES -swf-version=$SWFVERSION -output MacOS-x86/mac_$NAME.swc -debug=false
$ACOMPC -source-path src/ -include-classes $INCLUDE_CLASSES -swf-version=$SWFVERSION -output MacOS-x86-64/mac_$NAME.swc -debug=false
sleep 3


echo "GENERATING LIBRARY from SWC WIN"
cd "Windows-x86"
unzip win_$NAME.swc
sleep 2
[[ -f "catalog.xml" ]] && rm -f "catalog.xml"
#mv "library.swf" "lib/library.swf"
rm win_$NAME.swc
cd ".."

echo "GENERATING LIBRARY from SWC MAC"
cd "MacOS-x86"
unzip mac_$NAME.swc
sleep 2
[[ -f "catalog.xml" ]] && rm -f "catalog.xml"
#mv "library.swf" "lib/library.swf"
rm mac_$NAME.swc
cd ".."


echo "GENERATING LIBRARY from SWC MAC"
cd "MacOS-x86-64"
unzip mac_$NAME.swc
sleep 2
[[ -f "catalog.xml" ]] && rm -f "catalog.xml"
#mv "library.swf" "lib/library.swf"
rm mac_$NAME.swc
cd ".."


echo "GENERATING ANE"
$ADT -package -target ane HwKeyAne.ane descriptor.xml -swc $NAME.swc -platform MacOS-x86 -C MacOS-x86 . -platform MacOS-x86-64 -C MacOS-x86-64 . -platform Windows-x86 -C Windows-x86 .
#[[ -f "MacOS-x86/lib/library.swf" ]] && rm -f "MacOS-x86/lib/library.swf"
#[[ -f "Windows-x86/lib/library.swf" ]] && rm -f "Windows-x86/lib/library.swf"
sleep 2

echo "DONE!"



