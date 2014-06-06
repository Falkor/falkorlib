##############################################################################
# tasks : Default FalkorLib rake tasks
# .           See http://rake.rubyforge.org/
# Time-stamp: <Ven 2014-06-06 10:20 svarrette>
#
# Copyright (c) 2014 Sebastien Varrette <Sebastien.Varrette@uni.lu>
##############################################################################

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

end # namespace falkorlib



# Empty task debug 
task :DEBUG do
end

