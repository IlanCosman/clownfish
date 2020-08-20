function mock -a cmd arg exit_code executed_code
    set -l type (type --type $cmd)

    if test "$type" = function && not functions --query _non_mocked_$cmd
        functions --copy $cmd _non_mocked_$cmd
    end

    function $cmd'_'$arg -V exit_code -V executed_code
        eval $executed_code
        return $exit_code
    end

    function $cmd -a argument -V cmd -V type
        if functions --query $cmd'_'\*
            $cmd'_'\*
        else if functions --query $cmd'_'$argument
            $cmd'_'$argument
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
    echo '
Usage: mock [command] [argument] [exit code] [executed_code]

Examples
    $ mock git pull 0 "echo This command sucessfully echoes"
    $ mock git push 1 "echo This command fails with status 1"
    $ mock git \* 0 "echo This command overrides all git commands"

Tips
    - Many mocks can be applied to the same command at the same time with different arguments.
    - Be sure to escape the asterisk symbol when using it as a fallback (\*)
'
end