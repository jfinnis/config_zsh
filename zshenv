typeset -U path
path=($path)

# setup function loading
fpath=( ~/.config/zsh/completion ~/.config/zsh/functions_src ~/.config/zsh/functions $fpath )
autoload ~/.config/zsh/functions/*
autoload ~/.config/zsh/functions_src/*
source ~/.config/zsh/functions_src/*

