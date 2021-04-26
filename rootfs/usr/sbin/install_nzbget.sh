#!/bin/sh
set -x
ARCH="$(uname -m)"
echo "building for ${ARCH}"

mkdir /usr/bin/nzbget
wget "https://github.com/nzbget/nzbget/releases/download/v21.0/nzbget-21.0-bin-linux.run" -O /usr/bin/nzbget/install.run
chmod +x /usr/bin/nzbget

sh /usr/bin/nzbget/install.run --destdir /usr/bin/nzbget