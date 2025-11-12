#!/usr/bin/env bash
#
# Wrapper script for various media SaaS providers to retrieve arbitrary
# content & metadata for future playback.
#
# Configuration env vars:
#   - COOKIEFILE_PATH (default `~/.cache/cookies.txt`)
#     path to cookie export for authenticated downloads
#     @see Firefox plugin https://github.com/rotemdan/ExportCookies
#   - FETCH_MP3 (default `0`)-
#     if `1`, download mp3 instead of opus or m4a
#   - EXTRACT_YT_AUDIO (default `0`)-
#     if `1`, audio will be extracted from YouTube video, and video discarded
#   - IGNORE_DL_ERRORS (default `0`)-
#     if `1`, artist / playlist downloads will continue if a track fails
#
# @depends on `ffmpeg` & Python modules being available on $PATH:
#   - yt-dlp  (YouTube)
#   - scdl    (SoundCloud)
#   - gamdl   (Apple Music)
#   - spotdl  (Spotify)
# To install them all, use https://pipx.pypa.io/ as follows:
#   sudo apt install ffmpeg pipx   # (on Debian-based systems)
#   pipx install yt-dlp scdl gamdl spotdl
#
# @author pospi <pospi@spadgos.com>
# @since  2025-11-11
#

if [[ $# -ne 1 ]]; then
  echo "Please provide a media URL to download!"
  exit 1
fi

# read config from environment
COOKIEFILE="${COOKIEFILE_PATH:-$HOME/.cache/cookies.txt}"
DL_MP3S="${FETCH_MP3:-0}"
YT_AUDIOONLY="${EXTRACT_YT_AUDIO:-0}"
IGNORE_ERRORS="${IGNORE_DL_ERRORS:-0}"

# internal script status flags
skip_cleanup=1
progressfile=""

# ensure cache folder for download progress / resume files
mkdir -p $HOME/.cache

#
#------------------------- Spotify -------------------------
#
if [[ "$1" == *"spotify"* ]]; then

  progressfile="~/.cache/dl-progress-spotify.spotdl"

  args=( \
    '--restrict' 'ascii' \
    '--lyrics' 'genius' 'musixmatch' \
    '--save-file' "$progressfile" \
    '--log-level' 'INFO' \
  )
  (( "$DL_MP3S" == 0 )) && args+=( \
    '--audio' 'youtube-music' \
    '--cookie-file' "$COOKIEFILE"  \
    '--format' 'm4a' \
    '--bitrate' 'disable' \
  )
  (( "$DL_MP3S" == 1 )) && args+=( \
    '--audio' 'soundcloud' 'bandcamp' 'youtube' \
    '--format' 'mp3' \
    '--bitrate' 'auto' \
  )

  spotdl "$@" "${args[@]}"

  skip_cleanup=$?

#
#----------------------- SoundCloud ------------------------
#
elif [[ "$1" == *"soundcloud"* ]]; then

  progressfile="~/.cache/dl-progress-soundcloud.log"

  args=( \
    '--addtofile' \
    '--download-archive' "$progressfile" \
    '--yt-dlp-args' "--cookies \"${COOKIEFILE}\"" \
  )
  (( "$DL_MP3S" == 0 )) && args+=( '--opus' )
  (( "$IGNORE_ERRORS" == 0 )) && args+=( '--strict-playlist' )

  scdl -l "$@" "${args[@]}"

  # intentionally disabled: scdl cleans up after itself
  # skip_cleanup=$?

#
#------------------------- YouTube -------------------------
#
elif [[ "$1" == *"youtube"* ]]; then

  progressfile="~/.cache/dl-progress-youtube.log"

  args=( \
    '--restrict-filenames' \
    '--write-subs' '--write-auto-subs' \
    '--write-thumbnail' \
    '--write-description' \
    '--progress' '--progress-delta' '1' \
    '--cookies' "$COOKIEFILE" \
    '--write-info-json' '--write-comments' \
    '--download-archive' "$progressfile" \
  )
  # '--write-link' \
  (( "$YT_AUDIOONLY" == 1 && "$DL_MP3S" == 1 )) && args+=( '-x' '-t' 'mp3' )
  (( "$YT_AUDIOONLY" == 1 && "$DL_MP3S" == 0 )) && args+=( '-x' '-t' 'aac' )

  yt-dlp "${args[@]}" "$@"

  skip_cleanup=$?

#
#-------------------------- Apple --------------------------
#
elif [[ "$1" == *"apple"* ]]; then

  progressfile="~/.cache/dl-progress-apple.log"

  args=( \
    '--log-level' 'INFO' \
    '--cookies-path' "$COOKIEFILE" \
    '--synced-lyrics-format' 'srt' \
  )

  gamdl "${args[@]}" "$@"

  skip_cleanup=$?

#
#--------------------------- ??? ---------------------------
#
else

  echo "Unknown media service domain in URL '$1'. Skipping."
  exit 1

fi

# cleanup resume files
if [[ "$skip_cleanup" -eq 0 && -n "$progressfile" ]]; then
  rm "$progressfile"
fi
