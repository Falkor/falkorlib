# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Sun 2020-04-12 10:42 svarrette>
################################################################################
# Interface for the main Bootstrapping operations
#

require "falkorlib"
require "falkorlib/common"
require "falkorlib/bootstrap"

require 'erb' # required for module generation
require 'artii'
require 'facter'

include FalkorLib::Common

module FalkorLib #:nodoc:
  module Config
    # Default configuration for Bootstrapping processes
    module Bootstrap

      DEFAULTS =
        {
          :gitcrypt => {
            :owner    => `git config user.signingKey`.chomp,
            :subkeys  => [],
            :hooksdir => 'config/hooks',
            :hook     => 'pre-commit.git-crypt.sh',
            :ulhpc    => [
              #'Ox5D08BCDD4F156AD7',  # S. Varrette
              '0x3F3242C5B34D98C2',   # V. Plugaru
              '0x6429C2514EBC4737',   # S. Peter
              '0x07FEA8BA69203C2D',   # C. Parisot
              '0x37183CEF550DF40B',   # H. Cartiaux
            ],
            # :hooks    => {
            #   :precommit => 'https://gist.github.com/848c82daa63710b6c132bb42029b30ef.git',
            # },
          },
          :motd => {
            :file     => 'motd',
            :hostname => `hostname -f`.chomp,
            :title    => "Title",
            :desc     => "Brief server description",
            :support  => `git config user.email`.chomp,
            :width    => 80
          },
          :latex => {
            :name     => '',
            :author   => `git config user.name`.chomp,
            :mail     => `git config user.email`.chomp,
            :title    => 'Title',
            :subtitle => 'Overview and Open Challenges',
            :image    => 'images/logo_ULHPC.pdf',
            :logo     => 'images/logo_UL.pdf',
            :url      => 'http://csc.uni.lu/sebastien.varrette'
          },
          :letter => {
            :author_title    => 'PhD',
            :institute       => 'University of Luxembourg',
            :department      => 'Parallel Computing and Optimization Group',
            :department_acro => 'PCOG',
            :address         => '7, rue Richard Coudenhove-Kalergie',
            :zipcode         => 'L-1359',
            :location        => 'Luxembourg',
            :phone           => '(+352) 46 66 44 6600',
            :twitter         => 'svarrette',
            :linkedin        => 'svarrette',
            :skype           => 'sebastien.varrette',
            :scholar         => '6PTStIcAAAAJ'
          },
          :metadata => {
            :name         => '',
            :type         => [],
            :by           => (ENV['USER']).to_s,
            :author       => `git config user.name`.chomp,
            :mail         => `git config user.email`.chomp,
            :summary      => "rtfm",
            :description  => '',
            :forge        => '',
            :source       => '',
            :project_page => '',
            :origin       => '',
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
            "BSD" => {
              :url  => "http://www.linfo.org/bsdlicense.html",
              :logo => "http://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/License_icon-bsd.svg/200px-License_icon-bsd.svg.png"
            },
            "CC-by-nc-sa" => {
              :name => "Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International",
              :url  => "http://creativecommons.org/licenses/by-nc-sa/4.0",
              :logo => "https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png"
            },
            "GPL-2.0" => {
              :url  => "http://www.gnu.org/licenses/gpl-2.0.html",
              :logo => "https://licensebuttons.net/l/GPL/2.0/88x62.png"
            },
            "GPL-3.0" => {
              :url  => "http://www.gnu.org/licenses/gpl-3.0.html",
              :logo => "https://www.gnu.org/graphics/gplv3-88x31.png"
            },
            "LGPL-2.1" => {
              :url  => "https://www.gnu.org/licenses/lgpl-2.1.html",
              :logo => "https://licensebuttons.net/l/LGPL/2.1/88x62.png"
            },
            "LGPL-3.0" => {
              :url  => "https://www.gnu.org/licenses/lgpl.html",
              :logo => "https://www.gnu.org/graphics/lgplv3-88x31.png"
            },
            "MIT" => {
              :url  => "http://opensource.org/licenses/MIT",
              :logo => "http://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/License_icon-mit-2.svg/200px-License_icon-mit-2.svg.png"
            }
          },
          :puppet => {},
          :forge => {
            :none   => { :url => '', :name => "None" },
            :gforge => { :url => 'gforge.uni.lu', :name => 'GForge @ Uni.lu' },
            :github => { :url => 'github.com',    :name => 'Github', :login => (`whoami`.chomp.capitalize).to_s },
            :gitlab => { :url => 'gitlab.uni.lu', :name => 'Gitlab @ Uni.lu', :login => (`whoami`.chomp.capitalize).to_s }
          },
          :vagrant => {
            :os     => :centos7,
            :ram    => 1024,
            :vcpus  => 2,
            :domain => 'vagrant.dev',
            :range  => '10.10.1.0/24',
            :boxes => {
              :centos7  => 'centos/7',
              :debian8  => 'debian/contrib-jessie64',
              :ubuntu14 => 'ubuntu/trusty64'
            },
          }
        }

    end
  end
