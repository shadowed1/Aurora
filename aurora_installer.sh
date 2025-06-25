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
echo "${RESET}${CYAN}Run apps and games on Borealis using Flatpak with signficantly higher performance than Crostini!${RESET}${MAGENTA}"
echo "${RESET}"
echo "${BLUE}0: Quit${RESET}"
echo "${MAGENTA}1: Download and install Aurora + Flatpak to ~/ and ~/opt${RESET}"
echo ""
read -rp "Enter (0-1): " choice
export PATH="$HOME/opt/flatpak/usr/bin:$HOME/opt/flatpak-deps/usr/bin:$HOME:$PATH"
export LD_LIBRARY_PATH="$HOME/opt/flatpak-deps/usr/lib:$LD_LIBRARY_PATH"
export PATH="/bin:/usr/bin:$PATH"


case "$choice" in
    0)
        echo "Quit"
        ;;
    1)
echo ""
echo "${CYAN}Downloading Flatpak and its dependencies!${RESET}"
sleep 3
 mkdir -p ~/opt/flatpak
 mkdir -p ~/opt/flatpak-deps
 mkdir -p ~/opt/bin

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
    LD_LIBRARY_PATH="$HOME/opt/flatpak-deps/usr/lib" ~/opt/flatpak/usr/bin/flatpak --version
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

if ! grep -q 'flatpak.env' ~/.bashrc; then
  echo '[ -f "$HOME/opt/flatpak.env" ] && . "$HOME/opt/flatpak.env"' >> ~/.bashrc
fi

curl -L https://raw.githubusercontent.com/shadowed1/Aurora/main/.bashrc -o ~/.bashrc
curl -L https://raw.githubusercontent.com/shadowed1/Aurora/main/aurora -o ~/opt/bin/aurora
curl -L https://raw.githubusercontent.com/shadowed1/Aurora/main/flatpak.env -o ~/opt/flatpak.env
chmod +x ~/opt/bin/aurora
chmod 644 ~/.bashrc


echo "${MAGENTA}"
echo "╔═══════════════════════════════════════════════════════════════════════════════════════════════╗"
echo "║${RESET}${BOLD}${MAGENTA}                                       INSTALL COMPLETE!${RESET}${MAGENTA}                                       ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════════════════════╝"
echo "${RESET}"
echo ""
export PATH="$HOME/opt/flatpak/usr/bin:$HOME/opt/flatpak-deps/usr/bin:$HOME:$PATH"
export LD_LIBRARY_PATH="$HOME/opt/flatpak-deps/usr/lib:$LD_LIBRARY_PATH"
export PATH="\$HOME/opt/flatpak/usr/bin:\$HOME/opt/flatpak-deps/usr/bin:\$PATH"
export LD_LIBRARY_PATH="\$HOME/opt/flatpak-deps/usr/lib:\$LD_LIBRARY_PATH"
export PATH="/bin:$PATH"
"$HOME/opt/flatpak/usr/bin/flatpak" --version
sleep 3
/bin/bash ~/opt/bin/aurora help


        ;;
    *)
        echo "${RED}Invalid option.$RESET"
        exit 1
        ;;
esac
exit 0
