################################################################################
# gitflow.rake - Special tasks for the management of Git [Flow] operations
# Time-stamp: <Fri 2016-11-11 15:25 svarrette>
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

  ###########  git:init   ###########
  #desc "Initialize Git repository"
  task :init => [ 'git:flow:init' ]

  #.....................
  namespace :flow do

    ###########   git:flow:init   ###########
    desc "Initialize your local clone of the repository for the git-flow management"
    task :init do |t|
      info t.comment
      FalkorLib::GitFlow.init(git_root_dir)
    end # task init

  end # namespace git::flow

  #.....................
  namespace :feature do

    #########   git:feature:start ##########################
    desc "Start a new feature operation on the repository using the git-flow framework"
    task :start, [:name] do |t, args|
      #args.with_default[:name => '']
      name = args.name == 'name' ? ask("Name of the feature (the git branch will be 'feature/<name>')") : args.name
      info t.comment + " with name 'feature/#{name}'"
      really_continue?
      Rake::Task['git:up'].invoke unless FalkorLib::Git.remotes.empty?
      info "=> prepare new 'feature' using git flow"
      o = FalkorLib::GitFlow.start('feature', name)
      error "Git flow feature operation failed" unless o == 0
      # Now you should be in the new branch
    end

    #########   git:feature:finish ##########################
    desc "Finalize the feature operation"
    task :finish do |t|
      branch = FalkorLib::Git.branch?
      expected_branch_prefix = FalkorLib.config.gitflow[:prefix][:feature]
      if branch !~ /^#{expected_branch_prefix}/
        error "You are not in the expected branch (with prefix '#{expected_branch_prefix}')"
      end
      name = branch.sub(/^#{expected_branch_prefix}/, '')
      info t.comment
      o = FalkorLib::GitFlow.finish('feature', name)
      error "Git flow feature operation failed" unless o == 0
      unless FalkorLib::Git.remotes.empty?
        info "=> about to update remote tracked branches"
        really_continue?
        Rake::Task['git:push'].invoke
      end
    end
  end # End namespace 'git:feature'

end # namespace git


#.....................
namespace :version do

  ###########   version:info   ###########
  #desc "Get versioning information"
  task :info do |t|
    include FalkorLib::Versioning
    version = get_version
    #major, minor, patch =  bump(version, :major), bumpversion, :minor), bump(version, :patch)
    info "Get versioning information" #  t.comment
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
        error "Git flow release process failed" unless o == 0
        # Now you should be in the new branch
        current_branch = FalkorLib::Git.branch?
        expected_branch = FalkorLib.config[:gitflow][:prefix][:release] + release_version
        if (current_branch == expected_branch)
          FalkorLib::Versioning.set_version(release_version)
          if (! FalkorLib.config[:versioning].nil?) &&
              FalkorLib.config[:versioning][:type] == 'gem' &&
              File.exists?(File.join(FalkorLib::Git.rootdir, 'Gemfile'))
            info "Updating Gemfile information"
            run %{
                           # Update cache info
                           bundle list > /dev/null
                           git commit -s -m "Update Gemfile.lock accordingly" Gemfile.lock
            }
          end
          warning "The version number has already been bumped"
          warning "==> run 'rake version:release' to finalize the release and merge the current version of the repository into the '#{FalkorLib.config[:gitflow][:branches][:master]}' branch"
        else
          error "You are in the '#{branch}' branch and not the expected one, i.e. #{expected_branch}"
        end
      end
    end
  end # namespace version:bump

  ###########   release   ###########
  desc "Finalize the release of a given bumped version"
  task :release do |t|
    version = FalkorLib::Versioning.get_version
    branch  = FalkorLib::Git.branch?
    expected_branch = FalkorLib.config[:gitflow][:prefix][:release] + version
    error "You are not in the '#{expected_branch}' branch but in the '#{branch}' one. May be you forgot to run 'rake version:bump:{patch,minor,major}' first" if branch != expected_branch
    info "=> Finalize the release of the version '#{version}' into the '#{FalkorLib.config[:gitflow][:branches][:master]}' branch/environment"
    o = FalkorLib::GitFlow.finish('release', version, Dir.pwd, '-s')
    error "Git flow release process failed" unless o == 0
    if FalkorLib::Git.remotes?
      info("=> about to update remote tracked branches")
      really_continue?
      FalkorLib.config[:gitflow][:branches].each do |type, branch|
        run %{
                   git checkout #{branch}
                   git push origin
        }
      end
      run %{ git push origin --tags }
    end
    #info "Update the changelog"
    if (! FalkorLib.config[:versioning].nil?) &&
        FalkorLib.config[:versioning][:type] == 'gem'
      warn "About to push the released new gem (version #{version}) to the gem server (rybygems.org)"
      really_continue?
      Rake::Task['gem:release'].invoke
    end

    #Rake::Task['git:push'].invoke
  end # task version:release



end # namespace version
