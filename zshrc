############################ zsh options #####################################
##############################################################################
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

# Shift-tab Perform backwards menu completion
if [[ -n "$terminfo[kcbt]" ]]; then
    bindkey "$terminfo[kcbt]" reverse-menu-complete
elif [[ -n "$terminfo[cbt]" ]]; then # required for GNU screen
    bindkey "$terminfo[cbt]" reverse-menu-complete
fi

# history bindings
bindkey -M vicmd o infer-next-history   # complete from prefix
bindkey -M viins  infer-next-history
bindkey -M viins  history-beginning-search-backward    # complete based on line
bindkey -M viins  history-incremental-search-backward  # standard ctrl-r behavior
bindkey -M vicmd  history-incremental-search-backward

# completion bindings
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

# display environment vars based on prefix
ev() { echo
       set | egrep -i \^$1 |sed -e 's/=/     /' -e '/^PATH/d' -e '/^CDPATH/d' | sort
       echo }

# easier sudo function, with no argument, drops to root shell
smart_sudo () {
    if [[ -n $1 ]]; then
        #test if the first parameter is a alias
        if [[ -n $aliases[$1] ]]; then
            #if so, substitute the real command
            sudo ${=aliases[$1]} $argv[2,-1]
        else
            #else just run sudo as is
            sudo $argv
        fi
    else
        #if no parameters were given, then assume we want a root shell
        sudo -s
    fi
}

# access to output of last command
zmodload -i zsh/parameter
insert-last-command-output() {
    LBUFFER+="$(eval $history[$((HISTCMD-1))])"
}
zle -N insert-last-command-output

