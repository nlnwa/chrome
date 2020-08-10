#!/bin/bash
set -e

# When docker restarts, this file is still there,
# so we need to kill it just in case
[ -f /tmp/.X99-lock ] && rm /tmp/.X99-lock

_kill_procs() {
  kill -TERM $node
  kill -TERM $xvfb
}

# Relay quit commands to processes
trap _kill_procs SIGTERM SIGINT

Xvfb :99 -screen 0 1920x1200x16 &
xvfb=$!

export DISPLAY=:99

x11vnc -forever -nopw -localhost &
x11vnc=$!

dumb-init -- node ./build/index.js $@ &
node=$!

wait $node
wait $xvfb
wait $x11vnc
