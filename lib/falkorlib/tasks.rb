# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Jeu 2014-06-12 16:36 svarrette>
################################################################################
#
# Default FalkorLib rake tasks
#

require 'rake'
require 'yaml'

#Needed for rake/gem '= 0.9.2.2'
Rake::TaskManager.record_task_metadata = true

FalkorLib.config.debug = ARGV.include?('DEBUG')

#.....................
namespace :falkorlib do
	###########  falkorlib:conf   ###########
	desc "Print the current configuration of FalkorLib"
	task :conf do
		puts FalkorLib.config.to_yaml
	end 
end # namespace falkorlib<


# Empty task debug 
task :DEBUG do
end

