#!/usr/bin/env bash
#
# Recompress whatever vids into nicely compressed x264 MP4's with AAC sound.
#
# @author:  pospi <pospi@spadgos.com>
# @since:   2016-04-08
#
##

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 {videos}"
  echo "Converts any (glob-matched) video files to an efficient x264/AAC storage format."
  exit 1
fi

for vid in "$@"
do
  echo ""
  echo ""
  echo "--- CONVERTING ${vid} ---"
  echo ""

  video=$(basename "$vid" ".MOV")

  ffmpeg -i "$vid" -vcodec libx264 -acodec aac -crf 20 -pix_fmt yuv420p -preset slow "${video}.conv.mp4"

  SUCCESS=$?
  if [[ $SUCCESS -ne 0 ]]; then
    exit $SUCCESS
  fi

  touch -r "$vid" "${video}.conv.mp4"
done

# ffmpeg -i "$1" -c:v libx264 -crf 19 -preset slow -c:a libvo_aacenc -b:a 192k -ac 2 -pix_fmt yuv420p "$2"
# ffmpeg -i "$1" -vcodec libx264 -acodec libfdk_aac -crf 20 "$2"
# -c:v libvpx -c:a libvorbis (webM- https://trac.ffmpeg.org/wiki/Encode/VP8)

exit 0
