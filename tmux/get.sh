#!/bin/sh

BASE=https://raw.githubusercontent.com/cjcdev/bootstrap/main/tmux
TMUX_CONF=${BASE}/tmux.conf
DEST=~/.tmux.conf

wget -q -O ${DEST} ${TMUX_CONF}
echo "tmux config stored in ${DEST}"
