##############################################################################
# Rakefile - Configuration file for rake (http://rake.rubyforge.org/)
# Time-stamp: <Sun 2016-11-13 20:53 svarrette>
#
# Copyright (c) 2012 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
#                       ____       _         __ _ _
#                      |  _ \ __ _| | _____ / _(_) | ___
#                      | |_) / _` | |/ / _ \ |_| | |/ _ \
#                      |  _ < (_| |   <  __/  _| | |  __/
#                      |_| \_\__,_|_|\_\___|_| |_|_|\___|
#
# Use 'rake -T' to list the available actions
#
# Resources:
# * http://www.stuartellis.eu/articles/rake/
##############################################################################

# require 'rubygems'
# FALKORLIB_SPEC = Gem::Specification.load("falkorlib.gemspec")

task :default => [ 'rspec' ]

#.....................
require 'rake/clean'
CLEAN.add   'pkg'
CLOBBER.add 'doc'

#__________________ My own rake tasks __________________
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "falkorlib"

# Adapt the versioning aspects
FalkorLib.config.versioning do |c|
  c[:type] = 'gem'
end

# Adapt the Git flow aspects
FalkorLib.config.gitflow do |c|
  c[:branches] = {
    :master => 'production',
    :develop => 'devel'
  }
end

require "falkorlib/tasks/git"    # OR require "falkorlib/git_tasks"
require "falkorlib/tasks/gem"    # OR require "falkorlib/gem_tasks"


# [ 'rspec', 'yard' ] .each do |tasks|
#     load "falkorlib/tasks/#{tasks}.rake"
# end

# desc "clean the directory"
# task :clean => :clobber_package do
#   sh "rm -rf doc" if File.directory?("doc")
# end
