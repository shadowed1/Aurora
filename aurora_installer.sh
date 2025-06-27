#!/bin/bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)
echo "${MAGENTA}${BOLD}"
echo ""
echo "   ------    ----    ---- -----------    --------   -----------     ------${RESET}"    
echo "${MAGENTA}${BOLD}  ********   ****    **** ***********   **********  ***********    ********${RESET}"   
echo "${MAGENTA} ----------  ----    ---- ----    ---  ----    ---- ----    ---   ----------${RESET}" 
echo "${MAGENTA}****    **** ****    **** *********    ***      *** *********    ****    ****${RESET}" 
echo "${BLUE}------------ ----    ---- ---------    ---      --- ---------    ------------${RESET}" 
echo "${BLUE}************ ************ ****  ****   ****    **** ****  ****   ************${RESET}" 
echo "${CYAN}----    ---- ------------ ----   ----   ----------  ----   ----  ----    ----${RESET}" 
echo "${CYAN}${BOLD}****    **** ************ ****    ****   ********   ****    **** ****    ****${RESET}"
echo ""
echo "${RESET}${CYAN}Run apps and games in Borealis using Flatpak for signficantly higher performance than Crostini!${RESET}"
echo "${RESET}"
echo "${BLUE}0: Quit${RESET}"
echo "${MAGENTA}1: Download and install Aurora + Flatpak to ~/ and ~/opt${RESET}"
echo ""
if [ ! -d "$HOME/.local/share/Steam" ]; then
  echo "${RED}Aurora needs Borealis.${RESET}"
  echo "${CYAN}Open Steam -> ${RESET}${BLUE}Open Crosh (ctrl-alt-t) -> ${RESET}${MAGENTA}vsh borealis${RESET}"
  echo ""
  exit 1
fi
read -rp "Enter (0-1): " choice


case "$choice" in
    0)
        echo "Quit"
        ;;
    1)
echo ""
echo "${CYAN}${BOLD}About to start downloading Flatpak and its dependencies!${RESET}"
sleep 3

 mkdir -p ~/opt/flatpak
 mkdir -p ~/opt/flatpak-deps
 mkdir -p ~/opt/bin
 
export XDG_RUNTIME_DIR="$HOME/.xdg-runtime-dir"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

export PATH="$HOME/opt/flatpak/usr/bin:$HOME/opt/flatpak-deps/usr/bin:/bin:/usr/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/opt/flatpak-deps/usr/lib:$LD_LIBRARY_PATH"

if [ ! -S "$XDG_RUNTIME_DIR/dbus-session" ]; then
  dbus-daemon --session \
    --address="unix:path=$XDG_RUNTIME_DIR/dbus-session" \
    --print-address=1 \
    --nopidfile \
    --nofork > "$XDG_RUNTIME_DIR/dbus-session.address" &
  sleep 1
fi
export DBUS_SESSION_BUS_ADDRESS=$(cat "$XDG_RUNTIME_DIR/dbus-session.address")

mkdir -p "$XDG_RUNTIME_DIR/doc/portal"
echo 3 > "$XDG_RUNTIME_DIR/doc/portal/version"

download_and_extract()
{
    local url="$1"
    local target_dir="$2"
    local FILE SAFE_FILE
    echo "${MAGENTA}"
    echo "Downloading: $url"
    wget --content-disposition --trust-server-names "$url"
    echo "${RESET}${BLUE}"
    
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
    echo "${RESET}${CYAN}${FILE} extracted.${RESET}"
    export LD_LIBRARY_PATH="$target_dir/usr/lib:$LD_LIBRARY_PATH"
    export FLATPAK_USER_DIR="$HOME/.local/share/flatpak"
   # sleep 1
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

URL="https://archlinux.org/packages/extra/x86_64/xdg-desktop-portal/download"
download_and_extract "$URL" "$HOME/opt/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/xdg-desktop-portal-gtk/download"
download_and_extract "$URL" "$HOME/opt/flatpak-deps"

# Futile attempt 
URL="https://archlinux.org/packages/extra/x86_64/fuse3/download"
download_and_extract "$URL" "$HOME/opt/flatpak-deps"

curl -L https://raw.githubusercontent.com/shadowed1/Aurora/main/flatpak.logic -o ~/opt/flatpak.logic
curl -L https://raw.githubusercontent.com/shadowed1/Aurora/main/aurora -o ~/opt/bin/aurora
curl -L https://raw.githubusercontent.com/shadowed1/Aurora/main/flatpak.env -o ~/opt/flatpak.env
chmod +x ~/opt/bin/aurora


export LD_LIBRARY_PATH="$HOME/opt/flatpak-deps/usr/lib:$LD_LIBRARY_PATH"

if file "$XDG_RUNTIME_DIR/dbus-session" | grep -q socket; then
  export DBUS_SESSION_BUS_ADDRESS=$(grep -E '^unix:' "$XDG_RUNTIME_DIR/dbus-session.address")
  grep -v '^export DBUS_SESSION_BUS_ADDRESS=' "$HOME/opt/flatpak.env" > "$HOME/opt/flatpak.env.tmp"
  echo "export DBUS_SESSION_BUS_ADDRESS=\"$DBUS_SESSION_BUS_ADDRESS\"" >> "$HOME/opt/flatpak.env.tmp"
  mv "$HOME/opt/flatpak.env.tmp" "$HOME/opt/flatpak.env"
else
  echo "D-Bus socket not found."
fi

if [ ! -f "$HOME/.bashrc" ]; then
  touch "$HOME/.bashrc"
fi
if ! grep -q 'flatpak.env' "$HOME/.bashrc"; then
  echo '[ -f "$HOME/opt/flatpak.env" ] && . "$HOME/opt/flatpak.env"' >> "$HOME/.bashrc"
fi


if [ ! -f "$HOME/opt/flatpak-deps/usr/lib/libostree-1.so.1" ]; then
  echo "libostree-1.so.1 missing from deps!"
  exit 1
fi

if ! grep -Fxq '[ -f "$HOME/opt/flatpak.logic" ] && . "$HOME/opt/flatpak.logic"' "$HOME/.bashrc"; then
  echo '[ -f "$HOME/opt/flatpak.logic" ] && . "$HOME/opt/flatpak.logic"' >> "$HOME/.bashrc"
fi

"$HOME/opt/flatpak/usr/bin/flatpak" --version
sleep 3

/bin/bash ~/opt/bin/aurora help

sleep 3
echo "${MAGENTA}"
echo "╔═══════════════════════════════════════════════════════════════════════════════════════════════╗"
echo "║                                       ${RESET}${BOLD}${MAGENTA}DOWNLOAD COMPLETE!${RESET}${MAGENTA}                                      ║"
echo "║           Open a new Crosh tab and run ${RESET}${BOLD}${MAGENTA}vsh borealis${RESET}${MAGENTA} to continue setting up Flatpak            ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════════════════════╝"
echo "${RESET}"
echo ""

${RESET}${BOLD}${MAGENTA} ${RESET}${MAGENTA}

        ;;
    *)
        echo "${RED}Invalid option.$RESET"
        exit 1
        ;;
esac
exit 0
