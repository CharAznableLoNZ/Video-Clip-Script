#!/bin/bash
echo "Video Clip Generator Script
Press CTRL+C to stop at anytime.
The script requires mkvtoolnix (for subs) and ffmpeg to be installed."
cd ~/Videos #Desired working directory.
while true
read -e -p "What is the source filename: " sourcefile
printf "filename: %s\n" "$sourcefile"
read -p "Where do you want the encode to start? (Entered HH:MM:SS format)" -i 00:00:00 -e starttime
echo "Start Time entered $starttime"
read -p "Where should it end? (Entered HH:MM:SS format)" -i 00:05:00 -e endtime
echo "End Time Entered $endtime"
amin=$(echo $starttime | awk -F: '{print $2}') # Get minutes of starttime
asec=$(echo $starttime | awk -F: '{print $3}') # Get seconds of starttime
bmin=$(echo $endtime | awk -F: '{print $2}') # Get minutes of endtime
bsec=$(echo $endtime | awk -F: '{print $3}') # Get seconds of endtime
time=$(echo "($bmin - $amin)*60 + ($bsec-$asec)" | bc) # Calculate file size time integer
echo "Total Clip Length $time Seconds"
read -p "Would you like to make changes to the video? (resolution,FPS,rotation) [y/n]" videofilterans
if [[ $videofilterans = y ]] ; then
videofilter="-vf"
read -p "Would you like to change the resolution? [y/n]" answer4
if [[ $answer4 = y ]] ; then
echo "How wide of a resolution would you like? Enter only the width resolution. 1920 for 1920x1080 etc.. The video will be scaled. Both must be divisible by 2, ex 1920x1080, 1280x720 etc..." #Keeps the aspect ratio while scaling the clip.
read resolutionAnswer
resolution="scale=$resolutionAnswer:-1"
else
resolution=
fi
read -p "Would you like to change the frame rate? [y/n]" answer  #change frame rate
if [[ $answer = y ]] ; then
echo "What frame rate would you like?"
read FPSAnswer
FPS="-r $FPSAnswer"
else
FPS=
fi
echo "Does the video need to be rotated?  Any rotation metadata will be automatically applied, if so, select Do Not Rotate."  #option to rotate video
rotate=("Clockwise" "Counterclockwise" "Upside Down" "Do Not Rotate")
select rotateanswer in "${rotate[@]}"; do
case $rotateanswer in
"Clockwise")
transpose=,"transpose=1"
break
;;
"Counterclockwise")
transpose=,"transpose=2"
break
;;
"Upside Down")
transpose=,"transpose=2,transpose=2"
break
;;
"Do Not Rotate")
transpose=
break
;;
esac
done
else
videofilter=
fi
echo "What platform is the clip for?" #select platform type
targetsize=("4MB 4chan" "6MB 4chan w/Sound" "10MB Discord" "Twitter/X" "Custom")
select selectedsize in "${targetsize[@]}"; do
case $selectedsize in
"4MB 4chan")
audio="-an"
size="4"
service=_4chan
echo "What codec would you like to use?" #select desired codec
codectype=("VP8 - Low Quality, Fast Encode" "VP9 8bit - High Quality, Slow Encode" "VP9 10bit - High Quality, Slow Encode (source must be 10 bit to make any difference)" "AVC MP4 High Quality")
select selectedcodec in "${codectype[@]}"; do
case $selectedcodec in
"VP8 - Low Quality, Fast Encode")
codec="libvpx -movflags +faststart"
extension=webm
break
;;
"VP9 8bit - High Quality, Slow Encode")
codec="libvpx-vp9 -pix_fmt yuv420p -movflags +faststart"
extension=webm
break
;;
"VP9 10bit - High Quality, Slow Encode (source must be 10 bit to make any difference)")
codec="libvpx-vp9 -pix_fmt yuv420p10le -movflags +faststart"
extension=webm
break
;;
"AVC MP4 High Quality")
codec="libx264 -crf 20 -preset slow -pix_fmt yuv420p -movflags +faststart"
extension=mp4
break
;;
esac
done
break
;;
"6MB 4chan w/Sound")
service=_4chan_wsg
echo "What codec would you like to use?" #select desired codec
codectype=("VP8 - Low Quality, Fast Encode" "VP9 8bit - High Quality, Slow Encode" "VP9 10bit - High Quality, Slow Encode (source must be 10 bit to make any difference)" "AVC MP4 High Quality")
select selectedcodec in "${codectype[@]}"; do
case $selectedcodec in
"VP8 - Low Quality, Fast Encode")
codec="libvpx -movflags +faststart"
extension=webm
echo "What audio quality would you like? 1-10 with 10 being highest."
read qualityanswer
audio="-acodec libvorbis -aq $qualityanswer"
if [ $qualityanswer -ge 5 ] ; then
size="4.5"
else
size="5"
fi
break
;;
"VP9 8bit - High Quality, Slow Encode")
codec="libvpx-vp9 -pix_fmt yuv420p -movflags +faststart"
extension=webm
echo "What audio quality would you like? 1-10 with 10 being highest."
read qualityanswer
audio="-acodec libvorbis -aq $qualityanswer"
if [ $qualityanswer -ge 5 ] ; then
size="4.5"
else
size="5"
fi
break
;;
"VP9 10bit - High Quality, Slow Encode (source must be 10 bit to make any difference)")
codec="libvpx-vp9 -pix_fmt yuv420p10le -movflags +faststart"
extension=webm
echo "What audio quality would you like? 1-10 with 10 being highest."
read qualityanswer
audio="-acodec libvorbis -aq $qualityanswer"
if [ $qualityanswer -ge 5 ] ; then
size="4.5"
else
size="5"
fi
break
;;
"AVC MP4 High Quality")
codec="libx264 -crf 20 -preset slow -pix_fmt yuv420p -movflags +faststart"
extension=mp4
echo "What audio quality would you like? 0.1-2 with 2 being highest."
read qualityanswer
audio="-c:a aac -q:a $qualityanswer"
if [ $qualityanswer -ge 2 ] ; then
size="4.5"
else
size="5"
fi
break
;;
esac
done
break
;;
"10MB Discord")
service=_discord
echo "What codec would you like to use?" #select desired codec
codectype=("VP8 - Low Quality, Fast Encode" "VP9 8bit - High Quality, Slow Encode" "VP9 10bit - High Quality, Slow Encode (source must be 10 bit to make any difference)" "AVC MP4 High Quality")
select selectedcodec in "${codectype[@]}"; do
case $selectedcodec in
"VP8 - Low Quality, Fast Encode")
codec="libvpx -movflags +faststart"
extension=webm
echo "Should this clip contain audio? Y/N (Audio increases filesize significantly)"
read answer2
if [ $answer2 = y ] ; then
echo "What audio quality would you like? 1-10 with 10 being highest."
read qualityanswer
audio="-acodec libvorbis -aq $qualityanswer"
if [ $qualityanswer -ge 5 ] ; then
size="8"
else
size="9"
fi
else
audio="-an"
size="10"
fi
break
;;
"VP9 8bit - High Quality, Slow Encode")
codec="libvpx-vp9 -pix_fmt yuv420p -movflags +faststart"
extension=webm
echo "Should this clip contain audio? Y/N (Audio increases filesize significantly)"
read answer2
if [ $answer2 = y ] ; then
echo "What audio quality would you like? 1-10 with 10 being highest."
read qualityanswer
audio="-acodec libvorbis -aq $qualityanswer"
if [ $qualityanswer -ge 5 ] ; then
size="8"
else
size="9"
fi
else
audio="-an"
size="10"
fi
break
;;
"VP9 10bit - High Quality, Slow Encode (source must be 10 bit to make any difference)")
codec="libvpx-vp9 -pix_fmt yuv420p10le -movflags +faststart"
extension=webm
echo "Should this clip contain audio? Y/N (Audio increases filesize significantly)"
read answer2
if [ $answer2 = y ] ; then
echo "What audio quality would you like? 1-10 with 10 being highest."
read qualityanswer
audio="-acodec libvorbis -aq $qualityanswer"
if [ $qualityanswer -ge 5 ] ; then
size="8"
else
size="9"
fi
else
audio="-an"
size="10"
fi
break
;;
"AVC MP4 High Quality")
codec="libx264 -crf 20 -preset slow -pix_fmt yuv420p -movflags +faststart"
extension=mp4
echo "Should this clip contain audio? Y/N (Audio increases filesize significantly)"
read answer2
if [ $answer2 = y ] ; then
echo "What audio quality would you like? 0.1-2 with 2 being highest."
read qualityanswer
audio="-c:a aac -q:a $qualityanswer"
if [ $qualityanswer -ge 2 ] ; then
size="8"
else
size="9"
fi
else
audio="-an"
size="10"
fi
break
;;
esac
done
break
;;
"Twitter/X")
service=_twitterX
echo "Specify the file size would you like to target in MB, the Twitter limit is 512MB:"
read target
echo "Should this clip contain audio? Y/N (Audio increases filesize significantly)"
read answer2
if [ $answer2 = y ] ; then
echo "What audio quality would you like? 0.1-2 with 2 being highest."
read qualityanswer
audio="-c:a aac -q:a $qualityanswer"
if [ $qualityanswer -ge 2 ] ; then
size="(($target-1))"
else
size="$target"
fi
else
audio="-an"
size="$target"
fi
extension=mp4
codec="libx264 -crf 20 -preset slow -pix_fmt yuv420p -movflags +faststart"
break
;;
"Custom")
echo "Specify the file size would you like to target in MB:"
read target
echo "What codec would you like to use?" #select desired codec
codectype=("VP8 - Low Quality, Fast Encode" "VP9 8bit - High Quality, Slow Encode" "VP9 10bit - High Quality, Slow Encode (source must be 10 bit to make any difference)" "AVC MP4 High Quality")
select selectedcodec in "${codectype[@]}"; do
case $selectedcodec in
"VP8 - Low Quality, Fast Encode")
codec=libvpx
echo "Should this clip contain audio? Y/N (Audio increases filesize significantly)"
read answer2
if [ $answer2 = y ] ; then
echo "What audio quality would you like? 1-10 with 10 being highest."
read qualityanswer
audio="-acodec libvorbis -aq $qualityanswer"
if [ $qualityanswer -ge 5 ] ; then
size="(($target-1))"
else
size="$target"
fi
else
audio="-an"
size="$target"
fi
break
;;
"VP9 8bit - High Quality, Slow Encode")
codec="libvpx-vp9 -pix_fmt yuv420p"
echo "Should this clip contain audio? Y/N (Audio increases filesize significantly)"
read answer2
if [ $answer2 = y ] ; then
echo "What audio quality would you like? 1-10 with 10 being highest."
read qualityanswer
audio="-acodec libvorbis -aq $qualityanswer"
if [ $qualityanswer -ge 5 ] ; then
size="(($target-1))"
else
size="$target"
fi
else
audio="-an"
size="$target"
fi
break
;;
"VP9 10bit - High Quality, Slow Encode (source must be 10 bit to make any difference)")
codec="libvpx-vp9 -pix_fmt yuv420p10le"
echo "Should this clip contain audio? Y/N (Audio increases filesize significantly)"
read answer2
if [ $answer2 = y ] ; then
echo "What audio quality would you like? 1-10 with 10 being highest."
read qualityanswer
audio="-acodec libvorbis -aq $qualityanswer"
if [ $qualityanswer -ge 5 ] ; then
size="(($target-1))"
else
size="$target"
fi
else
audio="-an"
size="$target"
fi
break
;;
"AVC MP4 High Quality")
codec="libx264 -crf 20 -preset slow -pix_fmt yuv420p -movflags +faststart"
echo "Should this clip contain audio? Y/N (Audio increases filesize significantly)"
read answer2
if [ $answer2 = y ] ; then
echo "What audio quality would you like? 0.1-2 with 2 being highest."
read qualityanswer
audio="-c:a aac -q:a $qualityanswer"
if [ $qualityanswer -ge 2 ] ; then
size="(($target-1))"
else
size="$target"
fi
else
audio="-an"
size="$target"
fi
break
;;
esac
done
echo "What file extension should be used?"
extentionselect=("MP4" "WebM" "MKV")
select selectedextension in "${extentionselect[@]}"; do
case $selectedextension in
"MP4")
extension=mp4
break
;;
"WebM")
extension=webm
break
;;
"MKV")
extension=mkv
break
;;
esac
done
service=_custom
break
;;
esac
done
echo "What quality setting should be used for encodeing? The better quality, the slower the encode." #select encode quality
qualityselect=("Low(Realtime)" "Good" "Best")
select selectedquality in "${qualityselect[@]}"; do
case $selectedquality in
"Low(Realtime)")
quality=realtime
break
;;
"Good")
quality=good
break
;;
"Best")
quality=best
break
;;
esac
done
read -p "Does the file contain subs you would like to use? [y/n]" answer3  #Subs burn in start
if [[ $answer3 = y ]] ; then
mkvinfo $sourcefile  # View subs tracks
echo "What track number is the subs? Use the ID for mkvmerge & mkvextract."  # Select subs track
read tracknumber
mkvextract tracks $sourcefile $tracknumber:subs.srt #Extract the subs.srt from the MKV source file.
#flip -m subs.srt  #Still debating if this is needed.  Disabled since most people won't have it.
ffmpeg -i subs.srt subs.ass #Convert the extracted subs.srt to subs.ass.
rm subs.srt  #Delete the subs.srt file.
subs=,"ass=subs.ass"
else
subs=
fi
echo "What would you like to call the file? Leave off file extension." # desired file name
read outputfile
echo "Please wait, depending on length and resolution this can take a while."
if [ $time -ge 240 ] ; then #Adjust time multiplier 4 Minute+
adjust="0.5"
else
if [ $time -ge 180 ] ; then #Adjust time multiplier 3 Minute
adjust="0.6"
else
if [ $time -ge 120 ] ; then #Adjust time multiplier 2 Minute
adjust="0.7"
else
if [ $time -ge 60 ] ; then #Adjust time multiplier 1 Minute
adjust="0.8"
else
adjust="0.9"
fi
fi
fi
fi
core=$(nproc) # Obtain thread count.
ffmpeg -loglevel info -y -i "$sourcefile" -ss $starttime -to $endtime $audio -c:v $codec -quality $quality $videofilter $resolution$subs$transpose $FPS -sn -b:v $size*1024*1024*8/$time*$adjust -thread_type frame -auto-alt-ref 1 -lag-in-frames 25 -tile-columns 2 -row-mt 1 -speed 6 -threads $core -pass 1 -f $extension /dev/null #first pass
ffmpeg -loglevel info -i "$sourcefile" -ss $starttime -to $endtime $audio -c:v $codec -quality $quality $videofilter $resolution$subs$transpose $FPS -sn -b:v $size*1024*1024*8/$time*$adjust -thread_type frame -auto-alt-ref 1 -lag-in-frames 25 -tile-columns 2 -row-mt 1 -speed 0 -threads $core -pass 2 temp.$extension #encode pass
ffmpeg -i temp.$extension -map 0 -map_metadata -1 -c copy "$outputfile$service.$extension" #strip metadata
rm temp.$extension #Delete the temp video file.
rm ffmpeg2pass-0.* #Deleting the log file.
rm -rf subs.ass #Delete subs file.
rm -rf fontconfig #Delete fontconfig folder.
file="$outputfile$service.$extension"
if [ -f $file ]; then
filesize=$(stat -c%s "$outputfile$service.$extension")
echo "The file is called $outputfile$service.$extension is $filesize bytes and is located in $(pwd)." # notification in terminal
else
echo "Something has gone wrong, please try again."
fi
do
echo Would you like to do another? [y/n]  #Loop to start to make another one or end script.
read x
if [[ $x == 'y' ]] ; then
echo "Okay, we can keep going."
else
exit
fi
done
