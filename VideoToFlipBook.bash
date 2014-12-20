#!/bin/bash

platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
    # ubuntu no longer has ffmpeg in the repo
    REQUIRED="avconv convert montage"
    SNAPSHOT_TOOL="avconv"
elif [[ "$unamestr" == 'Darwin' ]]; then
    # 'port' on mac osx only has ffmpeg
    REQUIRED="ffmpeg convert montage"
    SNAPSHOT_TOOL="ffmpeg"
else
    echo "Unsupported plattform. Aborting."
    exit 1
fi

RESOLUTION=300

usage() {
    echo "
Create printable document to tinker a flipbook. Requires $REQUIRED.
DIN A4 is used as the paper format. Print resolution is set to $RESOLUTION dpi.

Usage: $0 [-h] FILE [-i <IN>] [-o <OUT>] [-f <FRAMERATE>]
    -h, --help    Show this help message and exit
    -i, --in      Time of the video to start with (defaults to 00:00:00 and can
                  be given in format \"hh:mm:ss\" or as seconds only)
    -t, --time    Duration of the video to convert (defaults to ten seconds)
    -f, --fps     Number of frames to capture per second (defaults to 5)
"
    exit 1
}

file_exits() {
	local f="$1"
	[[ -f "$f" ]] && return 0 || return 1
}

tools_exist() {
    for tool in $REQUIRED
    do
        command -v $tool >/dev/null 2>&1 || { echo >&2 "The tool \"$tool\" is required but it's not installed. Aborting."; return 1; }
    done
}

# Exit if no file name is given...
[[ $# -eq 0 ]] && usage

if [ "$1" == "-h" ] || [ "$1" == "--help" ];
then
    usage
# ...or if it is not a file...
elif ( ! file_exits "$1" )
then
    echo "File \"$1\" not found. Exiting."
    exit 1
fi

# ...or if tool are not installed.
if ( ! tools_exist )
then
    exit 1
fi

# define default variables 
IN="00:00:00"
TIME=10
FPS=5
VIDEO=$1
shift

# parse options
while [[ $# > 1 ]]
do
key="$1"
shift
case $key in
    -i|--in)
    IN="$1"
    shift
    ;;
    -t|--time)
    TIME="$1"
    shift
    ;;
    -f|--fps)
    FPS="$1"
    shift
    ;;
    -h|--help)
    usage
    shift
    ;;
    *)
    # unknown option
    usage
    ;;
esac
done

OUTPUT="$(basename $VIDEO)_snapshots"

# Create folder for intermediate pictures
echo Creating folder "$OUTPUT"
mkdir $OUTPUT

#
# Start taking snapshots
#

echo "Taking snapshots..."
$SNAPSHOT_TOOL -i $VIDEO -ss $IN -t $TIME -r $FPS ${OUTPUT}/snapshot_%04d.png

#
# Add 100% margin and file name on the left side 
# to allow binding and reassembling
#
FILES="$OUTPUT/*"
 
#
# Create gif preview
#
echo "Creating gif preview: $(basename $VIDEO)_flipbook.gif"
convert -resize 320x240 -delay 20 -loop 0 $FILES $(basename $VIDEO)_flipbook.gif

echo "Extending and annotating pictures..."
for file in $FILES
do
    mogrify -gravity east -extent 200x100% $file 
    mogrify -gravity west -annotate 90x90+10+0 '%f' -pointsize 16 $file
    
    # Enable on demand: create four copies of each picture.
    # The resulting pdf will have the same file four time
    # on each page. Bind and cut the book to get four flipbooks.
    #cp $file "$file"_d
    #cp $file "$file"_c
    #cp $file "$file"_b
    #mv $file "$file"_a
done

#
# Combine the annotated pictures (four pictures on a sheet of paper)
#
echo "Combining pictures to pages..."

# This call to montage should duplicate each file four times but it didn't 
# work for me. Therefore the pictures are copied as needed (see above).
#montage "$OUTPUT/*.*" -duplicate 4,0-`\ls $OUTPUT/*.png -afq | wc -l` -tile 1x4  -geometry +75+75 "$OUTPUT/montage_%d.png"

# This takes very long and uses huge amounts of ram!
montage "$OUTPUT/*.*" -tile 1x4  -geometry +75+75 "$OUTPUT/montage_%d.png"


# 'Print' the montages to a sheet of DIN A4 paper (resolution is hard coded here.
# see http://en.wikipedia.org/wiki/ISO_216#A.2C_B.2C_C_comparison for adaption
# to other formats)
echo "Printing pages to pdf..."
convert "$OUTPUT/montage_*.png" -resize 2480x3506 -units PixelsPerInch -density "$RESOLUTION"x"$RESOLUTION" $(basename $VIDEO)_flipbook.pdf


# cleanup behind us
echo "Deleting intermediate pictures..."
rm $FILES
rmdir "$OUTPUT"

