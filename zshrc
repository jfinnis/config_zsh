# completion engine
zstyle :compinstall filename '/home/josh/.zshrc'
autoload -Uz compinit
compinit

# assorted options
setopt no_beep                    # don't be annoying
setopt correct                    # suggest corrections for mispellings
setopt no_multibyte               # allow use of alt/meta keys in shell
setopt no_hup                     # don't quit background jobs on shell close
setopt local_options local_traps  # allow local traps/options in functions
setopt rc_quotes                  # double quoting -> 'a''b''c' = a'b'c
setopt rm_star_silent             # i don't need my hand held

# directory options
setopt autocd                     # if dir entered by itself, cd to it
setopt autoname_dirs              # load named directories automatically
cdpath=(~/working ~/apps .)       # like adding /bin to path except for dirs
source /etc/profile.d/autojump.zsh       # load autojump script

# expansion options
setopt brace_ccl                  # brace expansion for letters
setopt extended_glob              # enable extra globbing features
setopt glob_subst                 # allow glob expansion with $~foo
setopt magic_equal_subst          # expand pattern =~ and =...~ (i.e., paths)
setopt rc_expand_param            # combines with each element of expansion

# history options
HISTFILE=~/.zsh/HISTFILE
HISTSIZE=1000
SAVEHIST=1000
setopt append_history             # don't overwrite history file
setopt extended_history           # save date/runtime of commands in history
setopt hist_ignore_dups           # don't see duplicates when using history
setopt inc_append_history         # add lines to history as they are executed

# prompt options
PS1='%(?..(E%?%))%20<..<%~ %# '   # [error number], truncated dir name

##############################################################################
############################ vim bindings ####################################
##############################################################################
bindkey -v                              # set vim bindigns
bindkey -rpM viins '^['                 # remove delay when hitting escape

# completion bindings
bindkey -M vicmd o infer-next-history   # complete from prefix
bindkey -M viins  infer-next-history
bindkey -M viins  history-beginning-search-backward    # complete based on line
bindkey -M viins  _complete_help      # show completion context for cursor
bindkey -M viins  _correct_word       # correct complete word
bindkey -M viins  _next_tags          # cycle through tags

# editing bindings
bindkey -M vicmd z push-line-or-edit    # edit continuation lines as block
bindkey -M viins  push-line-or-edit
autoload -z edit-command-line; zle -N edit-command-line  # load vim to edit cli
bindkey -M vicmd v edit-command-line
bindkey -M viins "[A" up-line-or-history      # allow up to go up in insert mode
bindkey -M viins "[B" down-line-or-history    # allow up to go up in insert mode

# free cmd keys: F2-F10 F12 K M U V Z g ! @ & * ( ) _ [ ] { } ; , ` = space
# free ins keys: ctrl+ f p

##############################################################################
######################### completion options #################################
##############################################################################
setopt complete_aliases           # expand arguments based on type
setopt complete_in_word           # tab complete in middle of words
setopt list_packed                # compact menu listings for completion

# expand paths of form /a/a/z even if z doesn't exist
zstyle ':completion:*' expand prefix suffix
# don't tabcomplete cdpath directories
zstyle ':completion:*:cd:*' tag-order local-directories path-directories
# don't include parameters in command completion
zstyle ':completion:*:-command-:*' tag-order '!parameters'
# complete all pids for user, filter out some jobs
zstyle ':completion:*:*:kill:*' command "ps -ujosh -o pid,%cpu,cputime,cmd | grep -v usr\/ | grep -v ps\ -ujosh"
# complete user/host for commands like ssh
source ~/.zsh/zsh_comp_user-host-mappings
# complete urls from file
zstyle ':completion:*:urls' urls ~/.zsh/zsh_comp_url-file

# extra formatting to state what type the completions are
zstyle ':completion:*:descriptions' format '%UCompleting %d%u'
# group based on type of commands
zstyle ':completion:*' group-name ''
#doesn't work
zstyle ':completion:*:-command-' group-order builtins functions commands

# figure out this plus previous commands
# ordinary complete, then allow 1 error, then match patterns such as 
# a-b<tab> = apple-banana, then allow 4 error
#zstyle ':completion:*' completer _complete _approximate:-one _complete:-extended _approximate:-four
#zstyle ':completion:*:approximate-one:*' max-errors 1
#zstyle ':completion:*:complete-extended:*' matcher 'r:|[.,_-]=* r:|=*'
#zstyle ':completion:*:approximate-four:*' max-errors 4

##############################################################################
############################### aliases ######################################
##############################################################################
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias mutt='/home/josh/apps/mutt-1.5.20/build/mutt -F /home/josh/.mutt/cfg/muttrc'
alias tmux='tmux -2'

alias colors='for i in {0..255}; do printf "\x1b[38;5;${i}mcolour${i}\n"; done'
alias sz='source ~/.zshrc'
alias to=testoption && compdef _options to testoption

##############################################################################
############################## functions #####################################
##############################################################################
autoload zmv

# show if zsh option is set
testoption() { if [[ -o $1 ]]; then print $1 set; else print $1 unset; fi }

# make man use help as a fallback
man() { /usr/bin/man $@ || (help $@ 2> /dev/null && help $@ | less) }

# right hand prompt displays insert/normal mode
function zle-line-init zle-keymap-select {
    RPS1="${${KEYMAP/vicmd/-- NORMAL --}/(main|viins)/-- INSERT --}"
    RPS2=$RPS1
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

# google command line aliases
gde() { google docs edit --title $1; }
alias gdl='google docs list --delimiter " == " --fields title,url'
gca() { google calendar add \""$*"\"; }
alias gcd='google calendar delete'
alias gct='google calendar today --delimiter " == "'

##############################################################################
######################### environment variables ##############################
##############################################################################
export EDITOR=/usr/local/bin/vim
