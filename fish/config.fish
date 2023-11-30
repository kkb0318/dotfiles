if status is-interactive
    # Commands to run in interactive sessions can go here
end

# set --universal nvm_default_version v18.7.0

set -x PATH $PATH $HOME/.config/yarn/global/node_modules/.bin

set -x PATH $PATH $HOME/go/bin

abbr -a tree 'tree -a -I "\.DS_Store|\.git|node_modules|vendor\/bundle" -N'
set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH

# tmux color. install https://gist.github.com/bbqtd/a4ac060d6f6b9ea6fe3aabe735aa9d95
export TERM="tmux-256color"

export RIPGREP_CONFIG_PATH="$HOME/.config/.ripgreprc"

# import custom config in conf.d/
for file in ~/.config/fish/conf.d/custom/*.fish
    source $file
end

