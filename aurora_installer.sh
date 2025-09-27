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
echo "${CYAN}${BOLD}About to start downloading Flatpak, Git, GCC, Python and their dependencies! Download can take up to 10 minutes.${RESET}"
sleep 5

mkdir -p ~/opt/flatpak
mkdir -p ~/opt/flatpak-deps
mkdir -p ~/opt/bin

sed -i '/\.flatpak\.env/d' "$HOME/.bashrc"
sed -i '/\.flatpak\.logic/d' "$HOME/.bashrc"

if grep -q "# Flatpak --user logic" "$HOME/.bashrc"; then
sed -i '/# Flatpak --user logic/,/^}/d' "$HOME/.bashrc"
echo "${CYAN}Removed Flatpak function from .bashrc${RESET}"
fi

export XDG_RUNTIME_DIR="$HOME/.xdg-runtime-dir"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

export PATH="$HOME/opt/flatpak/usr/bin:$HOME/opt/flatpak-deps/usr/bin:/bin:/usr/bin:$PATH"
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

echo "${MAGENTA}"
curl -L https://raw.githubusercontent.com/shadowed1/Aurora/main/.flatpak.logic -o ~/opt/.flatpak.logic
echo "${RESET}${BLUE}"
curl -L https://raw.githubusercontent.com/shadowed1/Aurora/main/aurora -o ~/opt/bin/aurora
echo "${RESET}${CYAN}"
curl -L https://raw.githubusercontent.com/shadowed1/Aurora/main/starman -o ~/opt/bin/starman
echo "${RESET}${BLUE}"
curl -L https://raw.githubusercontent.com/shadowed1/Aurora/main/version -o ~/opt/bin/version
echo "${RESET}${MAGENTA}"
curl -L https://raw.githubusercontent.com/shadowed1/Aurora/main/.flatpak.env -o ~/opt/.flatpak.env
echo "${RESET}"
chmod +x ~/opt/bin/aurora
chmod +x ~/opt/bin/starman

echo ""

download_flatpak() {
    local url="$1"
    local target="$HOME/opt/flatpak"
    local archive="$HOME/$(basename "$url")"

    mkdir -p "$target"
    echo "${RESET}${MAGENTA}"
    echo "Downloading $url ..."
    echo ""
    if command -v curl >/dev/null 2>&1; then
        curl -L --insecure -o "$archive" "$url" || true
    fi

    if [[ ! -s "$archive" ]]; then
        if command -v wget >/dev/null 2>&1; then
            wget --no-check-certificate -O "$archive" "$url"
        fi
    fi

    if [[ ! -s "$archive" ]]; then
        echo "${RESET}${RED}"
        echo "Error: Failed to download $url"
        echo "${RESET}"
        return 1
    fi
    echo "${RESET}${BLUE}"
    echo "Download complete: $archive"
    echo ""

    echo "${RESET}${CYAN}"
    echo "Extracting $archive to $target ..."
    echo ""
    tar --use-compress-program=unzstd -xvpf "$archive" -C "$target"

    rm -f "$archive"

    echo "${RESET}${MAGENTA}"
    echo "Setting permissions..."

    find "$target" -type d -name bin -exec chmod -R +x {} + 2>/dev/null
    find "$target" -type d -name lib -exec chmod -R 755 {} + 2>/dev/null
    find "$target" -type f ! -path "*/bin/*" ! -path "*/lib/*" -exec chmod 644 {} + 2>/dev/null

    echo "${RESET}${BLUE}"
    echo "Extraction and permissions set for $(basename "$archive")."
    echo "${RESET}"
    sleep 1
}

download_flatpak "https://archlinux.org/packages/extra/x86_64/flatpak/download"

sleep 1

download_flatpakdeps() {
    local url="$1"
    local target="$HOME/opt/flatpak-deps"
    local archive="$HOME/$(basename "$url")"

    mkdir -p "$target"
    echo "${RESET}${MAGENTA}"
    echo "Downloading $url ..."
    echo ""
    if command -v curl >/dev/null 2>&1; then
        curl -L --insecure -o "$archive" "$url" || true
    fi

    if [[ ! -s "$archive" ]]; then
        if command -v wget >/dev/null 2>&1; then
            wget --no-check-certificate -O "$archive" "$url"
        fi
    fi

    if [[ ! -s "$archive" ]]; then
        echo "${RESET}${RED}"
        echo "Error: Failed to download $url"
        echo "${RESET}"
        return 1
    fi
    echo "${RESET}${BLUE}"
    echo "Download complete: $archive"
    echo ""

    echo "${RESET}${CYAN}"
    echo "Extracting $archive to $target ..."
    echo ""
    tar --use-compress-program=unzstd -xvpf "$archive" -C "$target"

    rm -f "$archive"

    echo "${RESET}${MAGENTA}"
    echo "Setting permissions..."
    echo ""

    find "$target" -type d -name bin -exec chmod -R +x {} + 2>/dev/null
    find "$target" -type d -name lib -exec chmod -R 755 {} + 2>/dev/null
    find "$target" -type f ! -path "*/bin/*" ! -path "*/lib/*" -exec chmod 644 {} + 2>/dev/null

    echo "${RESET}${BLUE}"
    echo "Extraction and permissions set for $(basename "$archive")."
    echo ""
    sleep 1
}


