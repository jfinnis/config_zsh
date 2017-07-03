############################ zsh options ##################################{{{
##############################################################################
# assorted options
setopt no_beep                    # don't be annoying
setopt correct                    # suggest corrections for mispellings
setopt no_multibyte               # allow use of alt/meta keys in shell
setopt no_hup                     # don't quit background jobs on shell close
setopt local_options local_traps  # allow local traps/options in functions
setopt rc_quotes                  # double quoting -> 'a''b''c' = a'b'c
setopt rm_star_silent             # i don't need my hand held
setopt transient_rprompt          # remove rprompt when cut/paste

# directory options
setopt autocd                     # if dir entered by itself, cd to it
setopt autoname_dirs              # load named directories automatically
source ~/.zsh/cdpaths             # since cdpath is local to machine

#fpath=( ~/.zsh/completion ~/.zsh/functions "${fpath[@]}" )
#for file in `ls ~/.zsh/functions`; do
    #autoload ~/.zsh/functions/$file
#done

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

###########################################################################}}}
########################## prompt settings ################################{{{
##############################################################################
# setup colors
autoload colors && colors
for COLOR in RED GREEN YELLOW BLUE MAGENTA CYAN BLACK WHITE; do
    eval $COLOR='%{$fg_no_bold[${(L)COLOR}]%}'
    eval BOLD_$COLOR='%{$fg_bold[${(L)COLOR}]%}'
done
PS1="${CYAN}:${BOLD_CYAN}I${CYAN}: %#${WHITE} "
RPS1="${GREEN}%~ ${RED}%(?..^E%?^)${WHITE}"
RPS2=$RPS1

