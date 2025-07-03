#!/bin/bash
# Aurora Parallel Installer: Download and extract multiple files in parallel, safely

# Color setup (unchanged)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Logo and intro (unchanged)
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
echo "${RESET}${CYAN}Run apps and games in Borealis using Flatpak, AppImages, git, gcc, python, + automated .tar extraction for signficantly higher performance than Crostini!${RESET}"
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
echo "${CYAN}${BOLD}About to start downloading Flatpak, Git, GCC, Python and their dependencies!${RESET}"
sleep 3

mkdir -p ~/opt/flatpak ~/opt/flatpak-deps ~/opt/bin
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

download_and_extract() {
    local url="$1"
    local target_dir="$2"
    local tmpfile
    tmpfile=$(mktemp)
    echo "${MAGENTA}Downloading: $url${RESET}"
    wget --content-disposition --trust-server-names "$url" -O "$tmpfile"
    echo "${BLUE}Extracting to $target_dir${RESET}"
    mkdir -p "$target_dir"
    tar --use-compress-program=unzstd -xvf "$tmpfile" -C "$target_dir"
    rm -f "$tmpfile"
    echo "${CYAN}Extracted to $target_dir${RESET}"
}

files=(
"https://archlinux.org/packages/extra/x86_64/flatpak/download|$HOME/opt/flatpak"
"https://archlinux.org/packages/extra/x86_64/ostree/download|$HOME/opt/flatpak-deps"
"https://archlinux.org/packages/core/x86_64/libxml2/download|$HOME/opt/flatpak-deps"
"https://archlinux.org/packages/extra/x86_64/libmalcontent/download|$HOME/opt/flatpak-deps"
"https://archlinux.org/packages/core/x86_64/gpgme/download|$HOME/opt/flatpak-deps"
"https://archlinux.org/packages/extra/x86_64/libsodium/download|$HOME/opt/flatpak-deps"
"https://archlinux.org/packages/extra/x86_64/composefs/download|$HOME/opt/flatpak-deps"
"https://archlinux.org/packages/extra/x86_64/bubblewrap/download|$HOME/opt/flatpak-deps"
"https://archlinux.org/packages/extra/x86_64/xdg-dbus-proxy/download|$HOME/opt/flatpak-deps"
"https://archlinux.org/packages/extra/x86_64/xdg-desktop-portal/download|$HOME/opt/flatpak-deps"
"https://archlinux.org/packages/extra/x86_64/xdg-desktop-portal-gtk/download|$HOME/opt/flatpak-deps"
"https://archlinux.org/packages/extra/x86_64/fastfetch/download|$HOME/opt/"
"https://archlinux.org/packages/extra/x86_64/yyjson/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/nano/download|$HOME/opt/"
"https://archlinux.org/packages/extra/x86_64/git/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/expat/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/pcre2/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/openssl/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/perl/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/perl-error/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/perl-mailtools/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/shadow/download|$HOME/opt/"
"https://archlinux.org/packages/extra/x86_64/zlib-ng/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/libcurl-gnutls/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/zstd/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/lz4/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/leancrypto/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/libidn2/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/libp11-kit/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/libffi/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/glibc/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/tzdata/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/libtasn1/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/libunistring/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/nettle/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/gmp/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/zlib/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/gcc-libs/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/npm/download|$HOME/opt/"
"https://archlinux.org/packages/extra/x86_64/jq/download|$HOME/opt/"
"https://archlinux.org/packages/extra/x86_64/oniguruma/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/node-gyp/download|$HOME/opt/flatpak-deps"
"https://archlinux.org/packages/extra/any/semver/download|$HOME/opt/"
"https://archlinux.org/packages/extra/x86_64/nodejs/download|$HOME/opt/"
"https://archlinux.org/packages/extra/x86_64/oniguruma/download|$HOME/opt/"
"https://archlinux.org/packages/extra/x86_64/oniguruma/download|$HOME/opt/"
"https://archlinux.org/packages/extra/x86_64/oniguruma/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/gcc/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/binutils/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/jansson/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/libelf/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/json-c/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/brotli/download|$HOME/opt/"
"https://archlinux.org/packages/extra/x86_64/cmake/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/nlohmann-json/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/python/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-sphinx/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-babel/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/libxcrypt/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/mpdecimal/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-pytz/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-jaraco.collections/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-setuptools/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-jaraco.functools/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-jaraco.text/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-more-itertools/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-packaging/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-freezegun/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-pytest/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-docutils/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-imagesize/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-jinja/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-pygments/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-snowballstemmer/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-roman-numerals-py/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-sphinx-alabaster-theme/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-sphinxcontrib-htmlhelp/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-sphinxcontrib-jsmath/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-sphinxcontrib-qthelp/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-sphinxcontrib-serializinghtml/download|$HOME/opt/"
"https://archlinux.org/packages/extra/x86_64/cppdap/download|$HOME/opt/"
"https://archlinux.org/packages/extra/x86_64/jsoncpp/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/libarchive/download|$HOME/opt/"
"https://archlinux.org/packages/extra/x86_64/libuv/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/ncurses/download|$HOME/opt/"
"https://archlinux.org/packages/extra/x86_64/rhash/download|$HOME/opt/"
"https://archlinux.org/packages/extra/x86_64/emacs/download|$HOME/opt/"
"https://archlinux.org/packages/extra/x86_64/lcms2/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/gnutls/download|$HOME/opt/"
"https://archlinux.org/packages/extra/x86_64/qt6-base/download|$HOME/opt/"
"https://archlinux.org/packages/extra/x86_64/ninja/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/make/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/guile/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/gc/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-wheel/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-installer/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-build/download|$HOME/opt/"
"https://archlinux.org/packages/extra/x86_64/c-ares/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/icu/download|$HOME/opt/"
"https://archlinux.org/packages/extra/x86_64/libngtcp2/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/libnsl/download|$HOME/opt/"
"https://archlinux.org/packages/extra/x86_64/simdjson/download|$HOME/opt/"
"https://archlinux.org/packages/core/x86_64/procps-ng/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/nodejs-nopt/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-sphinxcontrib-applehelp/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/python-sphinxcontrib-devhelp/download|$HOME/opt/"
"https://archlinux.org/packages/extra/any/nvm/download|$HOME/opt/"
)

