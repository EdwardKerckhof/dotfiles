#!/bin/bash
running=$(pidof spotify)
if [ "$running" != "" ]; then
    artist=$(playerctl --player=spotify,chromium,vlc metadata artist)
    song=$(playerctl --player=spotify,chromium,vlc metadata title | cut -c 1-60)
    echo -n "$artist · $song"
fi
