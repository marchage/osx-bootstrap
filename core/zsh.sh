#!/bin/bash

# define helpers
source_dir=~/.osx-bootstrap

# install oh-my-zsh
if [[ ! -f ~/.zshrc ]]; then
    echo ''
    echo '##### Installing oh-my-zsh...'
    curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh

    # setup zsh
    rm -rf ~/.zshrc

    # create zshrc
    cp -rf $source_dir/templates/.zshrc ~/
fi

# install z prezto for sane defaults (sort of)
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
setopt EXTENDED_GLOB    
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done