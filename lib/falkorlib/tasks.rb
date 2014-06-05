##############################################################################
# tasks : Default FalkorLib rake tasks
# .           See http://rake.rubyforge.org/
# Time-stamp: <Jeu 2014-06-05 16:49 svarrette>
#
# Copyright (c) 2014 Sebastien Varrette <Sebastien.Varrette@uni.lu>
##############################################################################

require 'rake'

FalkorLib.config.debug = ARGV.include?('DEBUG')

# Empty task debug 
task :DEBUG do
end

