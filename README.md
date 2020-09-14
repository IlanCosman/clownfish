# Clownfish

## Installation

With [fisher][]:

```console
fisher add IlanCosman/clownfish
```

## Usage

```console
Usage: mock [options] [command] [argument] [exit code] [executedCode]

Options:
  -e or --erase    erase a mocked command/argument
  -v or --version  print the current mock version
  -h or --help     print this help message

Examples:
  mock git pull 0 "echo This command echoes succesfully!"
  mock git push 1 "echo This command fails with status 1"
  mock git \* 0 "echo This command acts as a fallback to all git commands"

  mock -e git push # Remove git push mock
  mock -e git \* # Remove the fallback mock
  mock -e git # Remove all git mocks

Tips:
  - Many mocks can be applied to the same command at the same time with different arguments.
  - Be sure to escape the asterisk symbol when using it as a fallback (\*).
```

## Acknowledgements

- [fish-mock][] - Inspired much of Clownfish's design and creation.

[fish-mock]: https://github.com/matchai/fish-mock
[fisher]: https://github.com/jorgebucaran/fisher
