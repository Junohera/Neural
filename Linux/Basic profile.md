# bash_profile
```shell
vi ~/.bash_profile 

#!/bin/sh

# ENVIRONMENT VARIABLES 
PATH=$PATH://usr/lib/postgresql/9.4/bin
export PATH

# ALIAS
alias 'c=clear'
alias 'his=history | cut -c 8- | uniq | sort -u'
alias 'myip=ifconfig | head -2 | tail -1 | awk -Fnetmask '"'"'{print $1}\'"'"' | awk -F" " '"'"'{print $NF}'"'"''
alias 'hello=clear;cat -n ~/.bash_profile;'

hello

:wq

source ~/.bash_profile
```

# vimrc
```shell
vi ~/.vimrc

if has("syntax")
  syntax on
endif

set nocp
set bs=2
set ts=2
set sts=2
set shiftwidth=2
set laststatus=2
set expandtab
set nu
set title
set showmode
set showmatch
set ruler
filetype on
set ignorecase
set incsearch
set hlsearch
set fileencodings=utf8,euc-kr
set visualbell

:wq
```