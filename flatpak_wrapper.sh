#!/bin/bash
export PATH="$HOME/opt/flatpak/usr/bin:$HOME/opt/flatpak-deps/usr/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/opt/flatpak-deps/usr/lib:$LD_LIBRARY_PATH"
export DISPLAY=:0
export TMPDIR="$HOME/tmp"
export XDG_RUNTIME_DIR="$HOME/.xdg-runtime-dir"
export GTK_USE_PORTAL=0
export FLATPAK_DISABLE_PORTAL=1

mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

if [ ! -f "$XDG_RUNTIME_DIR/dbus-session.address" ]; then
  dbus-daemon --session \
    --address="unix:path=$XDG_RUNTIME_DIR/dbus-session" \
    --print-address=1 \
    --nopidfile \
    --nofork > "$XDG_RUNTIME_DIR/dbus-session.address" &
  sleep 1
fi

export DBUS_SESSION_BUS_ADDRESS=$(cat "$XDG_RUNTIME_DIR/dbus-session.address")
