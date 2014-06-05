##############################################################################
# Rakefile - Configuration file for rake (http://rake.rubyforge.org/)
# Time-stamp: <Jeu 2014-06-05 10:19 svarrette>
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
end # namespace gem


#_____________ My own rake tasks ______________________
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

[ 'rspec.rake' ] .each do |tasks| 
	load "falkorlib/tasks/#{tasks}"
end

#
# Install all tasks found in tasks folder
#
# See .rake files there for complete documentation.
#
# RAKE_TASKS_TO_LOAD = [
#                       #'debug_mail.rake',
#                       #'gem.rake',
#                       'spec_test.rake',
#                       #'unit_test.rake',
#                       #'yard.rake'
#                      ] 

# Dir["tasks/*.rake"].each do |taskfile|
# 	next unless RAKE_TASKS_TO_LOAD.include?(taskfile.gsub(/.*tasks\//, ''))
# 	load taskfile
# end



# desc "clean the directory"
# task :clean => :clobber_package do
# 	sh "rm -rf doc" if File.directory?("doc")
# end

task :console do
  require 'irb'
  require 'irb/completion'
  require 'my_gem' # You know what to do.
  ARGV.clear
  IRB.start
end
