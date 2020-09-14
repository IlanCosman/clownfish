function mock
    argparse --stop-nonopt 'e/erase' 'h/help' -- $argv
    set -l cmd $argv[1]
    set -l arg $argv[2]
    set -l exitCode $argv[3]
    set -l executedCode $argv[4]

    if set -q _flag_help
        _mock_help
        return 0
    else if set -q _flag_erase
        if test -z "$arg"
            functions --erase (functions --all | string match --regex ^_mock_"$cmd"_.\*)
            functions --erase $cmd
            functions --copy _non_mocked_$cmd $cmd 2>/dev/null # Copy _non_mocked_$cmd -> $cmd if it exists
        else
            functions --erase _mock_"$cmd"_"$arg"
        end
        return 0
    end

    set -l type (type --type $cmd 2>/dev/null) # If $cmd doesn't exist, don't error

    if test "$type" = function && not functions --query _non_mocked_$cmd
        functions --copy $cmd _non_mocked_$cmd
    end

    function _mock_"$cmd"_"$arg" --inherit-variable exitCode --inherit-variable executedCode
        eval $executedCode
        return $exitCode
    end

    function $cmd -a argument --inherit-variable cmd --inherit-variable type
        if functions --query _mock_"$cmd"_"$argument"
            _mock_"$cmd"_"$argument"
        else if functions --query _mock_"$cmd"_\*
            _mock_"$cmd"_\*
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
Usage: mock [options] [command] [argument] [exit code] [executed code]

Options:
  -e or --erase    erase a mocked command/argument
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
'
end