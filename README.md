Stupid as a fish. Mighty as a bear.

What is it? It is...

# zsh context aliases

Define aliases based on context. Context is a shell function which is
reevaluated each time prompt is drawn.

For example, you can have alias `s` which is `git status -s` only when you are
inside git working directory.

Or alias `c` can be `git commit -m`, but if working tree is not dirty, then
`git commit --amend -m`.

## Installation

### zgen

```zsh
zgen load seletskiy/zsh-context-aliases
```

### antigen
```zsh
antigen bundle seletskiy/zsh-context-aliases
```

### Bare-bone usage
```zsh
git clone github.com/seletskiy/zsh-context-aliases ~/.zsh/zsh-context-aliases

fpath+=(~/.zsh/zsh-context-aliases)
source ~/.zsh/zsh-context-aliases
```

## Usage

You can use all your aliases definitions untouched. Plugin is smart enough to
understand aliases definitions and use them.

When you want to define aliases only in specific context, you should use
following syntax:

```zsh
alias s="default command"

aliases_context some_expression
    alias s="context specific command"
```

Also, it's a good idea to place `aliases_context_init` in the beginning of the
your `.zshrc` or aliases file, so if you reload configuration in running shell,
all context aliases will get properly re-initialized.

## Tips and tricks

Library comes with handy helper functions, which can be used to determine
context. They should be autoloaded before use:

```zsh
autoload is_inside_git_repo
aliases_context is_inside_git_repo
    alias a='git add'
    alias s='git status'
    ...
```

### `is_inside_git_repo`

Exits with 0 status if current directory is a working directory for git repo.

### `is_git_repo_dirty`

Exits with 0 if current directory is a dirty working directory.

### `is_rebase_in_progress`

Exits with 0 status if rebase in progress.
