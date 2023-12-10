#! /bin/bash
################################################################################
# bootstrap.sh - Bootstrap a fresh new directory for using FalkorLib and its
#    associated Rake tasks.
# Time-stamp: <Tue 2023-11-21 17:31 svarrette>
#
# Copyright (c) 2014-2023 Sebastien Varrette <Sebastien.Varrette@gmail.com>
################################################################################

RUBY_VERSION='3.1.2'
GEMSET=`basename $PWD`

echo "=> initialize RVM -- see http://rvm.io"
[ ! -f .ruby-version ] && echo ${RUBY_VERSION} > .ruby-version
rvm install `cat .ruby-version`
[ ! -f .ruby-gemset ] && echo ${GEMSET} > .ruby-gemset

echo "=> Force reloading RVM configuration within $PWD"
cd .. && cd -

echo "=> installing the Bundler gem -- see http://bundler.io"
gem install bundler

echo "=> setup the FalkorLib gem in the directory ${GEMSET}"
bundle init
if ! grep -Fq "falkorlib" Gemfile; then
    echo "gem 'falkorlib'" >> Gemfile
fi
bundle
if [ ! -f Rakefile ]; then
cat > Rakefile <<EOF
#
# Rakefile - Configuration file for rake (http://rake.rubyforge.org/)
#
require 'falkorlib'

## placeholder for custom configuration of FalkorLib.config.*
## See https://github.com/Falkor/falkorlib

require 'falkorlib/tasks/git'
EOF

fi

#echo "=> That's all folks!"
