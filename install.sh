#!/bin/bash

PYTHON_VERSIONS=(2.7.10 3.4.3 3.5.0)
PYTHON_GLOBAL_VERSION=3.4.3
PYTHON_PIP_VERSION=7.1.2
VAGRANT_VERSION=1.7.4

apk --update add curl ca-certificates git build-base \
    libffi-dev openssl-dev libbz2 libc6-compat ncurses-dev readline-dev \
    xz-dev zlib-dev sqlite-dev patch bzip2-dev expat-dev zlib-dev \
    gdbm-dev paxmark linux-headers tcl-dev ruby ruby-bundler ruby-dev \
    ruby-io-console ruby-json libxml2-dev libxslt-dev libarchive-tools openssh-client rsync

# Install pyenv
curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer -o /pyenv-installer
touch /root/.bashrc
/bin/ln -s /root/.bashrc /root/.bash_profile
/bin/bash /pyenv-installer
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bash_profile
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Install all python versions
for v in "${PYTHON_VERSIONS[@]}"; do
    pyenv install $v &
done
wait

# Set global python version
pyenv global $PYTHON_GLOBAL_VERSION "${PYTHON_VERSIONS[@]}"

# Install tox
pip install -U pip
pip install -U tox

# Install Vagrant
curl -L https://github.com/mitchellh/vagrant/archive/v${VAGRANT_VERSION}.tar.gz -o vagrant.tar.gz
tar zxf vagrant.tar.gz
cd vagrant-${VAGRANT_VERSION}
bundle config build.nokogiri --use-system-libraries
bundle install
rake install
cd ..

# Install vagrant-vsphere
VAGRANT_FORCE_BUNDLER=1 vagrant plugin install vagrant-vsphere

# Cleanup
rm /pyenv-installer
rm -rf /var/cache/apk/*
rm -rf /tmp/python*
rm -rf /tmp/pip*
rm -rf /usr/share/ri
rm vagrant.tar.gz
rm -rf vagrant-${VAGRANT_VERSION}
