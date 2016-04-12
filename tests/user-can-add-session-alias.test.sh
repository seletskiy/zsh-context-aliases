tests_source set-up.sh

tests_copy ../plugin.zsh

tests_do mkdir 1 2

tests_do tee aliases <<'EOF'
unalias -m '*'

context-aliases:match '[ "$(basename $(pwd))" = "1" ]'
    alias t="touch file_a"
EOF

tests_do tmux-prepare
tests_do tmux-send "source plugin.zsh && source aliases" enter
tests_do tmux-send "alias kek='touch kek'" enter
tests_do tmux-send "alias keuk='touch keuk'" enter
tests_do tmux-send "cd 1" enter
tests_do tmux-send "kek" enter
tests_do tmux-send "cd ../2" enter
tests_do tmux-send "keuk" enter

tests_do cat aliases

tests_do tmux-wait-sync

tests_test -e 1/kek
tests_test -e 2/keuk

tests_source tear-down.sh