download_flatpakdeps "https://archlinux.org/packages/extra/x86_64/ostree/download"
download_flatpakdeps "https://archlinux.org/packages/core/x86_64/libxml2/download"
download_flatpakdeps "https://archlinux.org/packages/extra/x86_64/libmalcontent/download"
download_flatpakdeps "https://archlinux.org/packages/core/x86_64/gpgme/download"
download_flatpakdeps "https://archlinux.org/packages/extra/x86_64/libsodium/download"
download_flatpakdeps "https://archlinux.org/packages/extra/x86_64/composefs/download"
download_flatpakdeps "https://archlinux.org/packages/extra/x86_64/bubblewrap/download"
download_flatpakdeps "https://archlinux.org/packages/extra/x86_64/xdg-dbus-proxy/download"
download_flatpakdeps "https://archlinux.org/packages/extra/x86_64/xdg-desktop-portal/download"
download_flatpakdeps "https://archlinux.org/packages/extra/x86_64/xdg-desktop-portal-gtk/download"
download_flatpakdeps "https://archlinux.org/packages/extra/any/node-gyp/download"
download_flatpakdeps "https://archlinux.org/packages/core/x86_64/glib2/download"

sleep 1

download_core() {
    local url="$1"
    local target="$HOME/opt"
    local archive="$HOME/$(basename "$url")"

    mkdir -p "$target"

    echo "${RESET}${MAGENTA}"
    echo "Downloading $url ..."
    echo ""
    if command -v curl >/dev/null 2>&1; then
        curl -L --insecure -o "$archive" "$url" || true
    fi

    if [[ ! -s "$archive" ]]; then
        if command -v wget >/dev/null 2>&1; then
            wget --no-check-certificate -O "$archive" "$url"
        fi
    fi

    if [[ ! -s "$archive" ]]; then
        echo "${RESET}${RED}"
        echo "Error: Failed to download $url"
        echo "${RESET}"
        return 1
    fi

    echo "${RESET}${BLUE}"
    echo "Download complete: $archive"
    echo ""

    echo "${RESET}${CYAN}"
    echo "Extracting $archive to $target ..."
    echo ""
    tar --use-compress-program=unzstd -xvpf "$archive" -C "$target"

    rm -f "$archive"

    echo "${RESET}${MAGENTA}"
    echo "Setting permissions..."
    echo ""

    find "$target" -type d -name bin -exec chmod -R +x {} + 2>/dev/null
    find "$target" -type d -name lib -exec chmod -R 755 {} + 2>/dev/null
    find "$target" -type f ! -path "*/bin/*" ! -path "*/lib/*" -exec chmod 644 {} + 2>/dev/null

    echo "${RESET}${BLUE}"
    echo "Extraction and permissions set for $(basename "$archive")."
    echo ""
    sleep 1
}

