# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Lun 2014-08-18 21:19 svarrette>
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
	#desc "Print the current configuration of FalkorLib"
	task :conf do
		puts FalkorLib.config.to_yaml
	end 
end # namespace falkorlib


#.....................
namespace :bundle do
	
	###########   init   ###########
	#desc "Initialize your Bundler configuration from your Gemfile"
	task :init do |t|
		info "#{t.comment}"
		run %{ bundle }
	end # task init 


end # namespace bundle

###########   setup   ###########
desc "Setup the repository"
task :setup => [ 'bundle:init' ]


# Empty task debug 
task :DEBUG do
end

