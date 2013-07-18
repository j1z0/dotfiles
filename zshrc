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
source /Library/Frameworks/Python.framework/Versions/2.7/bin/virtualenvwrapper.sh

#selenium stuff
#export SELENIUM_SERVER_JAR=/Users/j1z0/Code/Selenium/selenium-server-standalone-2.19.0.jar
#alias startSauce="java -jar /Users/j1z0/Code/NGA_Selenium/ews_automationframework/src/test/resources/Sauce-Connect.jar j1z0 994c963d-ffb8-46fd-9a34-8c13f99adf86 -b"
#alias NGAstartSauce="java -jar /Users/j1z0/Code/NGA_Selenium/ews_automationframework/src/test/resources/Sauce-Connect.jar athenepharo 0634af35-a277-4b18-b5c6-86502e5cd03c"

#alias ssh-jenkins="ssh jeremyj@DCA-V-SCL-0001.user.arinso"

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
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin:/usr/local/MacGPG2/bin:/Users/j1z0/Library/mongodb-osx-x86_64-2.0.6/bin:/Library/Frameworks/Python.framework/Versions/2.7/bin:/usr/local/sbin:/opt/local/bin:/opt/local/sbin:/Users/j1z0/Library/scripts

#ORacle stuff
export ORACLE_SID=XE
export ORACLE_BASE=/usr/lib/oracle/xe/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/10.2.0/server
export PATH=$PATH:$ORACLE_HOME/bin

#glassfish stuff
export GLASSFISH_DIR=/opt/glassfishv3
export GLASSFISH_HOME=$GLASSFISH_DIR/glassfish
export DERBY_HOME=$GLASSFISH_DIR/javadb
export OPEN_MQ_HOME=$GLASSFISH_DIR/mq
export PATH=$PATH:$GLASSFISH_HOME/bin:$DERBY_HOME/bin:$OPEN_MQ_HOME/bin

alias createUploadDir='mkdir /opt/glassfishv3/glassfish/domains/domain1/applications/ePermit-STA/Attach'
