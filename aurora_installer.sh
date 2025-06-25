#!/bin/bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)
echo "${MAGENTA}"
echo "   ------    ----    ---- -----------    --------   -----------     ------"    
echo "  ********   ****    **** ***********   **********  ***********    ********"   
echo " ----------  ----    ---- ----    ---  ----    ---- ----    ---   ----------" 
echo "****    **** ****    **** *********    ***      *** *********    ****    ****" 
echo "------------ ----    ---- ---------    ---      --- ---------    ------------" 
echo "************ ************ ****  ****   ****    **** ****  ****   ************" 
echo "----    ---- ------------ ----   ----   ----------  ----   ----  ----    ----" 
echo "****    **** ************ ****    ****   ********   ****    **** ****    ****"
echo "${RESET}${BOLD}${MAGENTA}Run apps on Borealis using Flatpak with signficantly more performance than Crostini!${RESET}${MAGENTA}"
echo "${RESET}"
echo "${BLUE}${BOLD}0: Quit$RESET"
echo "${MAGENTA}${BOLD}1: Download and install Flatpak to ~/opt${RESET}"

read -rp "Enter (0-1): " choice

export PATH="$HOME/opt/flatpak/usr/bin:$HOME/opt/flatpak-deps/usr/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/opt/flatpak-deps/usr/lib:$LD_LIBRARY_PATH"


case "$choice" in
    0)
        echo "Quit"
        ;;
    1)



 mkdir -p ~/opt/flatpak
 mkdir -p ~/opt/flatpak-deps

download_and_extract()
{
    local url="$1"
    local target_dir="$2"
    local FILE SAFE_FILE

    echo "${BLUE}Downloading: $url${RESET}"
    wget --content-disposition --trust-server-names "$url"
    
    if [[ -f "download" ]]; then
        FILE="download"
    else
        FILE=$(ls -t *.pkg.tar.zst 2>/dev/null | head -n 1)
    fi

    SAFE_FILE="${FILE//:/}"
    if [[ "$FILE" != "$SAFE_FILE" ]]; then
        mv "$FILE" "$SAFE_FILE"
        FILE="$SAFE_FILE"
    fi

    echo "Extracting $FILE to $target_dir"
    tar --use-compress-program=unzstd -xvf "$FILE" -C "$target_dir"
    rm -f "$FILE"

    echo "${MAGENTA}${FILE} extracted.${RESET}"
    export LD_LIBRARY_PATH="$target_dir/usr/lib:$LD_LIBRARY_PATH"
    export FLATPAK_USER_DIR="$HOME/.local/share/flatpak"
    LD_LIBRARY_PATH="$HOME/opt/flatpak-deps/usr/lib" ~/opt/flatpak/usr/bin/flatpak --version
    sleep 1
}

URL="https://archlinux.org/packages/extra/x86_64/flatpak/download"
download_and_extract "$URL" "$HOME/opt/flatpak"

URL="https://archlinux.org/packages/extra/x86_64/ostree/download"
download_and_extract "$URL" "$HOME/opt/flatpak-deps"

URL="https://archlinux.org/packages/core/x86_64/libxml2/download"
download_and_extract "$URL" "$HOME/opt/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/libmalcontent/download"
download_and_extract "$URL" "$HOME/opt/flatpak-deps"

URL="https://archlinux.org/packages/core/x86_64/gpgme/download"
download_and_extract "$URL" "$HOME/opt/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/libsodium/download"
download_and_extract "$URL" "$HOME/opt/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/composefs/download"
download_and_extract "$URL" "$HOME/opt/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/bubblewrap/download"
download_and_extract "$URL" "$HOME/opt/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/xdg-dbus-proxy/download"
download_and_extract "$URL" "$HOME/opt/flatpak-deps"

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
sleep 1
echo 3 > "$XDG_RUNTIME_DIR/doc/portal/version"
mkdir -p "$XDG_RUNTIME_DIR/doc/portal"
chmod 700 "$XDG_RUNTIME_DIR/doc" "$XDG_RUNTIME_DIR/doc/portal"
mkdir -p "$XDG_RUNTIME_DIR/doc"
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
###############################################
export PATH="$HOME/opt/flatpak/usr/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/opt/flatpak-deps/usr/lib:$LD_LIBRARY_PATH"
export PATH="$HOME/opt/flatpak-deps/usr/bin:$PATH"
TMPDIR=$HOME/tmp 
export TMPDIR="$HOME/tmp"
export DISPLAY=:0
export XDG_RUNTIME_DIR="$HOME/.xdg-runtime-dir"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"
echo "$DBUS_SESSION_BUS_ADDRESS"
###############################################
echo "${GREEN}Flatpak is ready to go!${RESET}"
curl -L https://raw.githubusercontent.com/shadowed1/Aurora/main/flatpak_wrapper.sh -o ~/opt/flatpak_wrapper.sh
chmod +x ~/opt/flatpak_wrapper.sh

echo "${MAGENTA}"
echo "╔═══════════════════════════════════════════════════════════════════════════════════════════════╗"
echo "║                                       INSTALL COMPLETE!                                       ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════════════════════╝"
echo "${RESET}"


        ;;
    *)
        echo "${RED}Invalid option.$RESET"
        exit 1
        ;;
esac
exit 0
