tests_source set-up.sh

tests_copy ../plugin.zsh

tests_do tee aliases <<EOF
unalias -m '*'

alias 1="touch file_1"
EOF

tests_do tmux-prepare
tests_do tmux-send "source plugin.zsh && source aliases" enter
tests_do tmux-send "1" enter

tests_do tmux-wait-sync

tests_test -e file_1

tests_source tear-down.sh
