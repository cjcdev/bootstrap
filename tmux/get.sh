#!/bin/sh

BASE=https://raw.githubusercontent.com/cjcdev/bootstrap/tmux/main/
TMUX_CONF=${BASE}/tmux.conf
DEST=~/.tmux.conf

wget -O ${DEST} ${TMUX_CONF}
echo "tmux config stored in ${DEST}"
