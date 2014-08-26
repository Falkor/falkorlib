# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Lun 2014-08-25 23:25 svarrette>
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
end # namespace falkorlib


#.....................
namespace :bootstrap do
	###########   bootstrap:bundler   ###########
	task :bundler do 
		info "Bootstrap Bundler -- see http://bundler.io/"
		error "Unable to find the 'bundle' command" unless command?('bundle')
		run %{ bundle }
	end 

	###########   rvm   ###########
	task :rvm do 
		info "Boostrap RVM for this repository -- see https://rvm.io"
		error "RVM is not installed -- see https://rvm.io/rvm/install for instructions" unless command?('rvm')
		init_rvm(Dir.pwd)
		# ['version', 'gemset'].each do |t| 
		# 	error "unable to find the .ruby-#{t} file" unless File.exists?(".ruby-#{t}")
		# end
		info "=> initialize RVM -- see http://rvm.io"
		run %{ rvm install `cat .ruby-version` }
		rvm_current = `rvm current`
		if rvm_current.empty? or rvm_current != "`cat .ruby-version`@`cat .ruby-gemset`"
			warn "You need to manually force the reloading of the RVM configuration."
			warn "To do that, simply run \n\t\tcd .. && cd -"
			error "manual RVM reloading required"
		end
		#rvmenv = %x( rvm env --path -- `cat .ruby-version`@`cat .ruby-gemset`)
		# info "=> Force reloading RVM configuration within $PWD"
		# run %{ 
        #    bash -l -c 'rvm use  `cat .ruby-version`' 
        #    bash -l -c 'rvm gemset use `cat .ruby-gemset`'
        #    bash -l -c 'rvm list && rvm gemset list'
        # }
		
		info "=> installing the Bundler gem -- see http://bundler.io"
		run %{ gem install bundler }
	end 

end # namespace bootstrap


###########   setup   ###########
desc "Setup the repository"
task :setup => ['bootstrap:rvm', 'bootstrap:bundler']


# Empty task debug 
task :DEBUG do
end

