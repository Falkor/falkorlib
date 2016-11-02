# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Tue 2016-11-01 10:08 svarrette>
################################################################################
# Interface for the main Bootstrapping operations
#

require "falkorlib"
require "falkorlib/common"
require "falkorlib/bootstrap"

require 'erb'      # required for module generation
require 'artii'
require 'facter'

include FalkorLib::Common



module FalkorLib
    module Bootstrap
        module_function

        ###### rvm ######
        # Initialize RVM in the current directory
        # Supported options:
        #  * :force       [boolean] force overwritting
        #  * :ruby        [string]  Ruby version to configure for RVM
        #  * :versionfile [string]  Ruby Version file
        #  * :gemset      [string]  RVM Gemset to configure
        #  * :gemsetfile  [string]  RVM Gemset file
        #  * :commit      [boolean] Commit the changes NOT YET USED
        ##
        def rvm(dir = Dir.pwd, options = {})
            info "Initialize Ruby Version Manager (RVM)"
            ap options if options[:debug]
            path = normalized_path(dir)
            use_git = FalkorLib::Git.init?(path)
            rootdir = use_git ? FalkorLib::Git.rootdir(path) : path
            files = {}
            exit_status = 1
            [:versionfile, :gemsetfile].each do |type|
                f = options[type.to_sym].nil? ? FalkorLib.config[:rvm][type.to_sym] : options[type.to_sym]
                if File.exists?( File.join( rootdir, f ))
                    content = `cat #{File.join( rootdir, f)}`.chomp
                    warning "The RVM file '#{f}' already exists (and contains '#{content}')"
                    next unless options[:force]
                    warning "... and it WILL BE overwritten"
                end
                files[type.to_sym] = f
            end
            # ==== Ruby version ===
            unless files[:versionfile].nil?
                file = File.join(rootdir, files[:versionfile])
                v =
                  options[:ruby] ?
                  options[:ruby] :
                  select_from(FalkorLib.config[:rvm][:rubies],
                              "Select RVM ruby to configure for this directory",
                              1)
                info " ==>  configuring RVM version file '#{files[:versionfile]}' for ruby version '#{v}'"
                File.open(file, 'w') do |f|
                    f.puts v
                end
                exit_status = (File.exists?(file) and `cat #{file}`.chomp == v) ? 0 : 1
                FalkorLib::Git.add(File.join(rootdir, files[:versionfile])) if use_git
            end
            # === Gemset ===
            if files[:gemsetfile]
                file = File.join(rootdir, files[:gemsetfile])
                default_gemset = File.basename(rootdir)
                default_gemset = `cat #{file}`.chomp if File.exists?( file )
                g = options[:gemset] ? options[:gemset] : ask("Enter RVM gemset name for this directory", default_gemset)
                info " ==>  configuring RVM gemset file '#{files[:gemsetfile]}' with content '#{g}'"
                File.open( File.join(rootdir, files[:gemsetfile]), 'w') do |f|
                    f.puts g
                end
                exit_status = (File.exists?(file) and `cat #{file}`.chomp == g) ? 0 : 1
                FalkorLib::Git.add(File.join(rootdir, files[:gemsetfile])) if use_git
            end
            # ==== Gemfile ===
            gemfile = File.join(rootdir, 'Gemfile')
            unless File.exists?( gemfile )
                # Dir.chdir(rootdir) do
                #     run %{ bundle init }
                # end
                info " ==>  configuring Gemfile with Falkorlib"
                File.open( gemfile, 'a') do |f|
                    f.puts "source 'https://rubygems.org'"
                    f.puts ""
                    f.puts "gem 'falkorlib' #, :path => '~/git/github.com/Falkor/falkorlib'"
                end
                FalkorLib::Git.add(gemfile) if use_git
            end
            exit_status
        end # rvm

        ###### repo ######
        # Initialize a Git repository for a project with my favorite layout
        # Supported options:
        # * :no_interaction [boolean]: do not interact
        # * :gitflow     [boolean]: bootstrap with git-flow
        # * :interactive [boolean] Confirm Gitflow branch names
        # * :master      [string]  Branch name for production releases
        # * :develop     [string]  Branch name for development commits
        # * :make        [boolean] Use a Makefile to pilot the repository actions
        # * :rake        [boolean] Use a Rakefile (and FalkorLib) to pilot the repository action
        # * :remote_sync [boolean] Operate a git remote synchronization
        # * :latex       [boolean] Initiate a LaTeX project
        # * :gem         [boolean] Initiate a Ruby gem project
        # * :rvm         [boolean] Initiate a RVM-based Ruby project
        # * :pyenv       [boolean] Initiate a pyenv-based Python project
        # * :octopress   [boolean] Initiate an Octopress web site
        ##
        def repo(name, options = {})
            ap options if options[:debug]
            path    = normalized_path(name)
            project = File.basename(path)
            use_git = FalkorLib::Git.init?(path)
            if options[:rake]
                options[:make] = false
                options[:rvm]  = true
            end
            info "Bootstrap a [Git] repository for the project '#{project}'"
            if use_git
                warning "Git is already initialized for the repository '#{name}'"
                really_continue? unless options[:force]
            end
            if options[:git_flow]
                info " ==> initialize Git flow in #{path}"
                FalkorLib::GitFlow.init(path, options)
                gitflow_branches = {}
                [ :master, :develop ].each do |t|
                    gitflow_branches[t.to_sym] = FalkorLib::GitFlow.branches(t, path)
                end
            else
                FalkorLib::Git.init(path, options)
            end
            # === prepare Git submodules ===
            info " ==> prepare the relevant Git submodules"
            submodules = {}
            #'gitstats' => { :url => 'https://github.com/hoxu/gitstats.git' }
            #             }
            if options[:make]
                submodules['Makefiles'] = {
                                           :url    => 'https://github.com/Falkor/Makefiles.git',
                                           :branch => 'devel'
                                          }
            end
            FalkorLib::Git.submodule_init(path, submodules)
            # === Prepare root [M|R]akefile ===
            if options[:make]
                info " ==> prepare Root Makefile"
                makefile = File.join(path, "Makefile")
                unless File.exist?( makefile )
                    src_makefile = File.join(path, FalkorLib.config.git[:submodulesdir],
                                             'Makefiles', 'repo', 'Makefile')
                    FileUtils.cp src_makefile, makefile
                    info "adapting Makefile to the gitflow branches"
                    Dir.chdir( path ) do
                        run %{
   sed -i '' \
        -e \"s/^GITFLOW_BR_MASTER=production/GITFLOW_BR_MASTER=#{gitflow_branches[:master]}/\" \
        -e \"s/^GITFLOW_BR_DEVELOP=devel/GITFLOW_BR_DEVELOP=#{gitflow_branches[:develop]}/\" \
        Makefile
                        }
                    end
                    FalkorLib::Git.add(makefile, 'Initialize root Makefile for the repo')
                else
                    puts "  ... not overwriting the root Makefile which already exists"
                end
            end
            if options[:rake]
                info " ==> prepare Root Rakefile"
                rakefile = File.join(path, "Rakefile")
                unless File.exist?( rakefile )
                    templatedir = File.join( FalkorLib.templates, 'Rakefile')
                    erbfiles = [ 'header_rakefile.erb' ]
                    erbfiles << 'rakefile_gitflow.erb' if FalkorLib::GitFlow.init?(path)
                    erbfiles << 'footer_rakefile.erb'
                    write_from_erb_template(erbfiles, rakefile, {}, { :srcdir => "#{templatedir}" })
                end
            end

            # === VERSION file ===
            FalkorLib::Bootstrap.versionfile(path, :tag => 'v0.0.0')

            # === RVM ====
            FalkorLib::Bootstrap.rvm(path, options) if options[:rvm]

            # === README ===
            FalkorLib::Bootstrap.readme(path, options)

            #===== remote synchro ========
            if options[:remote_sync]
                remotes  = FalkorLib::Git.remotes(path)
                if remotes.include?( 'origin' )
                    info "perform remote synchronization"
                    [ :master, :develop ].each do |t|
                        FalkorLib::Git.publish(gitflow_branches[t.to_sym], path, 'origin')
                    end
                else
                    warning "no Git remote  'origin' found, thus no remote synchronization performed"
                end
            end

        end # repo

        ###### versionfile ######
        # Bootstrap a VERSION file at the root of a project
        # Supported options:
        # * :file    [string] filename
        # * :version [string] version to mention in the file
        ##
        def versionfile(dir = Dir.pwd, options = {})
            file    = options[:file]    ? options[:file]    : 'VERSION'
            version = options[:version] ? options[:version] : '0.0.0'
            info " ==> bootstrapping a VERSION file"
            path = normalized_path(dir)
            path = FalkorLib::Git.rootdir(path) if FalkorLib::Git.init?(path)
            unless Dir.exists?( path )
                warning "The directory #{path} does not exists and will be created"
                really_continue?
                FileUtils.mkdir_p path
            end
            versionfile = File.join(path, file)
            unless File.exists?( versionfile )
                FalkorLib::Versioning.set_version(version, path, {
                                                                  :type => 'file',
                                                                  :source => { :filename => file }
                                                                 })
                Dir.chdir( path ) do
                    run %{ git tag #{options[:tag]} } if options[:tag]
                end
            else
                puts "  ... not overwriting the #{file} file which already exists"
            end

            # unless File.exists?( versionfile )
            #     run %{  echo "#{version}" > #{versionfile} }
            #     if FalkorLib::Git.init?(path)
            #         FalkorLib::Git.add(versionfile, "Initialize #{file} file")
            #         Dir.chdir( path ) do
            #             run %{ git tag #{options[:tag]} } if options[:tag]
            #         end
            #     end
            # else
            #     puts "  ... not overwriting the #{file} file which already exists"
            # end
        end # versionfile


        ###### motd ######
        # Generate a new motd (Message of the Day) file
        # Supported options:
        #  * :force [boolean] force action
        ##
        def motd(dir = Dir.pwd, options = {})
            config = FalkorLib::Config::Bootstrap::DEFAULTS[:motd].merge!(options)
            path = normalized_path(dir)
            erbfile = File.join( FalkorLib.templates, 'motd', 'motd.erb')
            outfile = (options[:file] =~ /^\//) ? options[:file] : File.join(path, options[:file])
            info "Generate a motd (Message of the Day) file '#{outfile}'"
            config[:os] = Facter.value(:lsbdistdescription) if Facter.value(:lsbdistdescription)
            config[:os] = "Mac " + Facter.value(:sp_os_version) if Facter.value(:sp_os_version)
            write_from_erb_template(erbfile, outfile, config, options)
        end # motd



        ###### readme ######
        # Bootstrap a README file for various context
        # Supported options:
        #  * :no_interaction [boolean]: do not interact
        #  * :force     [boolean] force overwritting
        #  * :latex     [boolean] describe a LaTeX project
        #  * :octopress [boolean] octopress site
        ##
        def readme(dir = Dir.pwd, options = {})
            info "Bootstrap a README file for this project"
            # get the local configuration
            local_config = FalkorLib::Config.get(dir)
            config = FalkorLib::Config::Bootstrap::DEFAULTS[:metadata].clone
            name = get_project_name(dir)
            if local_config[:project]
                config.deep_merge!( local_config[:project])
            else
                config[:name]     = ask("\tProject name: ", name) unless options[:name]
            end
            if options[:rake]
                options[:make] = false
                options[:rvm]  = true
            end
            config[:type] << :rvm  if options[:rake]
            # Type of project
            config[:type] << :latex if options[:latex]
            if config[:type].empty?
                t = select_from( FalkorLib::Config::Bootstrap::DEFAULTS[:types],
                                'Select the type of project to describe:', 1)
                config[:type] << t
                config[:type] << [ :ruby, :rvm ] if [ :gem, :rvm, :octopress, :puppet_module ].include?( t )
                config[:type] << :python if t == :pyenv
            end
            config[:type].uniq!
            ap config
            config[:type] = config[:type].uniq.flatten
            # Apply options (if provided)
            [ :name, :forge ].each do |k|
                config[k.to_sym] = options[k.to_sym] if options[k.to_sym]
            end
            path = normalized_path(dir)
            config[:filename] = options[:filename] ? options[:filename] : File.join(path, 'README.md')
            if ( FalkorLib::Git.init?(dir) && FalkorLib::Git.remotes(dir).include?( 'origin' ))
                config[:origin] = FalkorLib::Git.config('remote.origin.url')
                if config[:origin] =~ /((gforge|gitlab|github)[\.\w_-]+)[:\d\/]+(\w*)/
                    config[:forge] = $2.to_sym
                    config[:by]    = $3
                end
            else
                config[:forge] = select_forge(config[:forge]).to_sym if config[:forge].empty?
            end
            forges = FalkorLib::Config::Bootstrap::DEFAULTS[:forge][ config[:forge].to_sym ]
            #ap config
            default_source = case config[:forge]
                             when :gforge
                                 'https://' + forges[:url] + "/projects/" + name.downcase
                             when :github, :gitlab
                                 'https://' + forges[:url] + "/" + config[:by] + "/" + name.downcase
                             else
                                 ""
                             end
            FalkorLib::Config::Bootstrap::DEFAULTS[:metadata].each do |k,v|
                next if v.kind_of?(Array) or [ :license, :forge ].include?( k )
                next if k == :name and ! config[:name].empty?
                next if k == :issues_url and ! [ :github, :gitlab ].include?( config[:forge] )
                #next unless [ :name, :summary, :description ].include?(k.to_sym)
                default_answer = case k
                                 when :author
                                     (config[:by] == 'ULHPC') ? 'UL HPC Management Team' : config[:author]
                                 when :mail
                                     (config[:by] == 'ULHPC') ? 'hpc-sysadmins@uni.lu'   : config[:mail]
                                 when :description
                                     config[:description].empty? ? "#{config[:summary]}" : "#{config[:description]}"
                                 when :source
                                     config[:source].empty? ? default_source : "#{config[:source]}"
                                 when :project_page
                                     config[:source].empty? ? v : config[:source]
                                 when :issues_url
                                     config[:project_page].empty? ? v : "#{config[:project_page]}/issues"
                                 else
                                     config[k.to_sym].empty? ? v : config[k.to_sym]
                                 end
                config[k.to_sym] = ask( "\t" + sprintf("Project %-20s", "#{k}"), default_answer)
            end
            tags = ask("\tKeywords (comma-separated list of tags)", config[:tags].join(','))
            config[:tags]    = tags.split(',')
            config[:license] = select_licence() if config[:license].empty?
            # stack the ERB files required to generate the README
            templatedir = File.join( FalkorLib.templates, 'README')
            erbfiles = [ 'header_readme.erb',  ]
            [ :latex ].each do |type|
                erbfiles << "readme_#{type}.erb" if options[type.to_sym] and File.exist?( File.join(templatedir, "readme_#{type}.erb"))
            end
            erbfiles << "readme_issues.erb"
            erbfiles << "readme_git.erb"     if FalkorLib::Git.init?(dir)
            erbfiles << "readme_gitflow.erb" if FalkorLib::GitFlow.init?(dir)
            erbfiles << "readme_rvm.erb"     if config[:type].include?(:rvm)
            erbfiles << "footer_readme.erb"

            content = ""
            erbfiles.each do |f|
                erbfile = File.join(templatedir, f)
                content += ERB.new(File.read("#{erbfile}"), nil, '<>').result(binding)
            end
            show_diff_and_write(content, config[:filename], options)

            # Eventually save/upgrade local config
            info "=> saving customization of the FalkorLib configuration in #{FalkorLib.config[:config_files][:local]}"
            really_continue?
            FalkorLib::Config::Bootstrap::DEFAULTS[:metadata].keys.each do |k|
                local_config[:project] = {} unless local_config[:project]
                local_config[:project][k.to_sym] = config[k.to_sym]
            end
            if FalkorLib::GitFlow.init?(dir)
                local_config[:gitflow]  = {} unless local_config[:gitflow]
                local_config[:gitflow][:branches] = FalkorLib.config[:gitflow][:branches].clone unless local_config[:gitflow][:branches]
                [ :master, :develop ].each do |b|
                    local_config[:gitflow][:branches][b.to_sym] = FalkorLib::GitFlow.branches(b.to_sym)
                end
            end
            FalkorLib::Config.save(dir, local_config, :local)
            #
        end # readme



        ###### latex ######
        # Bootstrap a LaTeX sub-project of type <type> within a given repository <dir>.
        # Supported types:
        #  * :beamer    LaTeX Beamer Slides
        #  * :article   LaTeX article
        #  * :letter    LaTeX Letter
        # Supported options:
        #  * :force [boolean] force action
        ##
        def latex(dir = Dir.pwd, type = :beamer, options = {})
            ap options if options[:debug]
            print_error_and_exit "Unsupported type" unless [ :beamer, :article, :letter ].include?( type )
            path   = normalized_path(dir)
            config = FalkorLib::Config::Bootstrap::DEFAULTS[:latex].clone
            if type == :letter
              config.merge!(FalkorLib::Config::Bootstrap::DEFAULTS[:letter].clone)
              [ :title, :subtitle, :image ].each { |k| config.delete k }
            end
            config.deep_merge!(FalkorLib::Config::Bootstrap::DEFAULTS[:letter].clone) if type == :letter
            # initiate the repository if needed
            unless File.directory?( path )
                warn "The directory '#{path}' does not exists and will be created"
                really_continue? unless options[:force]
                run %{ mkdir -p #{path} }
            end
            repo(path, options) unless FalkorLib::Git.init?(path)
            rootdir = FalkorLib::Git.rootdir(path)
            info "Initiate a LaTeX #{type} project from the Git root directory: '#{rootdir}'"
            really_continue? unless options[:force]
            relative_path_to_root = (Pathname.new( FalkorLib::Git.rootdir(dir) ).relative_path_from Pathname.new( File.realpath(path))).to_s
            config[:name] = options[:name] ? options[:name] : ask("\tEnter the name of the #{type} LaTeX project: ", File.basename(path))
            raise FalkorLib::ExecError "Empty project name" if config[:name].empty?
            default_project_dir =  (Pathname.new( File.realpath(path) ).relative_path_from Pathname.new( FalkorLib::Git.rootdir(dir))).to_s
            if relative_path_to_root == '.'
                default_project_dir = case type
                                      when :article
                                          "articles/#{Time.now.year}/#{config[:name]}"
                                      when :beamer
                                          "slides/#{Time.now.year}/#{config[:name]}"
                                      when :bookchapter
                                          "chapters/#{config[:name]}"
                                      when :letter
                                          "letters/#{Time.now.year}/#{config[:name]}"
                                      else
                                          "#{config[:name]}"
                                      end
            else
                default_project_dir += "/#{config[:name]}" unless default_project_dir =~ /#{config[:name]}$/
            end
            project_dir = options[:dir] ? options[:dir] : ask("\tLaTeX Sources directory (relative to the Git root directory)", "#{default_project_dir}")
            raise FalkorLib::ExecError "Empty project directory" if project_dir.empty?
            src_project_dir = File.join(project_dir, 'src')
            srcdir = File.join(rootdir, src_project_dir)
            if File.exists?(File.join(srcdir, '.root'))
                warn "The directory '#{project_dir}' seems to have been already initialized"
                really_continue? unless options[:force]
            end
            FalkorLib::GitFlow.start('feature', config[:name], rootdir) if FalkorLib::GitFlow.init?(rootdir)
            # === prepare Git submodules ===
            info " ==> prepare the relevant Git submodules"
            submodules = {}
            submodules['Makefiles'] = { :url   => 'https://github.com/Falkor/Makefiles.git',
                                       :branch => 'devel'
                                      } if [ :article, :beamer, :bookchapter].include?(type)
            submodules['beamerthemeFalkor'] = { :url => 'https://github.com/Falkor/beamerthemeFalkor' } if type == :beamer
            FalkorLib::Git.submodule_init(rootdir, submodules)
            info "bootstrapping the #{type} project sources in '#{src_project_dir}'"
            # Create the project directory
            Dir.chdir( rootdir ) do
                run %{ mkdir -p #{src_project_dir}/images } unless File.directory?("#{srcdir}/images")
            end
            info "populating '#{src_project_dir}'"
            #FalkorLib::Bootstrap::Link.root(srcdir, { :verbose => true} )
            FalkorLib::Bootstrap::Link.makefile(srcdir, { :no_interaction => true })
            [ '_style.sty', '.gitignore' ].each do |f|
              Dir.chdir( srcdir ) do
                dst = ".makefile.d/latex/#{f}"
                run %{ ln -s #{dst} #{f} } unless File.exist?( File.join(srcdir, f) )
              end
            end
            if type == :beamer
              f = 'beamerthemeFalkor.sty'
              dst = "#{FalkorLib.config[:git][:submodulesdir]}/beamerthemeFalkor/#{f}"
              Dir.chdir( srcdir ) do
                run %{ ln -s .root/#{dst} #{f} } unless File.exist?( File.join(srcdir, f) )
              end
            end

            # Bootstrap the directory
            templatedir = File.join( FalkorLib.templates, 'latex', "#{type}")
            unless File.exists?( File.join(srcdir, "#{config[:name]}.tex"))
                info "gathering information for the LaTeX templates"
                prefix = case type
                         when :article
                             'Article '
                         when :beamer
                             'Slides '
                         when :bookchapter
                             'Book Chapter '
                         when :letter
                             'Letter '
                         else
                             ''
                         end
                config.each do |k,v|
                    next if k == :name
                    config[k.to_sym] = ask( "\t" + sprintf("%-20s", "#{prefix}#{k.capitalize}"), v)
                end
                init_from_template(templatedir, srcdir, config, {:no_interaction => true,
                                                                 :no_commit      => true })
                # Rename the main file
                Dir.chdir( srcdir ) do
                    run %{ mv main.tex #{config[:name]}.tex }
                end
            end
            # Create the trash directory
            trash(srcdir)

            # populate the images/ directory
            baseimages  = File.join( FalkorLib.templates, 'latex', 'images')
            #images_makefile_src = "#{FalkorLib.config[:git][:submodulesdir]}/Makefiles/generic/Makefile.insrcdir"
            images = File.join(srcdir, 'images')
            info "populating the image directory"
            Dir.chdir( images ) do
                run %{ rsync -avzu #{baseimages}/ . }
                run %{ ln -s ../.root .root } unless File.exists?(File.join(images, '.root'))
                #run %{ ln -s .root/#{images_makefile_src} Makefile } unless File.exists?(File.join(images, 'Makefile'))
            end
            FalkorLib::Bootstrap::Link.makefile(images, { :images => true, :no_interaction => true } )

            # Prepare the src/ directory
            FalkorLib::Bootstrap::Link.makefile(File.join(rootdir, project_dir), { :src => true, :no_interaction => true } )


            # default_project_dir = case type
            #               when :beamer
            #                   "slides/#{Time.new.yea}"
            #               end
        end # project


        ###
        # Select the forge (gforge, github, etc.) hosting the project sources
        ##
        def select_forge(default = :gforge, options = {})
            forge = FalkorLib::Config::Bootstrap::DEFAULTS[:forge]
            #ap forge
            default_idx = forge.keys.index(default)
            default_idx = 0 if default_idx.nil?
            v = select_from(forge.map{ |k,v| v[:name] },
                            "Select the Forge hosting the project sources",
                            default_idx+1,
                            forge.keys)
            v
        end # select_forge

        ###### select_licence ######
        # Select a given licence for the project
        ##
        def select_licence(default_licence = FalkorLib::Config::Bootstrap::DEFAULTS[:metadata][:license],
                           options = {})
            list_license    = FalkorLib::Config::Bootstrap::DEFAULTS[:licenses].keys
            idx = list_license.index(default_licence) unless default_licence.nil?
            select_from(list_license,
                        'Select the license index for this project:',
                        idx.nil? ? 1 : idx + 1)
            #licence
        end # select_licence

        ###### get_badge ######
        # Return a Markdown-formatted string for a badge to display, typically in a README.
        # Based on http://shields.io/
        # Supported options:
        #  * :style [string] style of the badge, Elligible: ['plastic', 'flat', 'flat-square']
        ##
        def get_badge(subject, status, color = 'blue', options = {})
            st = status.gsub(/-/, '--').gsub(/_/, '__')
            res = "https://img.shields.io/badge/#{subject}-#{st}-#{color}.svg"
            res += "?style=#{options[:style]}" if options[:style]
            res
        end # get_licence_badge

        ###### get_project_name ######
        # Return a "reasonable" project name from a given [sub] directory i.e. its basename
        ##
        def get_project_name(dir = Dir.pwd, options = {})
            path = normalized_path(dir)
            path = FalkorLib::Git.rootdir(path) if FalkorLib::Git.init?(path)
            File.basename(path)
        end # get_project_name


    end # module Bootstrap
end # module FalkorLib
