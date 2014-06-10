# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Mar 2014-06-10 10:32 svarrette>
################################################################################
#
# Default FalkorLib rake tasks
#

require 'rake'
require 'yaml'

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

