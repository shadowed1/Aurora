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

read -rp "Enter (0-1): " choice


case "$choice" in
    0)
        echo "Quit"
        ;;
    1)
echo ""
echo "${CYAN}${BOLD}About to start downloading Flatpak, Git, GCC, Python and their dependencies! Download can take up to 5 minutes.${RESET}"
sleep 5

sudo touch /usr/local/aurora/.aurorabashrc

sed -i '/\.flatpak\.env/d' "/usr/local/aurora/.aurorabashrc"
sed -i '/\.flatpak\.logic/d' "/usr/local/aurora/.aurorabashrc"

if grep -q "# Flatpak --user logic" "/usr/local/aurora/.aurorabashrc"; then
sed -i '/# Flatpak --user logic/,/^}/d' "/usr/local/aurora/.aurorabashrc"
echo "${CYAN}Removed Flatpak function from .aurorabashrc${RESET}"
fi

 sudo mkdir -p /usr/local/aurora/flatpak
 sudo mkdir -p /usr/local/aurora/flatpak-deps
 sudo mkdir -p /usr/local/aurora/bin
 
export XDG_RUNTIME_DIR="/usr/local/aurora/.xdg-runtime-dir"
sudo mkdir -p "$XDG_RUNTIME_DIR"
sudo chmod 700 "$XDG_RUNTIME_DIR"

export PATH="/usr/local/aurora/flatpak/usr/bin:/usr/local/aurora/flatpak-deps/usr/bin:/bin:/usr/bin:$PATH"
if [ ! -S "$XDG_RUNTIME_DIR/dbus-session" ]; then
  dbus-daemon --session \
    --address="unix:path=$XDG_RUNTIME_DIR/dbus-session" \
    --print-address=1 \
    --nopidfile \
    --nofork > "$XDG_RUNTIME_DIR/dbus-session.address" &
  sleep 1
fi
export DBUS_SESSION_BUS_ADDRESS=$(cat "$XDG_RUNTIME_DIR/dbus-session.address")

sudo mkdir -p "$XDG_RUNTIME_DIR/doc/portal"
echo 3 > "$XDG_RUNTIME_DIR/doc/portal/version"
sudo chmod +x "/usr/local/aurora/bin/aurora"
sudo chmod +x "/usr/local/aurora/bin/starman"
echo "${MAGENTA}"
curl -L https://raw.githubusercontent.com/shadowed1/Aurora/Aurora2/.flatpak.logic -o /usr/local/aurora/.flatpak.logic
echo "${RESET}${BLUE}"
curl -L https://raw.githubusercontent.com/shadowed1/Aurora/Aurora2/aurora -o /usr/local/aurora/bin/aurora
echo "${RESET}${CYAN}"
curl -L https://raw.githubusercontent.com/shadowed1/Aurora/Aurora2/starman -o /usr/local/aurora/bin/starman
echo "${RESET}${BLUE}"
curl -L https://raw.githubusercontent.com/shadowed1/Aurora/Aurora2/version -o /usr/local/aurora/bin/version
echo "${RESET}${MAGENTA}"
curl -L https://raw.githubusercontent.com/shadowed1/Aurora/Aurora2/.flatpak.env -o /usr/local/aurora/.flatpak.env
echo "${RESET}"
sudo chmod +x /usr/local/aurora/bin/aurora
sudo chmod +x /usr/local/aurora/bin/starman

echo ""

