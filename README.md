A simple command-line application.

```
./ez_conftest.py -c 'ps aux' './sshd.py'
```

Output like
```
WARN - - main - no pr input. restic tests will be ignored.
WARN - - main - no restic input. restic tests will be ignored.
FAIL - - main - neovim process 5.800000 %

10 tests, 7 passed, 2 warnings, 1 failure, 0 exceptions
```
