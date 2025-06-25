export PATH="/bin:$PATH"
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)
export PATH="/usr/bin:$PATH"
if [ -f "$HOME/opt/flatpak.env" ]; then
    . "$HOME/opt/flatpak.env"
fi
echo "${CYAN}Initalizing Flatpak!${RESET}${BLUE}"
export PATH="/bin:/usr/bin:$PATH"
echo 'export PATH="$HOME/opt/flatpak/usr/bin:$PATH"' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH="$HOME/opt/flatpak-deps/usr/lib:$LD_LIBRARY_PATH"' >> ~/.bashrc
export PATH="$HOME/opt/flatpak/usr/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/opt/flatpak-deps/usr/lib:$LD_LIBRARY_PATH"
export PATH="$HOME/opt/flatpak-deps/usr/bin:$PATH"
TMPDIR=$HOME/tmp 
export TMPDIR="$HOME/tmp"
export DISPLAY=:0
export XDG_RUNTIME_DIR="$HOME/.xdg-runtime-dir"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"
sleep 1

if [ ! -f "$XDG_RUNTIME_DIR/dbus-session.address" ]; then
  dbus-daemon --session \
    --address="unix:path=$XDG_RUNTIME_DIR/dbus-session" \
    --print-address=1 \
    --nopidfile \
    --nofork > "$XDG_RUNTIME_DIR/dbus-session.address" &
  sleep 1
fi

export DBUS_SESSION_BUS_ADDRESS=$(cat "$XDG_RUNTIME_DIR/dbus-session.address")
echo "$DBUS_SESSION_BUS_ADDRESS"
chmod 700 "$XDG_RUNTIME_DIR"
mkdir -p "$XDG_RUNTIME_DIR/doc"
mkdir -p "$XDG_RUNTIME_DIR/doc/portal"
chmod 700 "$XDG_RUNTIME_DIR/doc" "$XDG_RUNTIME_DIR/doc/portal"
echo 3 > "$XDG_RUNTIME_DIR/doc/portal/version"



chmod 700 "$XDG_RUNTIME_DIR/doc"
export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:/usr/local/share:/usr/share"
sleep 1
export GTK_USE_PORTAL=0
export FLATPAK_DISABLE_PORTAL=1
if ! dbus-send --session --dest=org.freedesktop.DBus --type=method_call \
     --print-reply /org/freedesktop/DBus org.freedesktop.DBus.ListNames > /dev/null 2>&1; then
    eval "$(dbus-launch --sh-syntax)"
    export DBUS_SESSION_BUS_ADDRESS
fi
sleep 1
mkdir -p ~/tmp
mkdir -p $HOME/tmp
TMPDIR=$HOME/tmp
export TMPDIR="$HOME/tmp"
chown -R $USER:$USER ~/.local/share/flatpak
chmod -R u+rw ~/.local/share/flatpak
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak --user update --appstream

if [ ! -f "$XDG_RUNTIME_DIR/dbus-session.address" ]; then
    mkdir -p "$XDG_RUNTIME_DIR"
    chmod 700 "$XDG_RUNTIME_DIR"
    dbus-daemon --session \
        --address="unix:path=$XDG_RUNTIME_DIR/dbus-session" \
        --print-address=1 \
        --nopidfile \
        --nofork > "$XDG_RUNTIME_DIR/dbus-session.address" &
    sleep 1
fi



export DBUS_SESSION_BUS_ADDRESS=$(cat "$XDG_RUNTIME_DIR/dbus-session.address")

flatpak() {
  command flatpak --user "$@"
}

echo "${RESET}${CYAN}Flatpak ready!${RESET}"

