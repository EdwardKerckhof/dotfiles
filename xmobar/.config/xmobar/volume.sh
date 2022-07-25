#!/bin/bash

muted=$(amixer get Master | grep -o 'off' | head -n1)

if [[ $muted == "off" ]]; then
  echo 'muted'
else
  awk -F"[][]" '/Left:/ { print $2 }' <(amixer sget Master)
fi
