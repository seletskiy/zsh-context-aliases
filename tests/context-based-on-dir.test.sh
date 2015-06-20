tests_source set-up.sh

tests_copy ../plugin.zsh

tests_do mkdir 1 2

tests_do tee aliases <<'EOF'
unalias -m '*'

aliases_context '[ "$(basename $(pwd))" = "1" ]'
    alias t="touch file_a"

aliases_context '[ "$(basename $(pwd))" = "2" ]'
    alias t="touch file_b"

aliases_context end
EOF

tests_do tmux-prepare
tests_do tmux-send "source plugin.zsh" enter
tests_do tmux-send "source aliases" enter
tests_do tmux-send "cd 1" enter
tests_do tmux-send "t" enter
tests_do tmux-send "cd ../2" enter
tests_do tmux-send "t" enter

tests_do cat aliases

tests_do tmux-wait-sync

tests_test -e 1/file_a
tests_test -e 2/file_b

tests_source tear-down.sh
