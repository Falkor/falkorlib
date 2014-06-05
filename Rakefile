##############################################################################
# Rakefile - Configuration file for rake (http://rake.rubyforge.org/)
# Time-stamp: <Jeu 2014-06-05 10:55 svarrette>
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

#.....................
namespace :gem do
    # Classical gem tasks offered within bundler
    require "bundler/gem_tasks"

    desc "Open a console to test the gem"
    task :console do |t|
        require 'irb'
        require 'irb/completion'
        require 'falkorlib'
        ARGV.clear
        IRB.start
    end

end # namespace gem


#__________________ My own rake tasks __________________
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

[ 'rspec', 'yard' ] .each do |tasks|
    load "falkorlib/tasks/#{tasks}.rake"
end

# desc "clean the directory"
# task :clean => :clobber_package do
#   sh "rm -rf doc" if File.directory?("doc")
# end