# update insert/normal display on keypress
function zle-line-init zle-keymap-select {
    PS1="${CYAN}:${BOLD_CYAN}${${KEYMAP/vicmd/N}/(main|viins)/I}${CYAN}: %#${WHITE} "
    PS2="${CYAN}:${BOLD_CYAN}${${KEYMAP/vicmd/N}/(main|viins)/I}${CYAN}: %_>${WHITE} "
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

###########################################################################}}}
############################ vim bindings #################################{{{
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
bindkey -M vicmd V edit-command-line
bindkey -M viins "[A" up-line-or-history      # allow up to go up in insert mode
bindkey -M viins "[B" down-line-or-history    # allow up to go up in insert mode
#bindkey -M viins  insert-last-command-output
autoload -U insert-files; zle -N insert-files   # fuzzy file finder
bindkey -M viins  insert-files
#bindkey '^x1' jump_after_first_word
#bindkey '^Xt' tmux-pane-words-prefix
#bindkey '^X^X' tmux-pane-words-anywhere

# extra vim mappings
bindkey -M vicmd di delete-in
bindkey -M vicmd da delete-around
bindkey -M vicmd ci change-in
bindkey -M vicmd ca change-around
bindkey -M vicmd  increment-number
bindkey -M vicmd  decrement-number
bindkey -M vicmd ga what-cursor-position
bindkey -M vicmd g~ vi-oper-swap-case

# free cmd keys: F2-F10 F12 K M U V Z g ! @ & * ( ) _ [ ] { } ; , ` = space
# free ins keys: ctrl+ p

# unbound: redisplay
# to bind: magic/transpose
###########################################################################}}}
############################## colorings ##################################{{{
##############################################################################
# enable syntax highlighting
source ~/.zsh/submodules/syntax-highlighting/zsh-syntax-highlighting.zsh

# less colors for man pages
export LESS_TERMCAP_mb=$'\E[01;31m'             # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'        # begin bold
export LESS_TERMCAP_me=$'\E[0m'                 # end mode
export LESS_TERMCAP_so=$'\E[38;33;46m'          # begin standout-mode - infobox
export LESS_TERMCAP_se=$'\E[0m'                 # end standout-mode
export LESS_TERMCAP_us=$'\E[04;38;5;146m'       # begin underline
export LESS_TERMCAP_ue=$'\E[0m'                 # end underline

# for colored ls
export LS_COLORS='rs=0:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:'

###########################################################################}}}
############################### aliases ###################################{{{
##############################################################################
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'

# better options for common programs
alias df='df -h'
alias du='du -h'
alias grep='grep --color=auto'
alias la='ls -aF --color=auto --group-directories-first'
alias ls='ls -F --color=auto --group-directories-first'
alias mutt='/home/josh/apps/mutt-1.5.20/build/mutt -F /home/josh/.mutt/cfg/muttrc'
alias tmux='tmux -2'
alias zmv='noglob zmv -W'

# useful aliases
alias ai='sudo apt-get install'
alias cs='for i in {0..255}; do printf "\x1b[38;5;${i}mcolour${i}\n"; done'
alias cdm='mkdir_and_cd'
alias ex=extract_archive && compdef '_files -g "*.gz *.tgz *.bz2 *.tbz *.zip *.rar *.tar *.lha"' extract_archive
alias ll='ls -F -lh --group-directories-first'
alias lla='ls -F -alh --group-directories-first'
alias ls1='ls -1 --group-directories-first'
alias lsdir="for dir in *;do;if [ -d \$dir ];then;du -hsL \$dir 2>/dev/null;fi;done"
alias su='smart_sudo && compdef _sudo smart_sudo'
alias sz='source ~/.zshrc'
alias to='testoption && compdef _options to testoption'

# global aliases can occur anywhere in command line
alias -g G='| grep'
alias -g H='--help'
alias -g HD='| head'
alias -g L="| less"
alias -g S='| sort'
alias -g TL='| tail'
alias -g W='| wc -l'
alias -g X='| xargs'
alias -g C='| column'

# suffix aliases run command when file with suffix is entered on command line
alias -s pdf='evince'
alias -s gif='eog'
alias -s jpg='eog'
alias -s png='eog'

###########################################################################}}}
############################## functions ##################################{{{
##############################################################################
# fast mkdir && cd
mkdir_and_cd() {
    mkdir $1 && cd $1
}

# determine what to do with files based on mime-type defined in ~/.mailcap
autoload -U zsh-mime-setup && zsh-mime-setup

# enable some other useful functions
autoload -U zmv zargs zrecompile

# display top 10 used lines
top10() {
    fc -l 1 | awk '{print $2}' | sort | uniq -c | sort -rn | head
}

# complete Words that appear in the current tmux pane
_tmux_pane_words() {
  local expl
  local -a w
  if [[ -z "$TMUX_PANE" ]]; then
    _message "not running inside tmux!"
    return 1
  fi
  w=( ${(u)=$(tmux capture-pane \; show-buffer \; delete-buffer)} )
  _wanted values expl 'words from current tmux pane' compadd -a w
}
zle -C tmux-pane-words-prefix complete-word _generic
zle -C tmux-pane-words-anywhere complete-word _generic

# show if zsh option is set
testoption() { if [[ -o $1 ]]; then print $1 set; else print $1 unset; fi }

# make man use help as a fallback
man() { /usr/bin/man $@ || (help $@ 2> /dev/null && help $@ | less) }

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
alias su='smart_sudo && compdef _sudo smart_sudo'

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

###########################################################################}}}
######################### environment variables ###########################{{{
##############################################################################
export EDITOR=vim
export SHELL=/bin/zsh
export TERM=screen-256color

export CONKYDIR=~/.conky

source ~/.zsh/local.zsh

###########################################################################}}}
######################### completion options ##############################{{{
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
zstyle ':completion:*' completer _complete _complete:-extended
#zstyle -e ':completion:*:approximate-one:*' max-errors 'reply=1'
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
#source ~/.zsh/zsh_comp_user-host-mappings  # complete user/host for commands like ssh
zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

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

# }}}
# vim:fdm=marker
