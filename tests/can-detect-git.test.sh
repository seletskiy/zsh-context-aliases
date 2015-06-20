tests_source set-up.sh

tests_copy ../plugin.zsh

tests_do mkdir repo

tests_do tee aliases <<'EOF'
unalias -m '*'

alias s="touch"

aliases_context is_inside_git_dir
    alias s="touch git_detected"

aliases_context done
EOF

tests_do tmux-prepare
tests_do tmux-send "source plugin.zsh" enter
tests_do tmux-send "source aliases" enter

tests_do tmux-send "cd repo" enter
tests_do tmux-send "s no_repo_yet" enter

tests_do tmux-wait-sync

tests_test -e repo/no_repo_yet

tests_do tmux-send "git init" enter
tests_do tmux-send "s" enter

tests_do tmux-wait-sync

tests_test -e repo/git_detected

tests_source tear-down.sh
