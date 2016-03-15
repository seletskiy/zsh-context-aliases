tests_source set-up.sh

tests_copy ../plugin.zsh

tests_do tee aliases <<EOF
unalias -m '*'

alias -- +x="chmod +x"
EOF

tests_do tmux-prepare
tests_do tmux-send "source plugin.zsh && source aliases" enter
tests_do tmux-send "touch test_file" enter
tests_do tmux-send "+x test_file" enter

tests_do tmux-wait-sync

tests_test -x test_file

tests_source tear-down.sh
