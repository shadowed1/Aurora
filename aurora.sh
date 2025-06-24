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
        
echo "${BLUE}Downloading Flatpak: https://archlinux.org/packages/extra/x86_64/flatpak/download${RESET}"   
sleep 1
              mkdir -p ~/opt/flatpak
              mkdir -p ~/opt/flatpak-deps
              URL="https://archlinux.org/packages/extra/x86_64/flatpak/download/"
              wget --content-disposition --trust-server-names "$URL"
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
              unzstd "$FILE"
              TAR_FILE="${FILE%.zst}"
              tar --use-compress-program=unzstd -xvf $TAR_FILE -C ~/opt/flatpak
              rm $FILE
              rm $TAR_FILE
        
echo "${MAGENTA} ${FILE} extracted to ~/opt/ and ~/opt/flatpak-deps created.${RESET}"
echo ""
sleep 1         
echo "${BLUE}Downloading ostree: https://archlinux.org/packages/extra/x86_64/ostree/download${RESET}"

              URL="https://archlinux.org/packages/extra/x86_64/ostree/download"
               wget --content-disposition --trust-server-names "$URL"
              if [[ -f "download" ]]; then
                FILE="download"
              else
                FILE=$(ls -t *.pkg.tar.zst 2>/dev/null | head -n 1)
              fi
              echo "Downloaded file: $FILE"
              SAFE_FILE="${FILE//:/}"
              if [[ "$FILE" != "$SAFE_FILE" ]]; then
                mv "$FILE" "$SAFE_FILE"
                FILE="$SAFE_FILE"
              fi
              unzstd "$FILE"
              TAR_FILE="${FILE%.zst}"
              tar --use-compress-program=unzstd -xvf $TAR_FILE -C ~/opt/flatpak-deps
              rm $FILE
              rm $TAR_FILE

echo "${MAGENTA} ${FILE} extracted. ${RESET}"
export LD_LIBRARY_PATH="$HOME/opt/flatpak-deps/usr/lib:$LD_LIBRARY_PATH"
sleep 1  
echo ""
echo "${BLUE}Downloading libxml2: https://archlinux.org/packages/core/x86_64/libxml2/download${RESET}"

              URL="https://archlinux.org/packages/core/x86_64/libxml2/download"
               wget --content-disposition --trust-server-names "$URL"
              if [[ -f "download" ]]; then
                FILE="download"
              else
                FILE=$(ls -t *.pkg.tar.zst 2>/dev/null | head -n 1)
              fi
              echo "Downloaded file: $FILE"
              SAFE_FILE="${FILE//:/}"
              if [[ "$FILE" != "$SAFE_FILE" ]]; then
                mv "$FILE" "$SAFE_FILE"
                FILE="$SAFE_FILE"
              fi
              unzstd "$FILE"
              TAR_FILE="${FILE%.zst}"
              tar --use-compress-program=unzstd -xvf $TAR_FILE -C ~/opt/flatpak-deps
              rm $FILE
              rm $TAR_FILE
          
echo "${MAGENTA} ${FILE} extracted.${RESET}"
export LD_LIBRARY_PATH="$HOME/opt/flatpak-deps/usr/lib:$LD_LIBRARY_PATH"       
sleep 1
echo ""
echo "${BLUE}Downloading libmalcontent: https://archlinux.org/packages/extra/x86_64/libmalcontent/download/${RESET}"

              URL="https://archlinux.org/packages/extra/x86_64/libmalcontent/download/"
               wget --content-disposition --trust-server-names "$URL"
              if [[ -f "download" ]]; then
                FILE="download"
              else
                FILE=$(ls -t *.pkg.tar.zst 2>/dev/null | head -n 1)
              fi
              echo "Downloaded file: $FILE"
              SAFE_FILE="${FILE//:/}"
              if [[ "$FILE" != "$SAFE_FILE" ]]; then
                mv "$FILE" "$SAFE_FILE"
                FILE="$SAFE_FILE"
              fi
              unzstd "$FILE"
              TAR_FILE="${FILE%.zst}"
              tar --use-compress-program=unzstd -xvf $TAR_FILE -C ~/opt/flatpak-deps
              rm $FILE
              rm $TAR_FILE
          
echo "${MAGENTA} ${FILE} extracted.${RESET}"
export LD_LIBRARY_PATH="$HOME/opt/flatpak-deps/usr/lib:$LD_LIBRARY_PATH"       
sleep 1
echo ""
echo "${BLUE}Downloading libmalcontent: https://archlinux.org/packages/core/x86_64/gpgme/download${RESET}"

              URL="https://archlinux.org/packages/core/x86_64/gpgme/download"
               wget --content-disposition --trust-server-names "$URL"
              if [[ -f "download" ]]; then
                FILE="download"
              else
                FILE=$(ls -t *.pkg.tar.zst 2>/dev/null | head -n 1)
              fi
              echo "Downloaded file: $FILE"
              SAFE_FILE="${FILE//:/}"
              if [[ "$FILE" != "$SAFE_FILE" ]]; then
                mv "$FILE" "$SAFE_FILE"
                FILE="$SAFE_FILE"
              fi
              unzstd "$FILE"
              TAR_FILE="${FILE%.zst}"
              tar --use-compress-program=unzstd -xvf $TAR_FILE -C ~/opt/flatpak-deps
              rm $FILE
              rm $TAR_FILE
          
echo "${MAGENTA} ${FILE} extracted.${RESET}"
export LD_LIBRARY_PATH="$HOME/opt/flatpak-deps/usr/lib:$LD_LIBRARY_PATH"       
sleep 1
        ;;
exit 0
        ;;
    *)
        echo "${RED}Invalid option.$RESET"
        exit 1
        ;;
esac
