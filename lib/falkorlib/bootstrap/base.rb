# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Lun 2015-03-09 17:07 svarrette>
################################################################################
# Interface for the main Bootstrapping operations
#

require "falkorlib"
require "falkorlib/common"
require 'erb'      # required for module generation
require 'artii'

include FalkorLib::Common

module FalkorLib  #:nodoc:
    module Config

        # Default configuration for Bootstrapping processes
        module Bootstrap
            DEFAULTS =
              {
               :metadata => {
                             :name         => '',
                             :type         => [],
                             :author       => "#{ENV['GIT_AUTHOR_NAME']}",
                             :mail         => "#{ENV['GIT_AUTHOR_EMAIL']}",
                             :summary      => "rtfm",
                             :description  => '',
                             :forge        => :gforge,
                             :source       => '',
                             :project_page => '',
                             :license      => '',
                             :issues_url   => '',
                             :tags         => []
                            },
               :trashdir => '.Trash',
               :types    => [ :none, :latex, :gem, :octopress, :puppet_module, :rvm, :pyenv ],
               :licenses => {
                             "none"       => {},
                             "Apache-2.0" => {
                                              :url  => "http://www.apache.org/licenses/LICENSE-2.0",
                                              :logo => "https://www.apache.org/images/feather-small.gif"
                                             },
                             "BSD"        => {
                                              :url  => "http://www.linfo.org/bsdlicense.html",
                                              :logo => "http://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/License_icon-bsd.svg/200px-License_icon-bsd.svg.png"
                                             },
                             "CC by-nc-sa" => {
                                               :name => "Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International",
                                               :url  => "http://creativecommons.org/licenses/by-nc-sa/4.0",
                                               :logo => "https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png"
                                              },
                             "GPL-2.0"    => {
                                              :url  => "http://www.gnu.org/licenses/gpl-2.0.html",
                                              :logo => "https://licensebuttons.net/l/GPL/2.0/88x62.png"
                                             },
                             "GPL-3.0"    => {
                                              :url  => "http://www.gnu.org/licenses/gpl-3.0.html",
                                              :logo => "https://www.gnu.org/graphics/gplv3-88x31.png",
                                             },
                             "LGPL-2.1"   => {
                                              :url  => "https://www.gnu.org/licenses/lgpl-2.1.html",
                                              :logo => "https://licensebuttons.net/l/LGPL/2.1/88x62.png",
                                             },
                             "LGPL-3.0"   => {
                                              :url  => "https://www.gnu.org/licenses/lgpl.html",
                                              :logo => "https://www.gnu.org/graphics/lgplv3-88x31.png",
                                             },
                             "MIT"        => {
                                              :url  => "http://opensource.org/licenses/MIT",
                                              :logo => "http://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/License_icon-mit-2.svg/200px-License_icon-mit-2.svg.png"
                                             },
                            },
               :puppet   => {},
               :forge => {
                          :none   => { :url => '', :name => "None"},
                          :gforge => { :url => 'https://gforge.uni.lu', :name => 'GForge @ Uni.lu' },
                          :github => { :url => 'https://github.com',    :name => 'Github', :login => "#{`whoami`.chomp.capitalize}" },
                          :gitlab => { :url => 'https://gitlab.uni.lu', :name => 'Gitlab @ Uni.lu' },
                         },
              }


        end
    end
end



module FalkorLib
    module Bootstrap
        module_function

        ###
        # Initialize a trash directory in path
        ##
        def trash(path = Dir.pwd, dirname = FalkorLib.config[:templates][:trashdir], options = {})
            #args = method(__method__).parameters.map { |arg| arg[1].to_s }.map { |arg| { arg.to_sym => eval(arg) } }.reduce Hash.new, :merge
            #ap args
            exit_status = 0
            trashdir = File.join(path, dirname)
            if Dir.exists?(trashdir)
                warning "The trash directory '#{dirname}' already exists"
                return 1
            end
            Dir.chdir(path) do
                info "creating the trash directory '#{dirname}'"
                exit_status = run %{
          mkdir -p #{dirname}
          echo '*' > #{dirname}/.gitignore
                }
                if FalkorLib::Git.init?(path)
                    exit_status = FalkorLib::Git.add(File.join(path, dirname, '.gitignore' ),
                                                     'Add Trash directory',
                                                     { :force => true } )
                end
            end
            exit_status.to_i
        end # trash

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
            options[:make] = false if options[:rake]
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
            submodules = {
                          'gitstats' => { :url => 'https://github.com/hoxu/gitstats.git' }
                         }
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
                        FalkorLib::Git.publish(gitflow_branch[t.to_sym], path, 'origin')
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
            if local_config[:project]
                config.deep_merge!( local_config[:project])
            else
                config[:name]     = ask("\tProject name: ", get_project_name(dir)) unless options[:name]
            end
            # Type of project
            config[:type] << :latex if options[:latex]
            if config[:type].empty?
                t = select_from( FalkorLib::Config::Bootstrap::DEFAULTS[:types],
                                'Select the type of project to describe:', 1)
                config[:type] << t
                config[:type] << [ :ruby, :rvm ] if [ :gem, :rvm, :octopress, :puppet_module ].include?( t )
                config[:type] << :python if t == :pyenv
            end
            config[:type] = config[:type].uniq.flatten
            # Apply options (if provided)
            [ :name, :forge ].each do |k|
                config[k.to_sym] = options[k.to_sym] if options[k.to_sym]
            end
            path = normalized_path(dir)
            config[:filename] = options[:filename] ? options[:filename] : File.join(path, 'README.md')
            config[:forge] = select_forge(config[:forge]).to_sym if config[:forge].empty?
            forges = FalkorLib::Config::Bootstrap::DEFAULTS[:forge][ config[:forge].to_sym ]
            default_source = case config[:forge]
                             when :gforge
                                 forges[:url] + "/projects/" + config[:name].downcase
                             when :github
                                 forges[:url] + "/" + forges[:login] + "/" + config[:name].downcase
                             when :gitlab
                                 forges[:url] + "/" + forges[:name].downcase
                             end

            FalkorLib::Config::Bootstrap::DEFAULTS[:metadata].each do |k,v|
                next if v.kind_of?(Array) or [ :license, :forge ].include?( k )
                next if k == :name and ! name.empty?
                next if k == :issues_url and ! [ :github, :gitlab ].include?( config[:forge] )
                #next unless [ :name, :summary, :description ].include?(k.to_sym)
                default_answer = case k
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
