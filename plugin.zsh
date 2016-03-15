
function aliases_context_init() {
    _aliases_contexts=()
    _aliases_context_loading=1
}

function aliases_context() {
    previous_aliases=$_aliases_contexts[-2]
    current_aliases=$(alias -L | _fix-alias-output)

    context_aliases=$(diff \
        <(cat <<< "$previous_aliases") \
        <(cat <<< "$current_aliases") \
        | grep '^> ' | cut -b3-)

    expression="${@}"

    _aliases_contexts+=(
        "$context_aliases" \
        "$expression" \
    )
}

function _change-aliases-context() {
    if [ "$_aliases_context_loading" ]; then
        aliases_context "true"
        unset _aliases_context_loading
    fi

    unalias -m '*'

    eval -- "${_aliases_contexts[1]}"

    for ((i = 2; i < $((${#_aliases_contexts})); i += 2)); do
        if eval -- "${_aliases_contexts[$i]}"; then
            eval -- "${_aliases_contexts[$(($i+1))]}"
        fi
    done
}

# Fix shitty zsh code.
#
# From man zshall:
#   alias [ {+|-}gmrsL ] [ name[=value] ... ]
#     If the -L flag is present, then print each alias in a manner suitable for
#     putting in a startup script.
#
# Let's try:
#   $ alias -- +x='chmod +x'
#   $ alias -L
#   alias +x='chmod +x'
#   $ eval $(alias -L)
#   zsh: bad option: -x
function _fix-alias-output() {
    sed -re 's/alias \+/alias -- +/'
}

autoload -U add-zsh-hook
add-zsh-hook precmd _change-aliases-context

aliases_context_init