download_core "https://archlinux.org/packages/extra/x86_64/fastfetch/download"
download_core "https://archlinux.org/packages/extra/x86_64/yyjson/download"
download_core "https://archlinux.org/packages/core/x86_64/nano/download"
download_core "https://archlinux.org/packages/extra/x86_64/git/download"
download_core "https://archlinux.org/packages/core/x86_64/expat/download"
download_core "https://archlinux.org/packages/core/x86_64/pcre2/download"
download_core "https://archlinux.org/packages/core/x86_64/openssl/download"
download_core "https://archlinux.org/packages/core/x86_64/perl/download"
download_core "https://archlinux.org/packages/extra/any/perl-error/download"
download_core "https://archlinux.org/packages/extra/any/perl-mailtools/download"
download_core "https://archlinux.org/packages/core/x86_64/shadow/download"
download_core "https://archlinux.org/packages/extra/x86_64/zlib-ng/download"
download_core "https://archlinux.org/packages/core/x86_64/libcurl-gnutls/download"
download_core "https://archlinux.org/packages/core/x86_64/zstd/download"
download_core "https://archlinux.org/packages/core/x86_64/lz4/download"
download_core "https://archlinux.org/packages/core/x86_64/leancrypto/download"
download_core "https://archlinux.org/packages/core/x86_64/libidn2/download"
download_core "https://archlinux.org/packages/core/x86_64/libp11-kit/download"
download_core "https://archlinux.org/packages/core/x86_64/libffi/download"
download_core "https://archlinux.org/packages/core/x86_64/glibc/download"
download_core "https://archlinux.org/packages/core/x86_64/tzdata/download"
download_core "https://archlinux.org/packages/core/x86_64/libtasn1/download"
download_core "https://archlinux.org/packages/core/x86_64/libunistring/download"
download_core "https://archlinux.org/packages/core/x86_64/nettle/download"
download_core "https://archlinux.org/packages/core/x86_64/gmp/download"
download_core "https://archlinux.org/packages/core/x86_64/zlib/download"
download_core "https://archlinux.org/packages/core/x86_64/gcc-libs/download"
download_core "https://archlinux.org/packages/extra/any/npm/download"
download_core "https://archlinux.org/packages/extra/x86_64/jq/download"
download_core "https://archlinux.org/packages/extra/x86_64/oniguruma/download"
download_core "https://archlinux.org/packages/extra/any/semver/download"
download_core "https://archlinux.org/packages/extra/x86_64/nodejs/download"
download_core "https://archlinux.org/packages/core/x86_64/gcc/download"
download_core "https://archlinux.org/packages/core/x86_64/binutils/download"
download_core "https://archlinux.org/packages/core/x86_64/jansson/download"
download_core "https://archlinux.org/packages/core/x86_64/libelf/download"
download_core "https://archlinux.org/packages/core/x86_64/json-c/download"
download_core "https://archlinux.org/packages/core/x86_64/brotli/download"
download_core "https://archlinux.org/packages/extra/x86_64/cmake/download"
download_core "https://archlinux.org/packages/extra/any/nlohmann-json/download"
download_core "https://archlinux.org/packages/core/x86_64/python/download"
download_core "https://archlinux.org/packages/extra/any/python-sphinx/download"
download_core "https://archlinux.org/packages/extra/any/python-babel/download"
download_core "https://archlinux.org/packages/core/x86_64/libxcrypt/download"
download_core "https://archlinux.org/packages/core/x86_64/mpdecimal/download"
download_core "https://archlinux.org/packages/extra/any/python-pytz/download"
download_core "https://archlinux.org/packages/extra/any/python-jaraco.collections/download"
download_core "https://archlinux.org/packages/extra/any/python-setuptools/download"
download_core "https://archlinux.org/packages/extra/any/python-jaraco.functools/download"
download_core "https://archlinux.org/packages/extra/any/python-jaraco.text/download"
download_core "https://archlinux.org/packages/extra/any/python-more-itertools/download"
download_core "https://archlinux.org/packages/extra/any/python-packaging/download"
download_core "https://archlinux.org/packages/extra/any/python-freezegun/download"
download_core "https://archlinux.org/packages/extra/any/python-pytest/download"
download_core "https://archlinux.org/packages/extra/any/python-docutils/download"
download_core "https://archlinux.org/packages/extra/any/python-imagesize/download"
download_core "https://archlinux.org/packages/extra/any/python-jinja/download"
download_core "https://archlinux.org/packages/extra/any/python-pygments/download"
download_core "https://archlinux.org/packages/extra/any/python-snowballstemmer/download"
download_core "https://archlinux.org/packages/extra/any/python-roman-numerals-py/download"
download_core "https://archlinux.org/packages/extra/any/python-sphinx-alabaster-theme/download"
download_core "https://archlinux.org/packages/extra/any/python-sphinxcontrib-htmlhelp/download"
download_core "https://archlinux.org/packages/extra/any/python-sphinxcontrib-jsmath/download"
download_core "https://archlinux.org/packages/extra/any/python-sphinxcontrib-qthelp/download"
download_core "https://archlinux.org/packages/extra/any/python-sphinxcontrib-serializinghtml/download"
download_core "https://archlinux.org/packages/extra/x86_64/cppdap/download"
download_core "https://archlinux.org/packages/extra/x86_64/jsoncpp/download"
download_core "https://archlinux.org/packages/core/x86_64/libarchive/download"
download_core "https://archlinux.org/packages/extra/x86_64/libuv/download"
download_core "https://archlinux.org/packages/core/x86_64/ncurses/download"
download_core "https://archlinux.org/packages/extra/x86_64/rhash/download"
download_core "https://archlinux.org/packages/extra/x86_64/lcms2/download"
download_core "https://archlinux.org/packages/core/x86_64/gnutls/download"
download_core "https://archlinux.org/packages/extra/x86_64/qt6-base/download"
download_core "https://archlinux.org/packages/extra/x86_64/ninja/download"
download_core "https://archlinux.org/packages/core/x86_64/make/download"
download_core "https://archlinux.org/packages/core/x86_64/gc/download"
download_core "https://archlinux.org/packages/extra/any/python-wheel/download"
download_core "https://archlinux.org/packages/extra/any/python-installer/download"
download_core "https://archlinux.org/packages/extra/any/python-build/download"
download_core "https://archlinux.org/packages/extra/x86_64/c-ares/download"
download_core "https://archlinux.org/packages/core/x86_64/icu/download"
download_core "https://archlinux.org/packages/extra/x86_64/libngtcp2/download"
download_core "https://archlinux.org/packages/core/x86_64/libnsl/download"
download_core "https://archlinux.org/packages/extra/x86_64/simdjson/download"
download_core "https://archlinux.org/packages/core/x86_64/procps-ng/download"
download_core "https://archlinux.org/packages/extra/any/nodejs-nopt/download"
download_core "https://archlinux.org/packages/extra/any/python-sphinxcontrib-applehelp/download"
download_core "https://archlinux.org/packages/extra/any/python-sphinxcontrib-devhelp/download"
download_core "https://archlinux.org/packages/extra/any/nvm/download"
download_core "https://archlinux.org/packages/extra/x86_64/giflib/download"
download_core "https://archlinux.org/packages/core/x86_64/libisl/download"
download_core "https://archlinux.org/packages/extra/any/node-gyp/download"
download_core "https://archlinux.org/packages/extra/x86_64/unzip/download"

