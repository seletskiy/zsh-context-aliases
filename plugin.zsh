function context-aliases:init() {
    _aliases_contexts=()
    _aliases_context_loading=1
    _aliases_session=''
    _aliases_current=''
}

function context-aliases:match() {
    local expression="${@}"
    local new_aliases=$(:get-added-aliases "${_aliases_contexts[-2]}")

    _aliases_context_loading=1

    _aliases_contexts+=(
        "$new_aliases" \
        "$expression" \
    )
}

function :get-added-aliases() {
    local previous_aliases="$1"
    local current_aliases=$(alias -L | :fix-alias-list-output)

    diff \
        <(cat <<< "$previous_aliases") \
        <(cat <<< "$current_aliases") \
            | grep '^> ' \
            | cut -b3-
}

function context-aliases:on-precmd() {
    if [ "$_aliases_context_loading" ]; then
        context-aliases:match "true"

        unset _aliases_context_loading
    else
        _aliases_session=$(:get-added-aliases "$_aliases_current")
    fi

    unalias -m '*'

    eval -- "${_aliases_contexts[1]}"

    local i
    for ((i = 2; i < $((${#_aliases_contexts})); i += 2)); do
        if eval -- "${_aliases_contexts[$i]}"; then
            eval -- "${_aliases_contexts[$(($i+1))]}"
        fi
    done

    _aliases_current=$(alias -L | :fix-alias-list-output)

    eval -- "$_aliases_session"
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
function :fix-alias-list-output() {
    sed -re 's/alias \+/alias -- +/'
}

autoload -U add-zsh-hook
add-zsh-hook precmd context-aliases:on-precmd

context-aliases:init
