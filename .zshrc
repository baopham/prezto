#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...

# GistID: 2957960

# {{{ Prezto settings:
#
# Modules: editor, history, completion, prompt, fasd, git
# Editor keymap: vi
# Theme: bpm (https://gist.github.com/4230860)
#
# }}}

#}}}

#{{{ Title

# Set the terminal title in OS X, stolen from http://tinyurl.com/5u9wfr
case $TERM in (*xterm*|ansi)
  function settab { print -Pn "\e]1;%15<...<%~\a" }
  function settitle { print -Pn "\e]2;%~\a" }
  function chpwd { settab; settitle }
  settab; settitle
  ;;
esac

#}}}

#{{{ Completion

# Completion with color
zstyle ':completion:*:default' menu select yes
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# Fall back to file completion if all else fails
orig_comp="$(zstyle -L ':completion:\*' completer 2>> "/dev/null")"
fasd_comp="_fasd_zsh_word_complete_trigger"
if [ "$orig_comp" ]; then
  case $orig_comp in
    # make sure the fasd completor goes after _files
    *_files*$fasd_comp*);;
    *$fasd_comp*) eval "${${orig_comp}/${fasd_comp}/_files} ${fasd_comp}";;
    *) eval "$orig_comp _files";;
  esac
else
  zstyle ':completion:*' completer _expand _complete _match _approximate _files _correct
fi
unset orig_comp fasd_comp

# Files to ignore during completion
fignore=(DS_Store $fignore)

# <C-F> for file completion
zle -C complete-file menu-expand-or-complete _generic
zstyle ':completion:complete-file:*' completer _files
bindkey -M viins '^F'      complete-file

#}}}

#{{{ Variables

export CLICOLOR=1
export LSCOLORS=gxfxcxdxbxegedabagacad
export LS_COLORS="no=00:fi=00:di=0;36:ln=01;36:pi=40;33:so=0;32:do=01;35:bd=40;33;01:cd=40;33;01: \ 
or=40;31;01:su=37;41:sg=30;43:tw=30;103:ow=30;103:st=37;44:ex=0;31:*.jpg=01;35:*.jpeg=01;35: \ 
*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35: \ 
*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35: \ 
*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.flac=01;35: \ 
*.mp3=01;35:*.mpc=01;35:*.ogg=01;35:*.wav=01;35:"

#}}}

#{{{ Alias

alias ll="ls -lh"
alias la="ls -A"
alias cpu='top -u'
alias sz='source ~/.zshrc'
alias mv="mv -v"
alias grep='grep --colour=always -n'
alias dirs='dirs -v'
alias cleanup='rm "#"* "."*~ *~ *.bak *.dvi *.aux'
alias firefox='open -a /Applications/Firefox.app'
alias excel='open -a /Applications/Microsoft\ Office\ 2011/Microsoft\ Excel.app'
alias word='open -a /Applications/Microsoft\ Office\ 2011/Microsoft\ Word.app'
alias text='open -a /Applications/TextEdit.app'
alias yui='java -jar ~/Projects/yuicompressor-2.4.7.jar'
alias compiler='java -jar ~/Projects/compiler.jar'
alias hide='setfile -a V'
alias show='setfile -a v'
alias drushy='drush -y'
alias apachelog='tail -f /private/var/log/apache2/error_log'
alias clear-logs='sudo rm /var/log/asl/*.asl'
alias git-pre-commit='mv ./.git/hooks/{pre-commit.sample,pre-commit}'

# grc
GRC=`which grc`
if [ "$TERM" != dumb ] && [ -n GRC ] ; then
  unalias grc &> /dev/null
  alias colourify="`which grc` -es --colour=auto"
  alias configure='colourify ./configure'
  alias diff='colourify diff'
  alias make='colourify make'
  alias gcc='colourify gcc'
  alias g++='colourify g++'
  alias as='colourify as'
  alias gas='colourify gas'
  alias ld='colourify ld'
  alias netstat='colourify netstat'
  alias ping='colourify ping'
  alias traceroute='colourify /usr/sbin/traceroute'
fi

#}}}

#{{{ Extra Vim Key binding

# Switch to command mode.
bindkey -M viins 'jk' vi-cmd-mode
bindkey -M viins 'kj' vi-cmd-mode

# Movement
bindkey -M viins '^E'   end-of-line
bindkey -M viins '^A'   vi-beginning-of-line
bindkey -M vicmd '^E'   end-of-line
bindkey -M vicmd '^A'   vi-beginning-of-line
bindkey "\e[1;5C"       forward-word            # Ctrl + right arrow
bindkey "\e[1;5D"       backward-word           # Ctrl + left arrow

# Kill line
bindkey -M viins '^K'   kill-line
bindkey -M viins '^U'   backward-kill-line
bindkey -M vicmd '^K'   kill-line
bindkey -M vicmd '^U'   backward-kill-line

# History
# Search based on what you typed in already
bindkey -M vicmd "//"   history-beginning-search-forward
bindkey -M vicmd "??"   history-beginning-search-backward

# Backspace
bindkey -M viins '^W'   backward-kill-word

# Unbind <C-[>
bindkey '^['            self-insert

#}}}

#{{{ Functions

function batch-rename {
  if [ $# -eq 0 ] ; then
    echo 'batch-rename *regex-files* new-basename'
  else
    args=($*)
    files=($args[1,-2])
    basename=$args[-1]
    count=1
    for file in $files; do
      filename=$(basename "$file")
      ext="${filename##*.}"
      mv -v ${file} ${basename}-${count}.${ext}
      ((count=$count+1))
    done
    unset count args files basename filename ext
  fi
}

function nametab {
  echo -ne "\033]0;"$@"\007"
}

function proj-ctags {
  # Check if the current directory is a git repo
  if git rev-parse --git-dir > /dev/null 2>&1; then
    dir="$(git rev-parse --show-toplevel)/.git"
  else
    dir="$(pwd)"
  fi
  if [ $# -eq 0 ] ; then
    ctags -f ${dir}/.tags
  else
    args=($*) 
    for arg in $args; do
      ctags --languages=${arg} -f ${dir}/${arg}.tags
    done
  fi
}

#}}}

#{{{ Options

setopt AUTO_CD

setopt CORRECT

#}}}

#{{{ fasd

# Alias
alias v='fasd -fe vim' # quick opening files with vim
alias m='fasd -fe mvim' # quick opening files with macvim
alias o='fasd -ae open' # quick opening files with open

#}}}
