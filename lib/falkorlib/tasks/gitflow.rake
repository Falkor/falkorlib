################################################################################
# gitflow.rake - Special tasks for the management of Git [Flow] operations 
# Time-stamp: <Mar 2014-06-03 10:48 svarrette>
#
# Copyright (c) 2014 Sebastien Varrette <Sebastien.Varrette@uni.lu>
#               http://varrette.gforge.uni.lu
################################################################################


#.....................
namespace :git do
	
	



	#.....................
	namespace :flow do
		
		###########   name   ###########
		desc "Initialize Git flow for this repository"
		task :init do |t|
			puts "init"
			puts "initiliaze "
			
		end # task name 




	end # namespace git::flow
end # namespace git

