tests
=====

Tests require tmux session named 'zsh-context-alises', so first thing is to launch tmux:

```bash
tmux new -s zsh-context-aliases
```

Then, to run all tests use following command from the `tests/` directory.

```bash
./lib/tests.sh -A
```