download_and_extract()
{
    local url="$1"
    local target_dir="$2"
    local FILE SAFE_FILE

    echo "${MAGENTA}"
    echo "Downloading: $url"

    env -i PATH="$PATH" wget --content-disposition --trust-server-names "$url"

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

    env -i PATH="$PATH" tar --use-compress-program=unzstd -xvf "$FILE" -C "$target_dir"

    rm -f "$FILE"
    sudo chmod +x "$target_dir/usr/bin"/* 2>/dev/null
    sudo chmod +x "/usr/local/aurora/usr/bin"/* 2>/dev/null
    sudo chmod +x "/usr/local/aurora/usr/share"/* 2>/dev/null
    echo "${RESET}${CYAN}${FILE} extracted.${RESET}"

    export LD_LIBRARY_PATH="$target_dir/usr/lib:/usr/local/aurora/usr/lib:$LD_LIBRARY_PATH"
    export FLATPAK_USER_DIR="/usr/local/aurora/.local/share/flatpak"
    sleep 1
}

# Flatpak Core
URL="https://archlinux.org/packages/extra/x86_64/flatpak/download"
download_and_extract "$URL" "/usr/local/aurora/flatpak"

URL="https://archlinux.org/packages/extra/x86_64/ostree/download"
download_and_extract "$URL" "/usr/local/aurora/flatpak-deps"

URL="https://archlinux.org/packages/core/x86_64/libxml2/download"
download_and_extract "$URL" "/usr/local/aurora/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/libmalcontent/download"
download_and_extract "$URL" "/usr/local/aurora/flatpak-deps"

URL="https://archlinux.org/packages/core/x86_64/gpgme/download"
download_and_extract "$URL" "/usr/local/aurora/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/libsodium/download"
download_and_extract "$URL" "/usr/local/aurora/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/composefs/download"
download_and_extract "$URL" "/usr/local/aurora/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/bubblewrap/download"
download_and_extract "$URL" "/usr/local/aurora/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/xdg-dbus-proxy/download"
download_and_extract "$URL" "/usr/local/aurora/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/xdg-desktop-portal/download"
download_and_extract "$URL" "/usr/local/aurora/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/xdg-desktop-portal-gtk/download"
download_and_extract "$URL" "/usr/local/aurora/flatpak-deps"

############################################################## 
# Fastfetch
URL="https://archlinux.org/packages/extra/x86_64/fastfetch/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/x86_64/yyjson/download"
download_and_extract "$URL" "/usr/local/aurora/"

############################################################## 
# Nano
URL="https://archlinux.org/packages/core/x86_64/nano/download"
download_and_extract "$URL" "/usr/local/aurora/"

############################################################## 
# Git
URL="https://archlinux.org/packages/extra/x86_64/git/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/expat/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/pcre2/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/openssl/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/perl/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/perl-error/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/perl-mailtools/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/shadow/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/x86_64/zlib-ng/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/libcurl-gnutls/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/zstd/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/lz4/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/leancrypto/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/libidn2/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/libp11-kit/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/libffi/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/glibc/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/tzdata/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/libtasn1/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/libunistring/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/nettle/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/gmp/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/zlib/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/gcc-libs/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/npm/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/x86_64/jq/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/x86_64/oniguruma/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/node-gyp/download"
download_and_extract "$URL" "/usr/local/aurora/flatpak-deps"

URL="https://archlinux.org/packages/extra/any/semver/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/x86_64/nodejs/download"
download_and_extract "$URL" "/usr/local/aurora/"

# gcc
URL="https://archlinux.org/packages/core/x86_64/gcc/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/binutils/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/jansson/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/libelf/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/json-c/download"
download_and_extract "$URL" "/usr/local/aurora/"


# python
URL="https://archlinux.org/packages/core/x86_64/brotli/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/x86_64/cmake/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/nlohmann-json/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/python/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-sphinx/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-babel/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/libxcrypt/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/mpdecimal/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-pytz/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-jaraco.collections/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-setuptools/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-jaraco.functools/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-jaraco.text/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-more-itertools/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-packaging/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-freezegun/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-pytest/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-docutils/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-imagesize/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-jinja/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-pygments/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-snowballstemmer/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-roman-numerals-py/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-sphinx-alabaster-theme/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-sphinxcontrib-htmlhelp/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-sphinxcontrib-jsmath/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-sphinxcontrib-qthelp/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-sphinxcontrib-serializinghtml/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/x86_64/cppdap/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/x86_64/jsoncpp/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/libarchive/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/x86_64/libuv/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/ncurses/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/x86_64/rhash/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/x86_64/lcms2/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/gnutls/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/x86_64/qt6-base/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/x86_64/ninja/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/make/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/gc/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-wheel/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-installer/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-build/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/x86_64/c-ares/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/icu/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/x86_64/libngtcp2/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/libnsl/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/x86_64/simdjson/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/procps-ng/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/nodejs-nopt/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-sphinxcontrib-applehelp/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/python-sphinxcontrib-devhelp/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/nvm/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/x86_64/giflib/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/core/x86_64/libisl/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/any/node-gyp/download"
download_and_extract "$URL" "/usr/local/aurora/"

URL="https://archlinux.org/packages/extra/x86_64/unzip/download"
download_and_extract "$URL" "/usr/local/aurora/"

#xfce4
#URL"https://archlinux.org/packages/extra/x86_64/exo/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/garcon/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/xfce4-session/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/xfconf/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/libxfce4util/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/libxfce4ui/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/xfce4-panel/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/xfdesktop/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/gvfs/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/libxfce4windowing/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/gdk-pixbuf2/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/core/x86_64/glib2/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/core/x86_64/util-linux-libs/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/core/x86_64/sqlite/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/gtk3/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/libdisplay-info/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/libwnck3/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/libx11/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/gobject-introspection/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/xfce4-dev-tools/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/any/gtk-doc/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/xorg-server-xephyr/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/libepoxy/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/core/x86_64/libtirpc/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/core/x86_64/krb5/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/core/x86_64/e2fsprogs/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/core/x86_64/libldap/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/core/x86_64/keyutils/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/libunwind/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/libxau/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/libxdmcp/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/libxshmfence/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/pixman/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/xcb-util-renderutil/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/xorg-server-common/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/any/xkeyboard-config/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/xorg-setxkbmap/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/xorg-xkbcomp/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/xcb-util-wm/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/xcb-util-keysyms/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/xcb-util-image/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/libxcb/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/xcb-util-renderutil/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/any/xorgproto/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/any/xcb-proto/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/xcb-util/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/gtk-layer-shell/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/startup-notification/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/libxres/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/xfce4-settings/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/libxklavier/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/libnotify/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/xfwm4/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/libxpresent/download"
#download_and_extract "$URL" "/usr/local/aurora/"

#URL"https://archlinux.org/packages/extra/x86_64/thunar/download"
#download_and_extract "$URL" "/usr/local/aurora/"

sudo chmod +x "/usr/local/aurora/usr/bin/fastfetch"
sudo chmod +x "/usr/local/aurora/usr/bin/nano"
touch "/usr/local/aurora//.starman_flatpak_cache"
echo ""

if file "$XDG_RUNTIME_DIR/dbus-session" | grep -q socket; then
  export DBUS_SESSION_BUS_ADDRESS=$(grep -E '^unix:' "$XDG_RUNTIME_DIR/dbus-session.address")
  grep -v '^export DBUS_SESSION_BUS_ADDRESS=' "/usr/local/aurora/.flatpak.env" > "/usr/local/aurora/.flatpak.env.tmp"
  echo "export DBUS_SESSION_BUS_ADDRESS=\"$DBUS_SESSION_BUS_ADDRESS\"" >> "/usr/local/aurora/.flatpak.env.tmp"
  mv "/usr/local/aurora/.flatpak.env.tmp" "/usr/local/aurora/.flatpak.env"
else
  echo "dbus socket not found."
fi

[ -f "/usr/local/aurora/.aurorabashrc" ] || touch "/usr/local/aurora/.aurorabashrc"

FLATPAK_ENV_LINE='[ -f "/usr/local/aurora/.flatpak.env" ] && . "/usr/local/aurora/.flatpak.env"'
FLATPAK_LOGIC_LINE='[ -f "/usr/local/aurora/.flatpak.logic" ] && . "/usr/local/aurora/.flatpak.logic"'

grep -Fxq "$FLATPAK_ENV_LINE" "/usr/local/aurora/.aurorabashrc" || echo "$FLATPAK_ENV_LINE" >> "/usr/local/aurora/.aurorabashrc"
grep -Fxq "$FLATPAK_LOGIC_LINE" "/usr/local/aurora/.aurorabashrc" || echo "$FLATPAK_LOGIC_LINE" >> "/usr/local/aurora/.aurorabashrc"


if [ ! -f "/usr/local/aurora/flatpak-deps/usr/lib/libostree-1.so.1" ]; then
  echo "libostree-1.so.1 missing from deps!"
  exit 1
fi

"/usr/local/aurora/flatpak/usr/bin/flatpak" --version
sleep 3

NPM_BASE="/usr/local/aurora/usr/lib/node_modules/npm"
NVM_DIR="/usr/local/aurora/usr/share/nvm"
BIN_DIR="/usr/local/aurora/usr/bin"

sudo mkdir -p "$BIN_DIR"
sudo mkdir -p /usr/local/aurora/etc/xdg/xfce4/xfwm4

rm -f "$BIN_DIR/npm" "$BIN_DIR/npx"

ln -s "$NPM_BASE/bin/npm-cli.js" "$BIN_DIR/npm"
ln -s "$NPM_BASE/bin/npx-cli.js" "$BIN_DIR/npx"

sudo chmod +x "$NPM_BASE/bin/"*.js

unset -f yay 2>/dev/null
unset -f paru 2>/dev/null
unset -f pacaur 2>/dev/null
unset -f pacman 2>/dev/null

ln -sf "/usr/local/aurora/bin/starman" "/usr/local/aurora/bin/yay"
ln -sf "/usr/local/aurora/bin/starman" "/usr/local/aurora/bin/paru"
ln -sf "/usr/local/aurora/bin/starman" "/usr/local/aurora/bin/pacaur"
ln -sf "/usr/local/aurora/bin/starman" "/usr/local/aurora/bin/pacman"


echo ""

export LD_LIBRARY_PATH="/usr/local/aurora/flatpak-deps/usr/lib:$LD_LIBRARY_PATH"


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