max_jobs=3
active_jobs=0

for entry in "${files[@]}"; do
    url="${entry%%|*}"
    target_dir="${entry##*|}"
    download_and_extract "$url" "$target_dir" &
    ((active_jobs++))
    # Limit number of parallel jobs
    if ((active_jobs >= max_jobs)); then
        wait -n
        ((active_jobs--))
    fi
done
wait
echo "${GREEN}All downloads and extractions complete!${RESET}"

curl -L https://raw.githubusercontent.com/shadowed1/Aurora/beta/.flatpak.logic -o ~/opt/.flatpak.logic
curl -L https://raw.githubusercontent.com/shadowed1/Aurora/beta/aurora -o ~/opt/bin/aurora
curl -L https://raw.githubusercontent.com/shadowed1/Aurora/beta/starman -o ~/opt/bin/starman
curl -L https://raw.githubusercontent.com/shadowed1/Aurora/beta/version -o ~/opt/bin/version
curl -L https://raw.githubusercontent.com/shadowed1/Aurora/beta/.flatpak.env -o ~/opt/.flatpak.env

chmod +x ~/opt/bin/aurora
chmod +x ~/opt/bin/starman
chmod +x ~/opt/usr/bin/fastfetch
chmod +x ~/opt/usr/bin/nano
touch /home/chronos/.starman_flatpak_cache
echo ""

export LD_LIBRARY_PATH="$HOME/opt/flatpak-deps/usr/lib:$LD_LIBRARY_PATH"

if file "$XDG_RUNTIME_DIR/dbus-session" | grep -q socket; then
  export DBUS_SESSION_BUS_ADDRESS=$(grep -E '^unix:' "$XDG_RUNTIME_DIR/dbus-session.address")
  grep -v '^export DBUS_SESSION_BUS_ADDRESS=' "$HOME/opt/.flatpak.env" > "$HOME/opt/.flatpak.env.tmp"
  echo "export DBUS_SESSION_BUS_ADDRESS=\"$DBUS_SESSION_BUS_ADDRESS\"" >> "$HOME/opt/.flatpak.env.tmp"
  mv "$HOME/opt/.flatpak.env.tmp" "$HOME/opt/.flatpak.env"
else
  echo "dbus socket not found."
fi

[ -f "$HOME/.bashrc" ] || touch "$HOME/.bashrc"
FLATPAK_ENV_LINE='[ -f "$HOME/opt/.flatpak.env" ] && . "$HOME/opt/.flatpak.env"'
FLATPAK_LOGIC_LINE='[ -f "$HOME/opt/.flatpak.logic" ] && . "$HOME/opt/.flatpak.logic"'
grep -Fxq "$FLATPAK_ENV_LINE" "$HOME/.bashrc" || echo "$FLATPAK_ENV_LINE" >> "$HOME/.bashrc"
grep -Fxq "$FLATPAK_LOGIC_LINE" "$HOME/.bashrc" || echo "$FLATPAK_LOGIC_LINE" >> "$HOME/.bashrc"

if [ ! -f "$HOME/opt/flatpak-deps/usr/lib/libostree-1.so.1" ]; then
  echo "libostree-1.so.1 missing from deps!"
  exit 1
fi

"$HOME/opt/flatpak/usr/bin/flatpak" --version
sleep 3

echo ""

/bin/bash ~/opt/bin/aurora help

sleep 3
echo "${RESET}${MAGENTA}"
echo "╔═══════════════════════════════════════════════════════════════════════════════════════════════╗"
echo "║                                       ${RESET}${BOLD}${MAGENTA}DOWNLOAD COMPLETE!${RESET}${MAGENTA}                                      ║"
echo "║           ${RESET}${BLUE}${BOLD}Open a new Crosh tab and run ${RESET}${BOLD}${CYAN}vsh borealis${RESET}${BLUE}${BOLD} to continue setting up Flatpak${RESET}${MAGENTA}            ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════════════════════╝"
echo "${RESET}"
echo ""

        ;;
    *)
        echo "${RED}Invalid option.$RESET"
        exit 1
        ;;
esac
exit 0
