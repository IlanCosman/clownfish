function mock
    if not argparse 'e/erase' 'v/version' 'h/help' -- $argv
        _mock_help
        return 1
    else if set -q _flag_help
        _mock_help
        return 0
    else if set -q _flag_version
        printf '%s\n' 'mock, version 1.0.0'
        return 0
    end

    set cmd $argv[1]
    set arg $argv[2]
    set exit_code $argv[3]
    set executed_code $argv[4]

    if set -q _flag_erase
        if test "$arg" = '*'
            functions --erase $cmd
        else
            functions --erase $cmd'_'$arg
        end
        return 0
    end

    if not set -l type (type --type $cmd)
        _mock_help
        return 1
    end

    if test "$type" = function && not functions --query _non_mocked_$cmd
        functions --copy $cmd _non_mocked_$cmd
    end

    function $cmd'_'$arg --inherit-variable exit_code --inherit-variable executed_code
        eval $executed_code
        return $exit_code
    end

    function $cmd -a argument --inherit-variable cmd --inherit-variable type
        if functions --query $cmd'_'$argument
            $cmd'_'$argument
        else if functions --query $cmd'_*'
            $cmd'_*'
        else
            switch $type
                case function
                    _non_mocked_$cmd $argv
                case builtin
                    builtin $cmd $argv
                case file
                    command $cmd $argv
            end
        end
    end
end

function _mock_help
    printf '%s' '
Usage: mock [options] [command] [argument] [exit code] [executed_code]

Options:
  -e or --erase    erase a mocked command/argument
  -v or --version  print the current mock version
  -h or --help     print this help message

Examples:
  mock git push 1 "echo This command fails with status 1"
  mock git \* 0 "echo This command acts as a fallback to all git commands"
  mock -e git push # git push is back to normal
  mock -e git \* # All git commands are back to normal

Tips:
  - Many mocks can be applied to the same command at the same time with different arguments.
  - Be sure to escape the asterisk symbol when using it as a fallback (\*)
'
end