end



module FalkorLib
  module Bootstrap #:nodoc:

    module_function

    ###### makefile ######
    # Supported options:
    # * :master  [string] git flow master/production branch
    # * :develop [string] git flow development branch
    # * :force   [boolean] for overwritting
    #......................................
    def makefile(dir = Dir.pwd, options = {})
      path = normalized_path(dir)
      path = FalkorLib::Git.rootdir(path) if FalkorLib::Git.init?(path)
      info "=> Setup a root repository makefile in '#{dir}'"
      # Preparing submodule
      submodules = {}
      submodules['Makefiles'] = {
        :url    => 'https://github.com/Falkor/Makefiles.git',
        :branch => 'devel'
      }
      FalkorLib::Git.submodule_init(path, submodules)
      makefile = File.join(path, "Makefile")
      if File.exist?( makefile )
        puts "  ... not overwriting the root Makefile which already exists"
      else
        src_makefile = File.join(path, FalkorLib.config.git[:submodulesdir],
                                 'Makefiles', 'repo', 'Makefile')
        FileUtils.cp src_makefile, makefile
        gitflow_branches = FalkorLib::Config::GitFlow::DEFAULTS[:branches]
        if FalkorLib::GitFlow.init?(path)
          [ :master, :develop ].each do |b|
            gitflow_branches[b.to_sym] = FalkorLib::GitFlow.branches(b.to_sym)
          end
        end
        unless options.nil?
          [ :master, :develop ].each do |b|
            gitflow_branches[b.to_sym] = options[b.to_sym] if options[b.to_sym]
          end
        end
        info "adapting Makefile to the gitflow branches"
        Dir.chdir( path ) do
          run %(
   sed -i '' \
        -e \"s/^GITFLOW_BR_MASTER=production/GITFLOW_BR_MASTER=#{gitflow_branches[:master]}/\" \
        -e \"s/^GITFLOW_BR_DEVELOP=devel/GITFLOW_BR_DEVELOP=#{gitflow_branches[:develop]}/\" \
        Makefile
                        )
        end
        FalkorLib::Git.add(makefile, 'Initialize root Makefile for the repo')
      end
    end # makefile


    ###
    # Initialize a trash directory in path
    ##
    def trash(path = Dir.pwd, dirname = FalkorLib.config[:templates][:trashdir], _options = {})
      #args = method(__method__).parameters.map { |arg| arg[1].to_s }.map { |arg| { arg.to_sym => eval(arg) } }.reduce Hash.new, :merge
      #ap args
      exit_status = 0
      trashdir = File.join(File.realpath(path), dirname)
      if Dir.exist?(trashdir)
        warning "The trash directory '#{dirname}' already exists"
        return 1
      end
      Dir.chdir(path) do
        info "creating the trash directory '#{dirname}'"
        exit_status = run %(
          mkdir -p #{dirname}
          echo '*' > #{dirname}/.gitignore
                )
        if FalkorLib::Git.init?(path)
          exit_status = FalkorLib::Git.add(File.join(trashdir.to_s, '.gitignore' ),
                                           'Add Trash directory',
                                           :force => true )
        end
      end
      exit_status.to_i
    end # trash

    ###### versionfile ######
    # Bootstrap a VERSION file at the root of a project
    # Supported options:
    # * :file    [string] filename
    # * :version [string] version to mention in the file
    ##
    def versionfile(dir = Dir.pwd, options = {})
      file    = (options[:file])    ? options[:file]    : 'VERSION'
      version = (options[:version]) ? options[:version] : '0.0.0'
      info " ==> bootstrapping a VERSION file"
      path = normalized_path(dir)
      path = FalkorLib::Git.rootdir(path) if FalkorLib::Git.init?(path)
      unless Dir.exist?( path )
        warning "The directory #{path} does not exists and will be created"
        really_continue?
        FileUtils.mkdir_p path
      end
      versionfile = File.join(path, file)
      if File.exist?( versionfile )
        puts "  ... not overwriting the #{file} file which already exists"
      else
        FalkorLib::Versioning.set_version(version, path, :type => 'file',
                                          :source => { :filename => file })
        Dir.chdir( path ) do
          run %( git tag #{options[:tag]} ) if options[:tag]
        end
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
    #  * :force    [boolean] force action
    #  * :title    [string]  title of the motd (in figlet)
    #  * :support  [string]  email address to use for  getting support
    #  * :hostname [string]  hostname of the server to mention in the motd
    #  * :width    [number]  width of the line used
    ##
    def motd(dir = Dir.pwd, options = {})
      config = FalkorLib::Config::Bootstrap::DEFAULTS[:motd].merge!(::ActiveSupport::HashWithIndifferentAccess.new(options).symbolize_keys)
      path = normalized_path(dir)
      erbfile = File.join( FalkorLib.templates, 'motd', 'motd.erb')
      outfile = (config[:file] =~ /^\//) ? config[:file] : File.join(path, config[:file])
      info "Generate a motd (Message of the Day) file '#{outfile}'"
      FalkorLib::Config::Bootstrap::DEFAULTS[:motd].keys.each do |k|
        next if [:file, :width].include?(k)
        config[k.to_sym] = ask( "\t" + format("Message of the Day (MotD) %-10s", k.to_s), config[k.to_sym]) unless options[:no_interaction]
      end
      config[:os] = Facter.value(:lsbdistdescription) if Facter.value(:lsbdistdescription)
      config[:os] = "Mac " + Facter.value(:sp_os_version) if Facter.value(:sp_os_version)
      unless options[:nodemodel]
        config[:nodemodel] = Facter.value(:sp_machine_name) if Facter.value(:sp_machine_name)
        config[:nodemodel] += " (#{Facter.value(:sp_cpu_type)}" if Facter.value(:sp_cpu_type)
        config[:nodemodel] += " " + Facter.value(:sp_current_processor_speed) if Facter.value(:sp_current_processor_speed)
        config[:nodemodel] += " #{Facter.value(:sp_number_processors)} cores )" if Facter.value(:sp_number_processors)
      end
      config[:nodemodel] = Facter.value(:sp_machine_name) unless options[:nodemodel]
      write_from_erb_template(erbfile, outfile, config, options)
    end # motd



    ###### readme ######
    # Bootstrap a README file for various context
    # Supported options:
    #  * :no_interaction [boolean]: do not interact
    #  * :force          [boolean] force overwritting
    #  * :license     [string]  License to use
    #  * :licensefile [string]  License filename (default: LICENSE)
    #  * :latex          [boolean] describe a LaTeX project
    #  * :octopress      [boolean] octopress site
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
        config[:name] = ask("\tProject name: ", name) unless options[:name]
      end
      if options[:rake]
        options[:make] = false
        options[:rvm]  = true
      end
      config[:license] = options[:license] if options[:license]
      config[:type] << :rvm if options[:rake]
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
      #ap config
      config[:type] = config[:type].uniq.flatten
      # Apply options (if provided)
      [ :name, :forge ].each do |k|
        config[k.to_sym] = options[k.to_sym] if options[k.to_sym]
      end
      path = normalized_path(dir)
      config[:filename] = (options[:filename]) ? options[:filename] : File.join(path, 'README.md')
      if ( FalkorLib::Git.init?(dir) && FalkorLib::Git.remotes(dir).include?( 'origin' ))
        config[:origin] = FalkorLib::Git.config('remote.origin.url')
        if config[:origin] =~ /((gforge|gitlab|github)[\.\w_-]+)[:\d\/]+(\w*)/
          config[:forge] = Regexp.last_match(2).to_sym
          config[:by]    = Regexp.last_match(3)
        end
      elsif config[:forge].empty?
        config[:forge] = select_forge(config[:forge]).to_sym
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
      FalkorLib::Config::Bootstrap::DEFAULTS[:metadata].each do |k, v|
        next if v.is_a?(Array) || [ :license, :forge ].include?( k )
        next if (k == :name) && !config[:name].empty?
        next if (k == :issues_url) && ![ :github, :gitlab ].include?( config[:forge] )
        #next unless [ :name, :summary, :description ].include?(k.to_sym)
        default_answer = case k
                         when :author
                           (config[:by] == 'ULHPC') ? 'UL HPC Team' : config[:author]
                         when :mail
                           (config[:by] == 'ULHPC') ? 'hpc-sysadmins@uni.lu'   : config[:mail]
                         when :description
                           (config[:description].empty?) ? (config[:summary]).to_s : (config[:description]).to_s
                         when :source
                           (config[:source].empty?) ? default_source : (config[:source]).to_s
                         when :project_page
                           (config[:source].empty?) ? v : config[:source]
                         when :issues_url
                           (config[:project_page].empty?) ? v : "#{config[:project_page]}/issues"
                         else
                           (config[k.to_sym].empty?) ? v : config[k.to_sym]
                         end
        config[k.to_sym] = ask( "\t" + Kernel.format("Project %-20s", k.to_s), default_answer)
      end
      tags = ask("\tKeywords (comma-separated list of tags)", config[:tags].join(','))
      config[:tags]    = tags.split(',')
      config[:license] = select_licence if config[:license].empty?
      # stack the ERB files required to generate the README
      templatedir = File.join( FalkorLib.templates, 'README')
      erbfiles = [ 'header_readme.erb' ]
      [ :latex ].each do |type|
        erbfiles << "readme_#{type}.erb" if options[type.to_sym] && File.exist?( File.join(templatedir, "readme_#{type}.erb"))
      end
      erbfiles << "readme_issues.erb"
      erbfiles << "readme_git.erb"     if FalkorLib::Git.init?(dir)
      erbfiles << "readme_gitflow.erb" if FalkorLib::GitFlow.init?(dir)
      erbfiles << "readme_rvm.erb"     if config[:type].include?(:rvm)
      erbfiles << "readme_mkdocs.erb"  if options[:mkdocs]
      erbfiles << "footer_readme.erb"

      content = ""
      ap options
      ap config
      erbfiles.each do |f|
        erbfile = File.join(templatedir, f)
        content += ERB.new(File.read(erbfile.to_s), nil, '<>').result(binding)
      end
      show_diff_and_write(content, config[:filename], options)

      # Force save/upgrade local config
      info "=> saving customization of the FalkorLib configuration in #{FalkorLib.config[:config_files][:local]}"
      # really_continue?
      FalkorLib::Config::Bootstrap::DEFAULTS[:metadata].keys.each do |k|
        local_config[:project] = {} unless local_config[:project]
        local_config[:project][k.to_sym] = config[k.to_sym]
      end
      if FalkorLib::GitFlow.init?(dir)
        local_config[:gitflow] = {} unless local_config[:gitflow]
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
    def select_forge(default = :gforge, _options = {})
      forge = FalkorLib::Config::Bootstrap::DEFAULTS[:forge]
      #ap forge
      default_idx = forge.keys.index(default)
      default_idx = 0 if default_idx.nil?
      v = select_from(forge.map { |_k, u| u[:name] },
                      "Select the Forge hosting the project sources",
                      default_idx + 1,
                      forge.keys)
      v
    end # select_forge

    ###### select_licence ######
    # Select a given licence for the project
    ##
    def select_licence(default_licence = FalkorLib::Config::Bootstrap::DEFAULTS[:metadata][:license],
                       _options = {})
      list_license = FalkorLib::Config::Bootstrap::DEFAULTS[:licenses].keys
      idx = list_license.index(default_licence) unless default_licence.nil?
      select_from(list_license,
                  'Select the license index for this project:',
                  (idx.nil?) ? 1 : idx + 1)
      #licence
    end # select_licence

    ###### license ######
    # Generate the licence file
    #
    # Supported options:
    #  * :force    [boolean] force action
    #  * :filename [string]  License file name
    #  * :organization [string]  Organization
    ##
    def license(dir = Dir.pwd,
                license = FalkorLib::Config::Bootstrap::DEFAULTS[:metadata][:license],
                authors = '',
                options = {
                  :filename     => 'LICENSE'
                })
      return if ((license.empty?) or (license == 'none') or (license =~ /^CC/))
      return unless FalkorLib::Config::Bootstrap::DEFAULTS[:licenses].keys.include?( license )
      info "Generate the #{license} licence file"
      path = normalized_path(dir)
      use_git = FalkorLib::Git.init?(path)
      rootdir = (use_git) ? FalkorLib::Git.rootdir(path) : path
      Dir.chdir( rootdir ) do
        run %( licgen #{license.downcase} #{authors} )
        run %( mv LICENSE #{options[:filename]} ) if( options[:filename] and options[:filename] != 'LICENSE')
      end
    end # license


    ###### guess_project_config ######
    # Guess the project configuration
    ##
    def guess_project_config(dir = Dir.pwd, options = {})
      path = normalized_path(dir)
      use_git = FalkorLib::Git.init?(path)
      rootdir = (use_git) ? FalkorLib::Git.rootdir(path) : path
      local_config = FalkorLib::Config.get(rootdir, :local)
      return local_config[:project] if local_config[:project]
      # Otherwise, guess the rest of the configuration
      config = FalkorLib::Config::Bootstrap::DEFAULTS[:metadata].clone
      # Apply options (if provided)
      [ :name, :forge ].each do |k|
        config[k.to_sym] = options[k.to_sym] if options[k.to_sym]
      end
      config[:name] = ask("\tProject name: ", get_project_name(dir)) if config[:name].empty?
      if (use_git)
        config[:origin] = FalkorLib::Git.config('remote.origin.url')
        if config[:origin] =~ /((gforge|gitlab|github)[\.\w_-]+)[:\d\/]+(\w*)/
          config[:forge] = Regexp.last_match(2).to_sym
          config[:by]    = Regexp.last_match(3)
        elsif config[:forge].empty?
          config[:forge] = select_forge(config[:forge]).to_sym
        end
      end
      forges = FalkorLib::Config::Bootstrap::DEFAULTS[:forge][ config[:forge].to_sym ]
      default_source = case config[:forge]
                       when :gforge
                         'https://' + forges[:url] + "/projects/" + config[:name].downcase
                       when :github, :gitlab
                         'https://' + forges[:url] + "/" + config[:by] + "/" + config[:name].downcase
                       else
                         ""
                       end
      config[:source] = config[:project_page] = default_source
      config[:issues_url] =  "#{config[:project_page]}/issues"
      config[:license] = select_licence if config[:license].empty?
      [ :summary  ].each do |k|
        config[k.to_sym] = ask( "\t" + Kernel.format("Project %-20s", k.to_s))
      end
      config[:description] = config[:summary]
      if FalkorLib::GitFlow.init?(rootdir)
        config[:gitflow] = FalkorLib::GitFlow.guess_gitflow_config(rootdir)
      end
      config[:make] = File.exists?(File.join(rootdir, 'Makefile'))
      config[:rake] = File.exists?(File.join(rootdir, 'Rakefile'))
      config
    end # guess_project_config


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
    def get_project_name(dir = Dir.pwd, _options = {})
      path = normalized_path(dir)
      path = FalkorLib::Git.rootdir(path) if FalkorLib::Git.init?(path)
      File.basename(path)
    end # get_project_name


  end # module Bootstrap
end # module FalkorLib
