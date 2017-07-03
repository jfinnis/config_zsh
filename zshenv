typeset -U path
path=($path)

# setup function loading
fpath=( ~/.zsh/completion ~/.zsh/functions_src ~/.zsh/functions $fpath )
autoload ~/.zsh/functions/*
autoload ~/.zsh/functions_src/*
source ~/.zsh/functions_src/*

