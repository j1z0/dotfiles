export EDITOR="vim"
bindkey -v

#vi style incremental search
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
bindkey '^P' history-search-backward
bindkey '^N' histroy-search-forward

#cd <dirname> without the cd
setopt AUTO_CD

# Path to your oh-my-zsh configuration.
ZSH=$HOME/dotfiles/oh-my-zsh

#Settings for virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs

export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--no-site-packages'
export PIP_VIRTUALENV_BASE=$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=true
if [[ -r /usr/local/bin/virtualenvwrapper.sh ]]; then
	    source /usr/local/bin/virtualenvwrapper.sh
    else
	        echo "WARNING: Can't find virtualenvwrapper.sh"
	fi

#selenium stuff
export SELENIUM_SERVER_JAR=/Users/j1z0/Code/Selenium/selenium-server-standalone-2.19.0.jar
alias startSauce="java -jar /Users/j1z0/Code/NGA_Selenium/ews_automationframework/src/test/resources/Sauce-Connect.jar j1z0 994c963d-ffb8-46fd-9a34-8c13f99adf86 -b"
alias NGAstartSauce="java -jar /Users/j1z0/Code/NGA_Selenium/ews_automationframework/src/test/resources/Sauce-Connect.jar athenepharo 0634af35-a277-4b18-b5c6-86502e5cd03c"

alias ssh-jenkins="ssh jeremyj@DCA-V-SCL-0001.user.arinso"

#todo.txt stuff
source /usr/local/etc/bash_completion.d
export TODOTXT_DEFAULT_ACTION=ls
alias t="todo.sh -d ~/.todo.cfg"
alias punch="python ~/Documents/todo/Punch.py"
#_complete -F _todo t

#github command line tool installed with brew install hub
alias git=hub

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="bunsen"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin:/Users/j1z0/Library/mongodb-osx-x86_64-2.0.6/bin:/usr/local/sbin:/opt/local/bin:/opt/local/sbin:/Users/j1z0/Library/scripts
