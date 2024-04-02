status is-interactive || exit

set --global _qwil_git _qwil_git_$fish_pid
set --global _qwil_toolbox _qwil_toolbox$fish_pid

function $_qwil_git --on-variable $_qwil_git --on-variable $_qwil_toolbox
    commandline --function repaint
end

# https://github.com/IlanCosman/tide/commit/38466cf6a110fe9ff66ec0d98385382639d0a3d3
function qwil_toolbox
    if test -e /run/.toolboxenv
        set --global _qwil_toolbox "⬢ "
    else
        set --global _qwil_toolbox ""
    end
end && qwil_toolbox


function _qwil_pwd --on-variable PWD --on-variable qwil_ignored_git_paths --on-variable fish_prompt_pwd_dir_length
    set --local git_root (command git --no-optional-locks rev-parse --show-toplevel 2>/dev/null)
    set --local git_base (string replace --all --regex -- "^.*/" "" "$git_root")
    set --local path_sep /

    test "$fish_prompt_pwd_dir_length" = 0 && set path_sep

    if set --query git_root[1] && ! contains -- $git_root $qwil_ignored_git_paths
        set --erase _qwil_skip_git_prompt
    else
        set --global _qwil_skip_git_prompt
    end

    set --global _qwil_pwd (
        string replace --ignore-case -- ~ \~ $PWD |
        string replace -- "/$git_base/" /:/ |
        string replace --regex --all -- "(\.?[^/]{"(
            string replace --regex --all -- '^$' 1 "$fish_prompt_pwd_dir_length"
        )"})[^/]*/" "\$1$path_sep" |
        string replace -- : "$git_base" |
        string replace --regex -- '([^/]+)$' "\x1b[1m\$1\x1b[22m" |
        string replace --regex --all -- '(?!^/$)/|^$' "\x1b[2m/\x1b[22m"
    )
end

function _qwil_postexec --on-event fish_postexec
    set --local last_status $pipestatus
    set --global _qwil_status "$_qwil_newline$_qwil_color_prompt$qwil_symbol_prompt"

    for code in $last_status
        if test $code -ne 0
            set --global _qwil_status "$_qwil_color_error| "(echo $last_status)" $_qwil_newline$_qwil_color_prompt$_qwil_color_error$qwil_symbol_prompt"
            break
        end
    end

    test "$CMD_DURATION" -lt $qwil_cmd_duration_threshold && set _qwil_cmd_duration && return

    set --local secs (math --scale=1 $CMD_DURATION/1000 % 60)
    set --local mins (math --scale=0 $CMD_DURATION/60000 % 60)
    set --local hours (math --scale=0 $CMD_DURATION/3600000)

    set --local out

    test $hours -gt 0 && set --local --append out $hours"h"
    test $mins -gt 0 && set --local --append out $mins"m"
    test $secs -gt 0 && set --local --append out $secs"s"

    set --global _qwil_cmd_duration "$out "
end

function _qwil_prompt --on-event fish_prompt
    set --query _qwil_status || set --global _qwil_status "$_qwil_newline$_qwil_color_prompt$qwil_symbol_prompt"
    set --query _qwil_pwd || _qwil_pwd

    command kill $_qwil_last_pid 2>/dev/null

    set --query _qwil_skip_git_prompt && set $_qwil_git && return

    fish --private --command "
        set branch (
            command git symbolic-ref --short HEAD 2>/dev/null ||
            command git describe --tags --exact-match HEAD 2>/dev/null ||
            command git rev-parse --short HEAD 2>/dev/null |
                string replace --regex -- '(.+)' '@\$1'
        )

        test -z \"\$$_qwil_git\" && set --universal $_qwil_git \"\$branch \"

        ! command git diff-index --quiet HEAD 2>/dev/null ||
            count (command git ls-files --others --exclude-standard) >/dev/null && set info \"$qwil_symbol_git_dirty\"

        for fetch in $qwil_fetch false
            command git rev-list --count --left-right @{upstream}...@ 2>/dev/null |
                read behind ahead

            switch \"\$behind \$ahead\"
                case \" \" \"0 0\"
                case \"0 *\"
                    set upstream \" $qwil_symbol_git_ahead\$ahead\"
                case \"* 0\"
                    set upstream \" $qwil_symbol_git_behind\$behind\"
                case \*
                    set upstream \" $qwil_symbol_git_ahead\$ahead $qwil_symbol_git_behind\$behind\"
            end

            set --universal $_qwil_git \"\$branch\$info\$upstream \"

            test \$fetch = true && command git fetch --no-tags 2>/dev/null
        end
    " &

    set --global _qwil_last_pid $last_pid
end

function _qwil_fish_exit --on-event fish_exit
    set --erase $_qwil_git
end

function _qwil_uninstall --on-event qwil_uninstall
    set --names |
        string replace --filter --regex -- "^(_?qwil_)" "set --erase \$1" |
        source
    functions --erase (functions --all | string match --entire --regex "^_?qwil_")
end

set --global qwil_color_normal (set_color normal)

for color in qwil_color_{pwd,git,error,prompt,duration,toolbox}
    function $color --on-variable $color --inherit-variable color
        set --query $color && set --global _$color (set_color $$color)
    end && $color
end

function qwil_multiline --on-variable qwil_multiline
    if test "$qwil_multiline" = true
        set --global _qwil_newline "\n"
    else
        set --global _qwil_newline ""
    end
end && qwil_multiline

set --query qwil_color_error || set --global qwil_color_error $fish_color_error
set --query qwil_color_toolbox || set --global qwil_color_toolbox cyan
set --query qwil_symbol_prompt || set --global qwil_symbol_prompt ❱
set --query qwil_symbol_git_dirty || set --global qwil_symbol_git_dirty •
set --query qwil_symbol_git_ahead || set --global qwil_symbol_git_ahead ↑
set --query qwil_symbol_git_behind || set --global qwil_symbol_git_behind ↓
set --query qwil_multiline || set --global qwil_multiline false
set --query qwil_cmd_duration_threshold || set --global qwil_cmd_duration_threshold 1000
