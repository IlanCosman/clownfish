function mock
    argparse --stop-nonopt e/erase h/help -- $argv
    set -l cmd $argv[1]
    set -l arg $argv[2]
    set -l executedCode $argv[3]

    if set -q _flag_help
        _mock_help
    else if set -q _flag_erase
        if test -z "$arg"
            functions --erase (functions --all | string match --regex '^_mock_'$cmd'_.*')
            functions --erase $cmd
            functions --copy _non_mocked_$cmd $cmd 2>/dev/null # Copy _non_mocked_$cmd -> $cmd if it exists
        else
            functions --erase _mock_"$cmd"_"$arg"
        end
    else
        set -l type (type --type $cmd 2>/dev/null) # If $cmd doesn't exist, don't error

        # If $cmd isn't a function, or if _non_mocked_$cmd is already defined, don't error
        functions --copy $cmd _non_mocked_$cmd 2>/dev/null

        function _mock_"$cmd"_"$arg" --inherit-variable arg --inherit-variable executedCode
            set -l argv (string replace -- "$arg " '' "$argv")

            eval $executedCode
        end

        function $cmd --inherit-variable cmd --inherit-variable type
            # This is looking from most-specific to least specific mock
            # For example, if we have mocked "foo bar" AND "foo bar baz",
            # if we run "foo bar baz" then it will run that mock, 
            # as opposed to the more general "foo bar"
            set -l i (count $argv)
            while test $i -gt 0
                set -l argument "$argv[1..$i]"
                if functions --query _mock_"$cmd"_"$argument"
                    _mock_"$cmd"_"$argument" $argv
                    return
                end
                set i (math $i-1)
            end

            if functions --query _mock_"$cmd"_\*
                _mock_"$cmd"_\* $argv
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
end

function _mock_help
    printf '%s' '
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
'
end
