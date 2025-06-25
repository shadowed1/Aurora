RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)
if [ -f "$HOME/opt/flatpak.env" ]; then
    . "$HOME/opt/flatpak.env"
fi
echo "${MAGENTA}Aurora initalizing Flatpak!${RESET}${BLUE}"

TMPDIR=$HOME/tmp 

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
export DBUS_SESSION_BUS_ADDRESS=$(grep -E '^unix:' "$XDG_RUNTIME_DIR/dbus-session.address" | tr -d '\n')
echo "$DBUS_SESSION_BUS_ADDRESS"
chmod 700 "$XDG_RUNTIME_DIR"
mkdir -p "$XDG_RUNTIME_DIR/doc"
mkdir -p "$XDG_RUNTIME_DIR/doc/portal"
chmod 700 "$XDG_RUNTIME_DIR/doc" "$XDG_RUNTIME_DIR/doc/portal"
echo 3 > "$XDG_RUNTIME_DIR/doc/portal/version"
chmod 700 "$XDG_RUNTIME_DIR/doc"
sleep 1

if ! dbus-send --session --dest=org.freedesktop.DBus --type=method_call \
     --print-reply /org/freedesktop/DBus org.freedesktop.DBus.ListNames > /dev/null 2>&1; then
    eval "$(dbus-launch --sh-syntax)"
fi


sleep 1
mkdir -p ~/tmp
mkdir -p $HOME/tmp
TMPDIR=$HOME/tmp
chown -R $USER:$USER ~/.local/share/flatpak
chmod -R u+rw ~/.local/share/flatpak
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak --user update --appstream

flatpak() {
  case "$1" in
    --help|-h|help|""|--version)
      command flatpak "$@"
      ;;
    *)
      command flatpak --user "$@"
      ;;
  esac
}


echo "${RESET}${CYAN}Flatpak ready!${RESET}"

