A script to encode videos for a few difference services, 4chan no sound clips, 4chan/wsg/ clips, discord clips, twitter/x clips, and a custom selection where file size and extension can be defined.


The services for specific sites offers only codecs supported by those sites.  For the custom option you have VP8, VP9, x264, and AV1.  


The script calculates the total length in seconds and based on options and service chosen to target a specific file size.  The script does not enforce any video length since I didn't feel like figureing that out.


FFmpeg is required and mkvtoolnix if you want to burn in subs.


The script defaults to your home directory Videos folder (~/Videos) where it will look for your video file to clip as well as where it will work on all files.  You can change this at line 5.


You can tab the file name at file selection prompt or paste your own in.  Be sure to encapulate any spaces like "file name.mkv" or it won't be passed to ffmpeg correctly.


If you make a mistake, just break out of the script with CTRL+C and start again.  I haven't done any kind of entry validation because I didn't want to bother.
