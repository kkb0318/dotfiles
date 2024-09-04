if status is-interactive
    # Commands to run in interactive sessions can go here
end


# define XDG paths
set -q XDG_CONFIG_HOME || set -gx XDG_CONFIG_HOME $HOME/.config
set -q XDG_DATA_HOME || set -gx XDG_DATA_HOME $HOME/.local/share
set -q XDG_CACHE_HOME || set -gx XDG_CACHE_HOME $HOME/.cache



set -gx VOLTA_HOME "$HOME/.volta"
fish_add_path "$VOLTA_HOME/bin"
fish_add_path $HOME/.config/yarn/global/node_modules/.bin
fish_add_path $HOME/go/bin
fish_add_path /opt/homebrew/bin

# set --universal nvm_default_version v18.7.0

# tmux color. install https://gist.github.com/bbqtd/a4ac060d6f6b9ea6fe3aabe735aa9d95
export TERM="tmux-256color"

export RIPGREP_CONFIG_PATH="$HOME/.config/.ripgreprc"

# import custom config in conf.d/
for file in ~/.config/fish/conf.d/custom/*.fish
    source $file
end

abbr -a tree 'tree -a -I "\.DS_Store|\.git|node_modules|vendor\/bundle" -N'

abbr -a dsstore "find . -name '.DS_Store' -type f -ls -delete"

abbr -a g 'git'
abbr -a gs 'git stash'
abbr -a nv 'nvim'

export GOPATH="$HOME/go"

# for kubernetes
abbr -a k 'kubectl'
abbr -a kg 'kubectl get'
abbr -a kd 'kubectl describe'
abbr -a ka 'kubectl apply'
## kubernetes krew setting
fish_add_path $HOME/.krew/bin
