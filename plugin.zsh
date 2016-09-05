function context-aliases:init() {
    _aliases_contexts=()
    _aliases_context_loading=1
    _aliases_session=''
    _aliases_current=''
    _aliases_previous=''
    _aliases_last_contexts=("--UNSET--")
}

function context-aliases:match() {
    local expression="${@}"
    local new_aliases=$(:get-added-aliases "$_aliases_previous")

    _aliases_previous=$(alias -L | :fix-alias-list-output)

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
    local i
    local context
    local failed=()
    local succeed=()
    local new_aliases=()

    for ((i = 2; i < $((${#_aliases_contexts})); i += 2)); do
        context=${_aliases_contexts[$i]}

        for prefix in "${failed[@]}"; do
            if [[ "${context:0:${#prefix}}" == "$prefix" ]]; then
                continue 2
            fi
        done

        if eval -- "$context"; then
            succeed+=("$context")
            new_aliases+="${_aliases_contexts[$i + 1]}"
        else
            failed+=("$context")
        fi
    done

    if [[ "${_aliases_last_contexts[*]}" == "${succeed[*]}" ]]; then
        return
    fi

    _aliases_last_contexts=("${succeed[@]}")

    if [ "$_aliases_context_loading" ]; then
        context-aliases:match "true"

        unset _aliases_context_loading
    else
        _aliases_session=$(:get-added-aliases "$_aliases_current")
    fi

    unalias -m '*'

    eval -- "${_aliases_contexts[1]}"

    local code
    for code in "${new_aliases[@]}"; do
        eval -- "$code"
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