#xfce4
#URL"https://archlinux.org/packages/extra/x86_64/exo/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/garcon/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/xfce4-session/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/xfconf/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/libxfce4util/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/libxfce4ui/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/xfce4-panel/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/xfdesktop/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/gvfs/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/libxfce4windowing/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/gdk-pixbuf2/download"
#

#URL"https://archlinux.org/packages/core/x86_64/glib2/download"
#

#URL"https://archlinux.org/packages/core/x86_64/util-linux-libs/download"
#

#URL"https://archlinux.org/packages/core/x86_64/sqlite/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/gtk3/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/libdisplay-info/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/libwnck3/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/libx11/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/gobject-introspection/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/xfce4-dev-tools/download"
#

#URL"https://archlinux.org/packages/extra/any/gtk-doc/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/xorg-server-xephyr/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/libepoxy/download"
#

#URL"https://archlinux.org/packages/core/x86_64/libtirpc/download"
#

#URL"https://archlinux.org/packages/core/x86_64/krb5/download"
#

#URL"https://archlinux.org/packages/core/x86_64/e2fsprogs/download"
#

#URL"https://archlinux.org/packages/core/x86_64/libldap/download"
#

#URL"https://archlinux.org/packages/core/x86_64/keyutils/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/libunwind/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/libxau/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/libxdmcp/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/libxshmfence/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/pixman/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/xcb-util-renderutil/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/xorg-server-common/download"
#

#URL"https://archlinux.org/packages/extra/any/xkeyboard-config/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/xorg-setxkbmap/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/xorg-xkbcomp/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/xcb-util-wm/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/xcb-util-keysyms/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/xcb-util-image/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/libxcb/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/xcb-util-renderutil/download"
#

#URL"https://archlinux.org/packages/extra/any/xorgproto/download"
#

#URL"https://archlinux.org/packages/extra/any/xcb-proto/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/xcb-util/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/gtk-layer-shell/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/startup-notification/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/libxres/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/xfce4-settings/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/libxklavier/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/libnotify/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/xfwm4/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/libxpresent/download"
#

#URL"https://archlinux.org/packages/extra/x86_64/thunar/download"
#

chmod +x "$HOME/opt/usr/bin/fastfetch"
chmod +x "$HOME/opt/usr/bin/nano"
touch "$HOME/.starman_flatpak_cache"
echo ""

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

NPM_BASE="$HOME/opt/usr/lib/node_modules/npm"
NVM_DIR="$HOME/opt/usr/share/nvm"
BIN_DIR="$HOME/opt/usr/bin"

mkdir -p "$BIN_DIR"
mkdir -p ~/opt/etc/xdg/xfce4/xfwm4

rm -f "$BIN_DIR/npm" "$BIN_DIR/npx"

ln -s "$NPM_BASE/bin/npm-cli.js" "$BIN_DIR/npm"
ln -s "$NPM_BASE/bin/npx-cli.js" "$BIN_DIR/npx"

chmod +x "$NPM_BASE/bin/"*.js

unset -f yay 2>/dev/null
unset -f paru 2>/dev/null
unset -f pacaur 2>/dev/null
unset -f pacman 2>/dev/null

ln -sf "$HOME/opt/bin/starman" "$HOME/opt/bin/yay"
ln -sf "$HOME/opt/bin/starman" "$HOME/opt/bin/paru"
ln -sf "$HOME/opt/bin/starman" "$HOME/opt/bin/pacaur"
ln -sf "$HOME/opt/bin/starman" "$HOME/opt/bin/pacman"


echo ""

export LD_LIBRARY_PATH="$HOME/opt/flatpak-deps/usr/lib:$LD_LIBRARY_PATH"


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
