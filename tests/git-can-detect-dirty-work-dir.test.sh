tests_source set-up.sh

tests_copy ../plugin.zsh
tests_copy ../is_inside_git_repo
tests_copy ../is_git_repo_dirty

tests_do mkdir repo

tests_do tee aliases <<'EOF'
unalias -m '*'

autoload is_inside_git_repo
autoload is_git_repo_dirty

aliases_context is_inside_git_repo
    alias s="touch git_detected"

aliases_context is_inside_git_repo \&\& is_git_repo_dirty
    alias s="touch git_dirty"

aliases_context done
EOF

tests_do tmux-prepare
tests_do tmux-send "source plugin.zsh" enter
tests_do tmux-send "source aliases" enter

tests_do tmux-send "cd repo" enter

tests_do tmux-send "git init" enter
tests_do tmux-send "s" enter

tests_do tmux-wait-sync
tests_test -e repo/git_detected

tests_do tmux-send "touch asd" enter
tests_do tmux-send "git add ." enter
tests_do tmux-send "s" enter

tests_do tmux-wait-sync
tests_test -e repo/git_dirty

tests_source tear-down.sh
