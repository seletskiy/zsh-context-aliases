TMUX_SESSION=${TMUX_SESSION:-zsh-context-aliases}

if ! tests_do tmux has-session -t $TMUX_SESSION; then
    tests_do cat <<EOF
tmux session is not found.

Please, run tmux session with following command:

    tmux new -s $TMUX_SESSION
EOF

    tests_interrupt
fi

function tmux-send() {
    tmux send-keys -t $TMUX_SESSION "${@}"
}

function tmux-prepare() {
    tmux-send "cd $(tests_tmpdir)" enter
    tmux-send "zsh -df" enter
}

function tmux-wait-sync() {
    tmux-send "touch $(tests_tmpdir)/.done" enter

    trials=10
    while [ ! -e $(tests_tmpdir)/.done -a $trials -gt 0 ]; do
        trials=$(($trials-1))
        sleep 0.1
    done

    rm -f .done

    if [ $trials -le 0 ]; then
        echo "tmux sync is timed out"
        tests_interrupt
    fi
}
