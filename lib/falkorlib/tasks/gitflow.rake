################################################################################
# gitflow.rake - Special tasks for the management of Git [Flow] operations
# Time-stamp: <Jeu 2014-06-19 17:19 svarrette>
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


    #['feature', 'hotfix', 'support'].each do |op|
    ['feature'].each do |op|
        #.....................
        namespace op.to_sym do

            #########   git:{feature,hotfix,support}:start ##########################
            desc "Start a new #{op} operation on the repository using the git-flow framework"
            task :start, [:name] do |t, args|
                #args.with_default[:name => '']
                name = args.name == 'name' ? ask("Name of the #{op} (the git branch will be 'feature/<name>')") : args.name
                info t.comment + " with name '#{op}/#{name}'"
                really_continue?
                Rake::Task['git:up'].invoke unless FalkorLib::Git.remotes.empty?
                info "=> prepare new '#{op}' using git flow"
                FalkorLib::GitFlow.start(op, name)
                # Now you should be in the new branch
            end

            #########   git:{feature,hotfix,support}:finish ##########################
            desc "Finalize the #{op} operation"
            task :finish do |t|
                branch = FalkorLib::Git.branch?
                expected_branch_prefix = FalkorLib.config.gitflow[:prefix][op.to_sym]
                if branch !~ /^#{expected_branch_prefix}/
                    error "You are not in the expected branch (with prefix '#{expected_branch_prefix}')"
                end
                name = branch.sub(/^#{expected_branch_prefix}/, '')
                info t.comment
                FalkorLib::GitFlow.finish(op, name)
                unless FalkorLib::Git.remotes.empty?
                    info "=> about to update remote tracked branches"
                    really_continue?
                    Rake::Task['git:push'].invoke
                end
            end
        end # End namespace 'git:{feature,hotfix,support}'
    end

end # namespace git


#.....................
namespace :version do

	###########   version:info   ###########
	desc "Get versioning information"
	task :info do |t|
		include FalkorLib::Versioning
		version = get_version
		#major, minor, patch =  bump(version, :major), bumpversion, :minor), bump(version, :patch)
		info t.comment
		puts "Current version: " + bold(version)
		FalkorLib.config[:versioning][:levels].reverse.each do |level|
			puts "- next #{level} version: " + bump(version, level.to_sym)
		end		
	end # task info 


	#.....................
	namespace :bump do
		[ 'major', 'minor', 'patch' ].each do |level|
			
			#################   version:bump:{major,minor,patch} ##################################
			desc "Prepare the #{level} release of the repository"
			task level.to_sym do |t|
				version = FalkorLib::Versioning.get_version
				release_version = FalkorLib::Versioning.bump(version, level.to_sym)
				info t.comment + " (from version '#{version}' to '#{release_version}')"
				really_continue?
				Rake::Task['git:up'].invoke unless FalkorLib::Git.remotes.empty?
				info "=> prepare release using git flow"
				o = FalkorLib::GitFlow.start('release', release_version)
				# Now you should be in the new branch
				current_branch = FalkorLib::Git.branch?
				expected_branch = FalkorLib.config[:gitflow][:prefix][:release] + release_version
				if (current_branch == expected_branch)
					FalkorLib::Versioning.set_version(release_version)
					warning "The version number has already been bumped"
					warning "==> run 'rake release:finish' to finalize the release and merge the current version of the repository into the '#{FalkorLib.config[:gitflow][:branches][:master]}' branch"
				else
					error "You are in the '#{branch}' branch and not the expected one, i.e. #{expected_branch}"
				end
			end
		end
	end # namespace version:bump
end # namespace version
