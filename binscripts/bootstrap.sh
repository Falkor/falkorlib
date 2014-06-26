#! /bin/bash
################################################################################
# bootstrap.sh - Bootstrap a fresh new directory for using FalkorLib and its
#    associated Rake tasks. 
# Creation : 26 Jun 2014
# Time-stamp: <Jeu 2014-06-26 11:02 svarrette>
#
# Copyright (c) 2014 Sebastien Varrette <Sebastien.Varrette@uni.lu>
#               http://varrette.gforge.uni.lu
################################################################################

RUBY_VERSION='2.1.0' 
GEMSET=`basename $PWD`

echo "=> initialize RVM -- see http://rvm.io"
[ ! -f .ruby-version ] && echo ${RUBY_VERSION} > .ruby-version;
rvm install `cat .ruby-version`;
[ ! -f .ruby-gemset ] && echo ${GEMSET} > .ruby-gemset;

echo "=> Force reloading RVM configuration within $PWD"
cd .. && cd -;

echo "=> installing the Bundler gem -- see http://bundler.io"
gem install bundler;

echo "=> setup the FalkorLib gem in the directory ${GEMSET}"
bundle init;
echo "gem 'falkorlib'" >> Gemfile; 
bundle;
[ ! -f Rakefile ] && echo "require 'falkorlib'" > Rakefile;

#echo "=> That's all folks!"
