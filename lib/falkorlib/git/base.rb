# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Sun 2022-06-05 17:16 svarrette>
################################################################################
# Interface for the main Git operations
#
# On purpose, I try to avoid using the Git library to avoid instanciate the Git
# class and thus managing the working directory

require "falkorlib"
require "falkorlib/common"

require "minigit"
require "pathname"

include FalkorLib::Common

module FalkorLib #:nodoc:

  module Config
    # Default configuration for Git
    module Git

      # Git defaults for FalkorLib
      DEFAULTS = {
        :submodulesdir => '.submodules',
        :submodules => {},
        :subtrees   => {}
      }

    end
  end

  # Management of Git operations
  module Git

    module_function

    ## Check if a git directory has been initialized
    def init?(path = Dir.pwd)
      begin
        MiniGit.new(path)
      rescue Exception
        return false
      end
      true
    end

    ## Check if the repositories already holds some commits
    def commits?(path)
      res = false
      Dir.chdir(path) do
        _stdout, _stderr, exit_status = Open3.capture3( "git rev-parse HEAD" )
        res = (exit_status.to_i.zero?)
      end
      res
    end

    ## Check the availability of a given git command
    def command?(cmd)
      cg = MiniGit::Capturing.new
      cmd_list = cg.help :a => true
      # typical run:
      # usage: git [--version] [--help] [-C <path>] [-c name=value]
      #            [--exec-path[=<path>]] [--html-path] [--man-path] [--info-path]
      #            [-p|--paginate|--no-pager] [--no-replace-objects] [--bare]
      #            [--git-dir=<path>] [--work-tree=<path>] [--namespace=<name>]
      #            <command> [<args>]
      #
      # available git commands in '/usr/local/Cellar/git/1.8.5.2/libexec/git-core'
      #
      #   add   [...]   \
      #   [...]          | The part we are interested in, delimited by '\n\n' sequence
      #   [...]         /
      #
      # 'git help -a' and 'git help -g' lists available subcommands and some
      # concept guides. See 'git help <command>' or 'git help <concept>'
      # to read about a specific subcommand or concept
      l = cmd_list.split("\n\n")
      l.shift # useless first part
      #ap l
      subl = l.each_index.select { |i| l[i] =~ /^\s\s+/ } # find sublines that starts with at least two whitespaces
      #ap subl
      return false if subl.empty?
      subl.any? { |i| l[i].split.include?(cmd) }
    end

    ###
    # Initialize a git repository
    ##
    def init(path = Dir.pwd, _options = {})
      # FIXME: for travis test: ensure the global git configurations
      # 'user.email' and 'user.name' are set
      [ 'user.name', 'user.email' ].each do |userconf|
        next unless MiniGit[userconf].nil?
        warn "The Git global configuration '#{userconf}' is not set so"
        warn "you should *seriously* consider setting them by running\n\t git config --global #{userconf} 'your_#{userconf.sub(/\./, '_')}'"
        default_val = ENV['USER']
        default_val += '@domain.org' if userconf =~ /email/
        warn "Now putting a default value '#{default_val}' you could change later on"
        run %(
                       git config --global #{userconf} "#{default_val}"
                  )
        #MiniGit[userconf] = default_val
      end
      exit_status = 1
      Dir.mkdir( path ) unless Dir.exist?( path )
      Dir.chdir( path ) do
        execute "git init" unless FalkorLib.config.debug
        exit_status = $?.to_i
      end
      # #puts "#init #{path}"
      # Dir.chdir( "#{path}" ) do
      #     %x[ pwd && git init ] unless FalkorLib.config.debug
      # end
      exit_status
    end

    # Return the Git working tree from the proposed path (current directory by default)
    def rootdir(path = Dir.pwd)
      g = MiniGit.new
      g.find_git_dir(path)[1]
    end

    # Return the git root directory for the path (current directory by default)
    def gitdir(path = Dir.pwd)
      g = MiniGit.new
      g.find_git_dir(path)[0]
    end

    # Create a new branch
    def create_branch(branch, path = Dir.pwd)
      #ap method(__method__).parameters.map { |arg| arg[1] }
      g = MiniGit.new(path)
      error "not yet any commit performed -- You shall do one" unless commits?(path)
      g.branch branch.to_s
    end

    # Delete a branch.
    def delete_branch(branch, path = Dir.pwd, opts = { :force => false })
      g = MiniGit.new(path)
      error "'#{branch}' is not a valid existing branch" unless list_branch(path).include?( branch )
      g.branch ((opts[:force]) ? :D : :d) => branch.to_s
    end

    ###### config ######
    # Retrieve the Git configuration
    # You can propose a pattern as key
    # Supported options:
    #  * :list [boolean] list all configurations
    #  * :hash [boolean] return a Hash
    ##
    def config(key, dir = Dir.pwd, options = {})
      #info "Retrieve the Git configuration"
      res = nil
      if (options[:list] || (key.is_a? Regexp) || (key =~ /\*/))
        cg  = MiniGit::Capturing.new(dir)
        res = (cg.config :list => true).split("\n")
        res.select! { |e| e.match(/^#{key}/) } unless key == '*'
        #res = res.map { |e| e.split('=') }.to_h if options[:hash]
        res = Hash[ res.map { |e| e.split('=') } ] if options[:hash]
      else
        g = MiniGit.new(dir)
        res = g[key]
        res = { key => g[key] } if options[:hash]
      end
      #ap res
      res
    end


    ## Fetch the latest changes
    def fetch(path = Dir.pwd)
      Dir.chdir( path ) do
        execute "git fetch --all -v"
      end
    end

    ## Get an array of the local branches present (first element is always the
    ## current branch)
    def list_branch(path = Dir.pwd)
      cg = MiniGit::Capturing.new(path)
      res = cg.branch :a => true
      res = res.split("\n")
      # Eventually reorder to make the first element of the array the current branch
      i = res.find_index { |e| e =~ /^\*\s/ }
      res[0], res[i] = res[i], res[0] unless (i.nil? || i.zero?)
      res.each { |e| e.sub!(/^\*?\s+/, '') }
      res
    end


    ## Get the current git branch
    def branch?(path = Dir.pwd)
      list_branch(path)[0]
    end

    ## Grab a remote branch
    def grab(branch, path = Dir.pwd, remote = 'origin')
      exit_status = 1
      error "no branch provided" if branch.nil?
      #remotes  = FalkorLib::Git.remotes(path)
      branches = FalkorLib::Git.list_branch(path)
      if branches.include? "remotes/#{remote}/#{branch}"
        info "Grab the branch '#{remote}/#{branch}'"
        exit_status = execute_in_dir(FalkorLib::Git.rootdir( path ), "git branch --track #{branch} #{remote}/#{branch}")
      else
        warning "the remote branch '#{remote}/#{branch}' cannot be found"
      end
      exit_status
    end

    ## Publish a branch on the remote
    def publish(branch, path = Dir.pwd, remote = 'origin')
      exit_status = 1
      error "no branch provided" if branch.nil?
      #remotes  = FalkorLib::Git.remotes(path)
      branches = FalkorLib::Git.list_branch(path)
      Dir.chdir(FalkorLib::Git.rootdir( path ) ) do
        if branches.include? "remotes/#{remote}/#{branch}"
          warning "the  remote branch '#{remote}/#{branch}' already exists"
        else
          info "Publish the branch '#{branch}' on the remote '#{remote}'"
          exit_status = run %(
                          git push #{remote} #{branch}:refs/heads/#{branch}
                          git fetch #{remote}
                          git branch -u #{remote}/#{branch} #{branch}
                )
        end
      end
      exit_status
    end

    ## List the files currently under version
    def list_files(path = Dir.pwd)
      g = MiniGit.new(path)
      g.capturing.ls_files.split
    end

    ## Add a file/whatever to Git and commit it
    # Supported options:
    # * :force [boolean]: force the add
    def add(path, msg = "", options = {})
      exit_status = 0
      dir  = File.realpath(File.dirname(path))
      root = rootdir(path)
      relative_path_to_root = Pathname.new( File.realpath(path) ).relative_path_from Pathname.new(root)
      real_msg = ((msg.empty?) ? "add '#{relative_path_to_root}'" : msg)
      opts = '-f' if options[:force]
      Dir.chdir( dir ) do
        exit_status = run %(
                  git add #{opts} #{path}
                  git commit -s -m "#{real_msg}" #{path}
                )
      end
      exit_status.to_i
    end

    ## Check if a git directory is in dirty mode
    # git diff --shortstat 2> /dev/null | tail -n1
    def dirty?(path = Dir.pwd)
      g = MiniGit.new(path)
      a = g.capturing.diff :shortstat => true
      #ap a
      !a.empty?
    end

    ## Get a hash table of tags under the format
    #  { <tag> => <commit> }
    def list_tag(path = Dir.pwd)
      res = {}
      cg  = MiniGit::Capturing.new(path)
      unless (cg.tag :list => true).empty?
        # git show-ref --tags
        a = (cg.show_ref :tags => true).split("\n")
        res = Hash[ a.collect { |item| item.split(' refs/tags/') } ].invert
      end
      res
    end # list_tag

    ## Get the last tag commit, or nil if no tag can be found
    def last_tag_commit(path = Dir.pwd)
      res = ""
      g = MiniGit.new(path)
      unless (g.capturing.tag :list => true).empty?
        # git rev-list --tags --max-count=1
        res = (g.capturing.rev_list :tags => true, :max_count => 1).chomp
      end
      res
    end # last_tag_commit

    ## Create a new tag
    # You can add extra options to the git tag command through the opts hash.
    # Ex:
    #   FalkorLib::Git.tag('name', dir,  { :delete => true } )
    #
    def tag(name, path = Dir.pwd, opts = {})
      g = MiniGit.new(path)
      g.tag opts, name
    end # tag

    ## List of Git remotes
    def remotes(path = Dir.pwd)
      g = MiniGit.new(path)
      g.capturing.remote.split
    end

    ## Check existence of remotes
    def remotes?(path = Dir.pwd)
      !remotes(path).empty?
    end

    # Create a new remote <name> targeting url <url>
    # You can pass additional options expected by git remote add in <opts>,
    # for instance as follows:
    #
    #  create_remote('origin', url, dir, { :fetch => true })
    #
    def create_remote(name, url, path = Dir.pwd, opts = {})
      g = MiniGit.new(path)
      g.remote :add, opts, name, url.to_s
    end

    # Delete a branch.
    # def delete_branch(branch, path = Dir.pwd, opts = { :force => false })
    #   g = MiniGit.new(path)
    #   error "'#{branch}' is not a valid existing branch" unless list_branch(path).include?( branch )
    #   g.branch (opts[:force] ? :D : :d) => "#{branch}"
    # end


    ###
    # Initialize git submodule from the configuration
    ##
    def submodule_init(path = Dir.pwd, submodules = FalkorLib.config.git[:submodules], _options = {})
      exit_status  = 1
      git_root_dir = rootdir(path)
      if File.exist?("#{git_root_dir}/.gitmodules")
        unless submodules.empty?
          # TODO: Check if it contains all submodules of the configuration
        end
      end
      #ap FalkorLib.config.git
      Dir.chdir(git_root_dir) do
        exit_status = FalkorLib::Git.submodule_update( git_root_dir )
        submodules.each do |subdir, conf|
          next if conf[:url].nil?
          url = conf[:url]
          dir = "#{FalkorLib.config.git[:submodulesdir]}/#{subdir}"
          branch = (conf[:branch].nil?) ? 'master' : conf[:branch]
          if File.directory?( dir )
            puts "  ... the git submodule '#{subdir}' is already setup."
          else
            info "adding Git submodule '#{dir}' from '#{url}'"
            exit_status = run %(
                           git submodule add -b #{branch} #{url} #{dir}
                           git commit -s -m "Add Git submodule '#{dir}' from '#{url}'" .gitmodules #{dir}
                        )
          end
        end
      end
      exit_status
    end

    ## Update the Git submodules to the **local** registered version
    def submodule_update(path = Dir.pwd)
      execute_in_dir(rootdir(path),
                     %(
                   git submodule init
                   git submodule update
            ))
    end

    ## Upgrade the Git submodules to the latest HEAD version from the remote
    def submodule_upgrade(path = Dir.pwd)
      execute_in_dir(rootdir(path),
                     %{
                   git submodule foreach 'git fetch origin; git checkout $(git rev-parse --abbrev-ref HEAD); git reset --hard origin/$(git rev-parse --abbrev-ref HEAD); git submodule update --recursive; git clean -dfx'
             })
    end


    ## Initialize git subtrees from the configuration
    def subtree_init(path = Dir.pwd)
      raise ArgumentError, "Git 'subtree' command is not available" unless FalkorLib::Git.command? "subtree"
      if FalkorLib.config.git[:subtrees].empty?
        FalkorLib::Git.config_warn(:subtrees)
        return 1
      end
      exit_status = 0
      git_root_dir = rootdir(path)
      Dir.chdir(git_root_dir) do
        FalkorLib.config.git[:subtrees].each do |dir, conf|
          next if conf[:url].nil?
          url    = conf[:url]
          remote = dir.gsub(/\//, '-')
          branch = (conf[:branch].nil?) ? 'master' : conf[:branch]
          remotes = FalkorLib::Git.remotes
          unless remotes.include?( remote )
            info "Initialize Git remote '#{remote}' from URL '#{url}'"
            exit_status = execute "git remote add --no-tags -f #{remote} #{url}"
          end
          unless File.directory?( File.join(git_root_dir, dir) )
            info "initialize Git subtree '#{dir}'"
            exit_status = execute "git subtree add --prefix #{dir} --squash #{remote}/#{branch}"
          end
        end
      end
      exit_status
    end

    ## Check if the subtrees have been initialized.
    ## Actually based on a naive check of sub-directory existence
    def subtree_init?(path = Dir.pwd)
      res = true
      FalkorLib.config.git[:subtrees].keys.each do |dir|
        res &&= File.directory?(File.join(path, dir))
      end
      res
    end # subtree_init?


    ## Show difference between local subtree(s) and their remotes"
    def subtree_diff(path = Dir.pwd)
      raise ArgumentError, "Git 'subtree' command is not available" unless FalkorLib::Git.command? "subtree"
      if FalkorLib.config.git[:subtrees].empty?
        FalkorLib::Git.config_warn(:subtrees)
        return 1
      end
      exit_status = 0
      git_root_dir = rootdir(path)
      Dir.chdir(git_root_dir) do
        FalkorLib.config.git[:subtrees].each do |dir, conf|
          next if conf[:url].nil?
          #url    = conf[:url]
          remote = dir.gsub(/\//, '-')
          branch = (conf[:branch].nil?) ? 'master' : conf[:branch]
          remotes = FalkorLib::Git.remotes
          raise IOError, "The git remote '#{remote}' is not configured" unless remotes.include?( remote )
          raise IOError, "The git subtree directory '#{dir}' does not exists" unless File.directory?( File.join(git_root_dir, dir) )
          info "Git diff on subtree '#{dir}' with remote '#{remote}/#{branch}'"
          exit_status = execute "git diff #{remote}/#{branch} #{FalkorLib::Git.branch?( git_root_dir )}:#{dir}"
        end
      end
      exit_status
    end

    # Pull the latest changes, assuming the git repository is not dirty
    def subtree_up(path = Dir.pwd)
      error "Unable to pull subtree(s): Dirty Git repository" if FalkorLib::Git.dirty?( path )
      exit_status = 0
      git_root_dir = rootdir(path)
      Dir.chdir(git_root_dir) do
        FalkorLib.config.git[:subtrees].each do |dir, conf|
          next if conf[:url].nil?
          #url    = conf[:url]
          remote = dir.gsub(/\//, '-')
          branch = (conf[:branch].nil?) ? 'master' : conf[:branch]
          remotes = FalkorLib::Git.remotes
          info "Pulling changes into subtree '#{dir}' using remote '#{remote}/#{branch}'"
          raise IOError, "The git remote '#{remote}' is not configured" unless remotes.include?( remote )
          info "\t\\__ fetching remote '#{remotes.join(',')}'"
          FalkorLib::Git.fetch( git_root_dir )
          raise IOError, "The git subtree directory '#{dir}' does not exists" unless File.directory?( File.join(git_root_dir, dir) )
          info "\t\\__ pulling changes"
          exit_status = execute "git subtree pull --prefix #{dir} --squash #{remote} #{branch}"
          #exit_status = puts "git subtree pull --prefix #{dir} --squash #{remote} #{branch}"
        end
      end
      exit_status
    end
    alias_method :subtree_pull, :subtree_up

    # Raise a warning message if subtree/submodule section is not present
    def config_warn(type = :subtrees)
      warn "You shall setup 'Falkorlib.config.git[#{type.to_sym}]' to configure #{type} as follows:"
      warn "     FalkorLib.config.git do |c|"
      warn "       c[#{type.to_sym}] = {"
      warn "          '<subdir>' => {"
      warn "             :url    => '<giturl>',"
      warn "             :branch => 'develop'   # if different from master"
      warn "          },"
      warn "        }"
      warn "     end"
      if type == :submodules
        warn "This will configure the Git submodule into FalkorLib.config.git.submodulesdir"
        warn "i.e. '#{FalkorLib.config.git[:submodulesdir]}'" if FalkorLib.config.git[:submodulesdir]
      end
    end






  end # module FalkorLib::Git

end # module FalkorLib
