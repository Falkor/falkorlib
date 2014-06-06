################################################################################
# gitflow.rake - Special tasks for the management of Git [Flow] operations 
# Time-stamp: <Ven 2014-06-06 18:53 svarrette>
#
# Copyright (c) 2014 Sebastien Varrette <Sebastien.Varrette@uni.lu>
#               http://varrette.gforge.uni.lu
################################################################################

require 'falkorlib'
require 'falkorlib/tasks'
require 'falkorlib/git'

#.....................
namespace :git do
	
	include FalkorLib::Common
    git_root_dir = FalkorLib::Git.rootdir

	#.....................
	namespace :flow do
		
		###########   git:flow:init   ###########
		desc "Initialize your local clone of the repository for the git-flow management"
		task :init do |t|
			FalkorLib::GitFlow.init(git_root_dir)
		end # task init 






	end # namespace git::flow
end # namespace git