# easy extract all function
extract_archive () {
    local old_dirs current_dirs lower
    lower=${(L)1}
    old_dirs=( *(N/) )
    if [[ $lower == *.tar.gz || $lower == *.tgz ]]; then
        tar zxfv $1
    elif [[ $lower == *.gz ]]; then
        gunzip $1
    elif [[ $lower == *.tar.bz2 || $lower == *.tbz ]]; then
        bunzip2 -c $1 | tar xfv -
    elif [[ $lower == *.bz2 ]]; then
        bunzip2 $1
    elif [[ $lower == *.zip ]]; then
        unzip $1
    elif [[ $lower == *.rar ]]; then
        unrar e $1
    elif [[ $lower == *.tar ]]; then
        tar xfv $1
    elif [[ $lower == *.lha ]]; then
        lha e $1
    else
        print "Unknown archive type: $1"
        return 1
    fi
    # Change in to the newly created directory, and
    # list the directory contents, if there is one.
    current_dirs=( *(N/) )
    for i in {1..${#current_dirs}}; do
        if [[ $current_dirs[$i] != $old_dirs[$i] ]]; then
            cd $current_dirs[$i]
            ls
            break
        fi
    done
}

# add i/a text objects
delete-in() {
    local CHAR LCHAR RCHAR LSEARCH RSEARCH COUNT
    read -k CHAR
    if [[ $CHAR == "w" ]];then
        zle vi-backward-word
        LSEARCH=$CURSOR
        zle vi-forward-word
        RSEARCH=$CURSOR
        RBUFFER="$BUFFER[$RSEARCH+1,${#BUFFER}]"
        LBUFFER="$LBUFFER[1,$LSEARCH]"
        return
    elif [[ $CHAR == "(" ]] || [[ $CHAR == ")" ]];then
        LCHAR="("
        RCHAR=")"
    elif [[ $CHAR == "[" ]] || [[ $CHAR == "]" ]];then
        LCHAR="["
        RCHAR="]"
    elif [[ $CHAR == "{" ]] || [[ $CHAR == "}" ]];then
        LCHAR="{"
        RCHAR="}"
    else
        LSEARCH=${#LBUFFER}
        while [[ $LSEARCH -gt 0 ]] && [[ "$LBUFFER[$LSEARCH]" != "$CHAR" ]]; do
            (( LSEARCH = $LSEARCH - 1 ))
        done
        RSEARCH=0
        while [[ $RSEARCH -lt (( ${#RBUFFER} + 1 )) ]] && [[ "$RBUFFER[$RSEARCH]" != "$CHAR" ]]; do
            (( RSEARCH = $RSEARCH + 1 ))
        done
        RBUFFER="$RBUFFER[$RSEARCH,${#RBUFFER}]"
        LBUFFER="$LBUFFER[1,$LSEARCH]"
        return
    fi
    COUNT=1
    LSEARCH=${#LBUFFER}
    while [[ $LSEARCH -gt 0 ]] && [[ $COUNT -gt 0 ]]; do
        (( LSEARCH = $LSEARCH - 1 ))
        if [[ $LBUFFER[$LSEARCH] == "$RCHAR" ]];then
            (( COUNT = $COUNT + 1 ))
        fi
        if [[ $LBUFFER[$LSEARCH] == "$LCHAR" ]];then
            (( COUNT = $COUNT - 1 ))
        fi
    done
    COUNT=1
    RSEARCH=0
    while [[ $RSEARCH -lt (( ${#RBUFFER} + 1 )) ]] && [[ $COUNT -gt 0 ]]; do
        (( RSEARCH = $RSEARCH + 1 ))
        if [[ $RBUFFER[$RSEARCH] == "$LCHAR" ]];then
            (( COUNT = $COUNT + 1 ))
        fi
        if [[ $RBUFFER[$RSEARCH] == "$RCHAR" ]];then
            (( COUNT = $COUNT - 1 ))
        fi
    done
    RBUFFER="$RBUFFER[$RSEARCH,${#RBUFFER}]"
    LBUFFER="$LBUFFER[1,$LSEARCH]"
}
zle -N delete-in

change-in() {
    zle delete-in
    zle vi-insert
}
zle -N change-in

delete-around() {
    zle delete-in
    zle vi-backward-char
    zle vi-delete-char
    zle vi-delete-char
}
zle -N delete-around

change-around() {
    zle delete-in
    zle vi-backward-char
    zle vi-delete-char
    zle vi-delete-char
    zle vi-insert
}
zle -N change-around

# increment-number
increment-number() {
    emulate -L zsh
    setopt extendedglob
    local pos num newnum sign buf
    if [[ $BUFFER[$((CURSOR + 1))] = [0-9] ]]; then
        pos=$((${#LBUFFER%%[0-9]##} + 1))
    else
        pos=$(($CURSOR + ${#RBUFFER%%[0-9]*} + 1))
    fi
    (($pos <= ${#BUFFER})) || return
    num=${${BUFFER[$pos,-1]}%%[^0-9]*}
    if ((pos > 0)) && [[ $BUFFER[$((pos - 1))] = '-' ]]; then
        num=$((0 - num))
        ((pos--))
    fi
    newnum=$((num + ${NUMERIC:-${incarg:-1}}))
    if ((pos > 1)); then
        buf=${BUFFER[0,$((pos - 1))]}${BUFFER[$pos,-1]/$num/$newnum}
    else
        buf=${BUFFER/$num/$newnum}
    fi
    BUFFER=$buf
    CURSOR=$((pos + $#newnum - 2))
}
zle -N increment-number

# decrement-number
decrement-number() {
    emulate -L zsh
    setopt extendedglob
    local pos num newnum sign buf
    if [[ $BUFFER[$((CURSOR + 1))] = [0-9] ]]; then
        pos=$((${#LBUFFER%%[0-9]##} + 1))
    else
        pos=$(($CURSOR + ${#RBUFFER%%[0-9]*} + 1))
    fi
    (($pos <= ${#BUFFER})) || return
    num=${${BUFFER[$pos,-1]}%%[^0-9]*}
    if ((pos > 0)) && [[ $BUFFER[$((pos - 1))] = '-' ]]; then
        num=$((0 - num))
        ((pos--))
    fi
    newnum=$((num - ${NUMERIC:-${incarg:-1}}))
    if ((pos > 1)); then
        buf=${BUFFER[0,$((pos - 1))]}${BUFFER[$pos,-1]/$num/$newnum}
    else
        buf=${BUFFER/$num/$newnum}
    fi
    BUFFER=$buf
    CURSOR=$((pos + $#newnum - 2))
}
zle -N decrement-number

# search for various types or README file in dir and display them with less
readme ()
{
	local files
	files=(./(#i)*(read*me|lue*m(in|)ut)*(ND))
	if (($#files))
	then less $files
	else
	print 'No README files.'
	fi
}

# utility functions for user-defined functions transpose/magic word
_my_extended_wordchars='*?_-.[]~=&;!#$%^(){}<>:@,\\'
_my_extended_wordchars_space="${_my_extended_wordchars} "
_my_extended_wordchars_slash="${_my_extended_wordchars}/"
# is the current position \-quoted ?
is_backslash_quoted () {
    test "${BUFFER[$CURSOR-1,CURSOR-1]}" = "\\"
}
unquote-forward-word () {
    while is_backslash_quoted
      do zle .forward-word
    done
}
unquote-backward-word () {
    while is_backslash_quoted
      do zle .backward-word
    done
}
backward-to-space () {
    local WORDCHARS="${_my_extended_wordchars_slash}"
    zle .backward-word
    unquote-backward-word
}
forward-to-space () {
     local WORDCHARS="${_my_extended_wordchars_slash}"
     zle .forward-word
     unquote-forward-word
}
backward-to-/ () {
    local WORDCHARS="${_my_extended_wordchars}"
    zle .backward-word
    unquote-backward-word
}
forward-to-/ () {
     local WORDCHARS="${_my_extended_wordchars}"
     zle .forward-word
     unquote-forward-word
}
# Create new user-defined widgets pointing to eponymous functions.
zle -N backward-to-space
zle -N forward-to-space
zle -N backward-to-/
zle -N forward-to-/
kill-big-word () {
    local WORDCHARS="${_my_extended_wordchars_slash}"
    zle .kill-word
}
zle -N kill-big-word
zle -N transpose-big-words
zle -N magic-forward-char
zle -N magic-forward-word

# google command line aliases
gde() { google docs edit --title $1; }
alias gdl='google docs list --delimiter " == " --fields title,url'
gca() { google calendar add "$*"; }
alias gcd='google calendar delete'
alias gct='google calendar today --delimiter " == "'

##############################################################################
######################### environment variables ##############################
##############################################################################
export EDITOR=vim
export SHELL=/bin/zsh
export TERM=screen-256color

export CONKYDIR=~/.conky

##############################################################################
######################### completion options #################################
##############################################################################
setopt complete_aliases           # expand arguments based on type
setopt complete_in_word           # tab complete in middle of words
setopt list_packed                # compact menu listings for completion

# enable completion and specify cache
zstyle :compinstall filename '/home/josh/.zshrc'
if [[ ! -d ~/.zsh/cache ]]; then
    mkdir -p ~/.zsh/cache
fi
autoload -Uz compinit && compinit -d ~/.zsh/cache/zcompdump
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache/cache

# completers
zstyle ':completion:*' completer _complete _approximate:-one _complete:-extended
zstyle -e ':completion:*:approximate-one:*' max-errors 'reply=1'
zstyle ':completion:*:complete-extended:*' matcher 'r:|[.,_-]=* r:|=*'  # expand a-b<tab> => apple-banana, e.g.

# would be useful if 1/3 applied after /
#zstyle ':completion:*' completer _complete _approximate:-fraction _complete:-extended
#zstyle -e ':completion:*:approximate-fraction:*' max-errors 'reply=( $(( ($#PREFIX + $#SUFFIX) / 3 )) )'  # 1/3 errors allowed

# general options
zstyle ':completion:*' expand prefix suffix  # expand /a/a/z even if no z
zstyle ':completion:*' menu select  # tab cycles through completion options
zstyle ':completion:*:-command-:*' tag-order '!parameters'  # don't include parameters in command completion
zstyle ':completion:*:default' list-prompt '%S%M matches%s'  # completion of options auto-expanded
zstyle ':completion::(^approximate*):*:functions' ignored-patterns '_*'  # ignore completion functions for commands you don't have
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters  # prefer indexes for subscripts

# command specific completion
zstyle ':completion:*:cd:*' tag-order local-directories path-directories   # don't tabcomplete cdpath directories
zstyle ':completion:*:*:evince:*' file-patterns '(#i)*.(pdf|ps) *(-/):directories'
zstyle ':completion:*:*:kill:*' command "ps -ujosh -o pid,%cpu,cputime,cmd | grep -v lib\/ | grep -v ps\ -ujosh"  # complete all pids for user, filter out some jobs
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:processes-names' command 'ps c -u ${USER} -o command | uniq'  # list more processes for commands like killall
zstyle ':completion:*:man:*' menu yes select  # into menu right away
zstyle ':completion:*:manuals' separate-sections true  # separate into sections listings from man
zstyle ':completion:*:manuals.(^1*)' insert-sections true  # dunno
zstyle ':completion:*:rm:*' ignore-line yes  # don't allow repeat parameters
zstyle ':completion:tmux-pane-words-(prefix|anywhere):*' completer _tmux_pane_words
zstyle ':completion:tmux-pane-words-(prefix|anywhere):*' ignore-line current
zstyle ':completion:tmux-pane-words-anywhere:*' matcher-list 'b:=* m:{A-Za-z}={a-zA-Z}'
zstyle ':completion:*:urls' urls ~/.zsh/zsh_comp_url-file  # complete urls from file
zstyle ':completion:*:*:*:users' ignored-patterns adm amanda apache avahi \
    avahi-autoipd backup beaglidx bin cacti canna clamav couchdb daemon \
    dbus distcache dovecot fax ftp games gdm gkrellmd gnats gopher hacluster \
    haldaemon halt hplip hsqldb ident irc junkbust kernoops ldap libuuid \
    list lp mail mailman mailnull man messagebus mldonkey mysql nagios named \
    netdump news nfsnobody nobody nscd ntp nut nx openvpn operator pcap \
    postfix postgres privoxy proxy pulse pvm quagga radvd rpc rpcuser \
    rpm rtkit saned shutdown speech-dispatcher squid sshd sync sys syslog \
    usbmux uucp vcsa www-data xfs 
zstyle ':completion:*:*:vi*:*' ignored-patterns '*.(o|class|pyc)'
source ~/.zsh/zsh_comp_user-host-mappings  # complete user/host for commands like ssh

# formatting display
zstyle ':completion:*' group-name ''  # group based on type of commands
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*:corrections' format "%U%B%d%b - %e error(s)%u"  # formatting strings
zstyle ':completion:*:descriptions' format '%UCompleting %B%d%b%u'  # formatting strings
#zstyle ':completion:*:-command-' group-order builtins functions commands  #doesn't work, alias

# figure out colors
#zstyle ':completion:*:messages' format $'%{\e[0;31m%}%d%{\e[0m%}'
#zstyle ':completion:*:warnings' format $'%{\e[0;31m%}No matches for: %d%{\e[0m%}'

# speedup git completion (disabled until necessary)
#__git_files () {
#    _wanted files expl ‘local files’ _files
#}

