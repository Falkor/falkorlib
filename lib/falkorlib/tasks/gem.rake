# -*- encoding: utf-8 -*-
################################################################################
# gem.rake - Special tasks for the management of Gem operations
# Time-stamp: <Jeu 2014-06-19 23:28 svarrette>
#
# Copyright (c) 2014 Sebastien Varrette <Sebastien.Varrette@uni.lu>
#               http://varrette.gforge.uni.lu
################################################################################

require 'falkorlib'
require 'falkorlib/tasks'
require 'falkorlib/git'
require 'rubygems/tasks'

#.....................
namespace :gem do
	Gem::Tasks::Console.new(:command => 'pry')
end # namespace gem

# Until [Issue#13](https://github.com/postmodern/rubygems-tasks/issues/13) it solved, 
# I have to remain in the global tasks not embedded in a namespace
Gem::Tasks::Install.new
Gem::Tasks::Build::Gem.new(:sign => true)
Gem::Tasks::Sign::PGP.new 

# Enhance the build to sign the built gem
Rake::Task['build'].enhance do
  Rake::Task["sign"].invoke
end

Gem::Tasks.new(
               :console => false,
               :install => false,
               :sign    => false,
               :build   => false,
               :release => true
               ) do |t|
	t.scm.tag = false
end



# Gem::Tasks.new(:console => false, :release => false, :sign => true) do |tasks|
# 	# tasks.build = {
# 	# 	:tar => true, 
# 	# 	:zip => true
# 	# },


# # 	#tasks.scm.tag.format = "release-%s",
# # 	#tasks.scm.tag.sign   = true,
# #     #tasks.console.command = 'pry'
# # 	# tasks.scm.tag = false
# #     # tasks.sign.checksum   = true
# #     # tasks.sign.pgp        = true
# end

