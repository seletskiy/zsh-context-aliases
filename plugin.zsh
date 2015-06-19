typeset -a _aliases_contexts

function context() {
    previous_aliases=$_aliases_contexts[-2]
    current_aliases=$(alias -L)

    context_aliases=$(diff \
        <(cat <<< "$previous_aliases") \
        <(cat <<< "$current_aliases") \
        | grep '^[><] ' | cut -b3-)

    expression="${@}"

    _aliases_contexts=(
        "$_aliases_contexts[@]" \
        "$context_aliases" \
        "$expression" \
    )

    if [[ "$expression" == "end" ]]; then
        _change-aliases-context
    fi
}

function _change-aliases-context() {
    unalias -m '*'

    eval "${_aliases_contexts[2]}"

    for ((i = 3; i < ${#_aliases_contexts}; i += 2)); do
        if eval "${_aliases_contexts[$i]}"; then
            eval "${_aliases_contexts[$(($i+1))]}"
        fi
    done
}

function is_inside_git_dir() {
    git rev-parse --show-toplevel >/dev/null 2>&1
}

add-zsh-hook precmd _change-aliases-context
