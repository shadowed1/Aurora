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
echo "╔═══════════════════════════════════════════════════════════════════════════════════════════════╗"
echo "║                                          AURORA:                                              ║"
echo "║     Run apps on Borealis using Flatpak for signficantly more performance than Crostini!       ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════════════════════╝"
echo "${RESET}"
echo "${BLUE}0: Quit$RESET"
echo "${MAGENTA}1: Download and install Flatpak to ~/opt${RESET}"

read -rp "Enter (0-1): " choice

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

mkdir -p ~/tmp
mkdir -p $HOME/tmp
TMPDIR=$HOME/tmp
export TMPDIR="$HOME/tmp"
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak --user update --appstream
flatpak --user install flathub org.gnome.gedit
chown -R $USER:$USER ~/.local/share/flatpak
chmod -R u+rw ~/.local/share/flatpak
TMPDIR="$HOME/tmp" flatpak --user install flathub org.gnome.gedit

        ;;
exit 0
        ;;
    *)
        echo "${RED}Invalid option.$RESET"
        exit 1
        ;;
esac
