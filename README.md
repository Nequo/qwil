# Qwil

> Ultra-pure, lag-free prompt with async Git status. Designed for [Fish](https://fishshell.com).
> Forked from jorgebucaran/hydro on 20240402

Qwil is my personal copy of hydro. Additional features:

- Show if in a toolbox container.

<pre>
<b>~</b> ⬢ ❱ ⎢
</pre>

[![](https://user-images.githubusercontent.com/56996/103166797-f807ee00-4868-11eb-9818-c661584274c8.gif)](#qwil)

## Installation

Install with [Fisher](https://github.com/jorgebucaran/fisher):

```console
fisher install Nequo/qwil
```

## Features

One prompt symbol to rule them all. [Change it](#configuration)?

<pre>
<b>~</b> ❱ ⎢
</pre>

Display Git branch name and status—prompt repaints asynchronously! ✨

<pre>
~/p/<b>qwil</b> main ❱ touch Solution
~/p/<b>qwil</b> main• ❱ ⎢
</pre>

> `•` indicates that there are staged, unstaged or untracked files.

Display how many commits ahead and/or behind you are of your upstream—prompt repaints asynchronously!

<pre>
~/p/<b>qwil</b> main• ↓2 ❱ git commit -am Hotfix
~/p/<b>qwil</b> main ↑1 ↓2 ❱ git pull --rebase && git push
~/p/<b>qwil</b> main ❱ ⎢
</pre>

Display [`$CMD_DURATION`](https://fishshell.com/docs/current/language.html?highlight=cmd_duration#envvar-CMD_DURATION) when > `1` second. [Configurable](#configuration).

<pre>
~/p/<b>qwil</b> main ❱ git push --quiet
~/p/<b>qwil</b> main 1.1s ❱ ⎢
</pre>

Display the last non-zero [exit status](https://fishshell.com/docs/current/tutorial.html#exit-status) (or statuses) using [`$pipestatus`](https://fishshell.com/docs/current/language.html?highlight=cmd_duration#envvar-pipestatus).

<pre>
~/p/<b>qwil</b> main ❱ false
~/p/<b>qwil</b> main | <b>1</b> ❱ ⎢
~/p/<b>qwil</b> main ❱ true | false | false
~/p/<b>qwil</b> main | <b>0</b> <b>1</b> <b>1</b> ❱ ⎢
</pre>

Truncate [`$PWD`](https://fishshell.com/docs/current/language.html?highlight=cmd_duration#envvar-PWD) segments except for the basename and root of Git repos.

<pre>
<b>~</b> ❱ projects/qwil/
~/p/<b>qwil</b> ❱ functions/share/
~/p/qwil/f/<b>share</b> ❱ ⎢
</pre>

Display the current bindings mode.

<pre>
<i>I</i> <b>~</b> ❱ <kbd>Esc</kbd>
<i>N</i> <b>~</b> ❱ <kbd>R</kbd>
<i>R</i> <b>~</b> ❱ ⎢
</pre>

## Performance

Blazing fast would be an understatement considering that the [LLVM repo](https://github.com/llvm/llvm-project) has over 375,000 commits!

<pre>
~/<b>llvm-project</b> main ❱ time fish_prompt
~/<b>llvm-project</b> main ❱
________________________________________________________
Executed in   79.00 micros    fish           external
   usr time   71.00 micros   71.00 micros    0.00 micros
   sys time    9.00 micros    9.00 micros    0.00 micros
</pre>

## Configuration

Modify variables using `set --universal` from the command line or `set --global` in your `config.fish` file.

### Symbols

| Variable                  | Type   | Description                     | Default |
| ------------------------- | ------ | ------------------------------- | ------- |
| `qwil_symbol_prompt`     | string | Prompt symbol.                  | `❱`     |
| `qwil_symbol_git_dirty`  | string | Dirty repository symbol.        | `•`     |
| `qwil_symbol_git_ahead`  | string | Ahead of your upstream symbol.  | `↑`     |
| `qwil_symbol_git_behind` | string | Behind of your upstream symbol. | `↓`     |

### Colors

> Any argument accepted by [`set_color`](https://fishshell.com/docs/current/cmds/set_color.html).

| Variable               | Type  | Description                    | Default              |
| ---------------------- | ----- | ------------------------------ | -------------------- |
| `qwil_color_pwd`      | color | Color of the pwd segment.      | `$fish_color_normal` |
| `qwil_color_git`      | color | Color of the git segment.      | `$fish_color_normal` |
| `qwil_color_error`    | color | Color of the error segment.    | `$fish_color_error`  |
| `qwil_color_prompt`   | color | Color of the prompt symbol.    | `$fish_color_normal` |
| `qwil_color_duration` | color | Color of the duration section. | `$fish_color_normal` |
| `qwil_color_toolbox`  | color | Color of the toolbox section.  | `cyan`               |

### Flags

| Variable          | Type    | Description                                  | Default |
| ----------------- | ------- | -------------------------------------------- | ------- |
| `qwil_fetch`     | boolean | Fetch git remote in the background.          | `false` |
| `qwil_multiline` | boolean | Display prompt character on a separate line. | `false` |

### Misc

| Variable                       | Type    | Description                                                                                                              | Default |
| ------------------------------ | ------- | ------------------------------------------------------------------------------------------------------------------------ | ------- |
| `fish_prompt_pwd_dir_length`   | numeric | The number of characters to display when path shortening. Set it to `0` to display only the topmost (current) directory. | `1`     |
| `qwil_ignored_git_paths`      | strings | Space separated list of paths where no git info should be displayed.                                                     | `""`    |
| `qwil_cmd_duration_threshold` | numeric | Minimum command duration, in milliseconds, after which command duration is displayed.                                    | `1000`  |

## License

[MIT](LICENSE.md)
