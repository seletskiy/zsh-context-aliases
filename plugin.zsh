function context-aliases:init() {
    _aliases_contexts=()
    _aliases_current=''
    _aliases_previous=''
    _aliases_last_contexts=("--UNSET--")
    _aliases_cache_dir=$HOME/.cache/zsh/context-aliases

    :init:cache
}

function context-aliases:commit() {
    emulate -L zsh
    setopt local_options rm_star_silent

    _aliases_contexts+=(
        "$(alias -L)" \
    )

    local md5sum=$(md5sum <<< "${_aliases_contexts[@]}")
    local cache_name=${md5sum%% *}
    local cache_path=$_aliases_cache_dir/$cache_name

    if [[ -f "$cache_path" ]]; then
        source "$cache_path"
    else
        ( rm -rf $_aliases_cache_dir/*; ) 2>&-

        local contexts=("${_aliases_contexts[1]}")

        for ((i = 2; i <= $((${#_aliases_contexts})); i += 2)); do
            contexts[$i]=${_aliases_contexts[$i]}
            contexts[$i+1]=$(
                :get-added-aliases \
                    "${_aliases_contexts[$i-1]}" \
                    "${_aliases_contexts[$i+1]}"
            )
        done

        _aliases_contexts=("${contexts[@]}")

        typeset -p _aliases_contexts > "$_aliases_cache_dir/$cache_name"
    fi

    unalias -m '*'
    context-aliases:on-precmd
}

function context-aliases:match() {
    emulate -L zsh

    local expression="${@}"
    _aliases_contexts+=(
        "$(alias -L)" \
        "$expression" \
    )
}

function :get-added-aliases() {
    local previous_aliases="$1"
    local current_aliases="$2"

    diff \
        <(<<< "$previous_aliases") \
        <(<<< "$current_aliases") \
            | grep '^> ' \
            | cut -b3-
}

function :init:cache() {
    mkdir -p $_aliases_cache_dir
}

function context-aliases:on-precmd() {
    emulate -L zsh

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
            new_aliases+="${_aliases_contexts[$i+1]}"
        else
            failed+=("$context")
        fi
    done

    if [[ "${_aliases_last_contexts[*]}" == "${succeed[*]}" ]]; then
        return
    fi

    _aliases_last_contexts=("${succeed[@]}")

    local session_aliases

    if [[ "$_aliases_current" != "$(alias -L)" ]]; then
        session_aliases=$(
            :get-added-aliases "$_aliases_current" "$(alias -L)"
        )
    fi

    unalias -m '*'

    eval -- ${_aliases_contexts[1]}

    local code
    for code in "${new_aliases[@]}"; do
        eval -- "$code"
    done

    _aliases_current=$(alias -L)

    eval -- "$session_aliases"
}

autoload -U add-zsh-hook
add-zsh-hook precmd context-aliases:on-precmd

context-aliases:init
