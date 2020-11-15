# Clownfish

## Installation

With [fisher][]:

```console
fisher install IlanCosman/clownfish
```

## Usage

```console
Usage: mock [options] [command] [argument] [executed code]

Options:
  -e or --erase    erase a mocked command/argument
  -h or --help     print this help message

Examples:
  mock git pull "echo This command echoes succesfully"
  mock git push "echo This command fails with status 1; return 1"
  mock git \* "echo This command acts as a fallback to all git commands"

  mock -e git push # Removes git push mock
  mock -e git \* # Removes the fallback mock
  mock -e git # Removes all git mocks

Tips:
  - Many mocks can be applied to the same command at the same time with different arguments.
  - Be sure to escape the asterisk symbol when using it as a fallback (\*).
```

## Acknowledgements

- [fish-mock][] - Inspired much of Clownfish's design and creation.

[fish-mock]: https://github.com/matchai/fish-mock
[fisher]: https://github.com/jorgebucaran/fisher
