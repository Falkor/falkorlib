# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Fri 2016-11-11 15:24 svarrette>
################################################################################
# Interface for the main Puppet Module operations
#

require "falkorlib"
require "falkorlib/common"

require "pathname"
require 'json'
require 'diffy'

include FalkorLib::Common

module FalkorLib #:nodoc:

  module Config
    module Puppet
      module Modules

        DEFAULTS = {
          :metadata => {
            :name         => '',
            :version      => '0.0.1',
            :author       => `git config user.name`.chomp,
            :mail         => `git config user.email`.chomp,
            :summary      => "Configure and manage rtfm",
            :description  => '',
            :license      => 'Apache-2.0',
            :source       => '',
            :project_page => '',
            :issues_url   => '',
            :forge_url    => 'https://forge.puppetlabs.com',
            :dependencies => [],
            :operatingsystem_support => [],
            :tags => []
          },
          :licenses => [
            "Apache-2.0",
            "BSD",
            "GPL-2.0",
            "GPL-3.0",
            "LGPL-2.1",
            "LGPL-3.0",
            "MIT"
          ]
        }

      end
    end
  end

  # Puppet actions
  module Puppet
    # Management of Puppet Modules operations
    module Modules

      module_function

      def _get_classdefs(moduledir = Dir.pwd, type = 'classes')
        name = File.basename( moduledir )
        error "The module #{name} does not exist" unless File.directory?( moduledir )
        t = case type
            when /class*/i
              'class'
            when /def*/
              'define'
            else
              ''
            end
        error "Undefined type #{type}" if t.empty?
        result = []
        Dir["#{moduledir}/manifests/**/*.pp"].each do |ppfile|
          #puts "=> testing #{ppfile}"
          File.read(ppfile).scan(/^[ \t]*#{t}[\s]+([0-9a-zA-z:-]+).*$/).each do |line|
            result << line[0]
          end
        end
        result.uniq!
        result.sort
      end


      ####
      # Initialize a new Puppet Module named `name` in `rootdir`.
      # Supported options:
      # * :no_iteraction [boolean]
      ##
      def init(rootdir = Dir.pwd, name = '', _options = {})
        config = {}
        #login = `whoami`.chomp
        config[:name] = name unless name.empty?
        moduledir     = rootdir
        #name.empty? ? rootdir : File.join(rootdir, name)
        FalkorLib::Config::Puppet::Modules::DEFAULTS[:metadata].each do |k, v|
          next if v.is_a?(Array) || (k == :license)
          next if (k == :name) && !name.empty?
          default_answer = case k
                           when :project_page
                             (config[:source].nil?) ? v : config[:source]
                           when :name
                             File.basename(rootdir).gsub(/^puppet-/, '')
                           when :issues_url
                             (config[:project_page].nil?) ? v : "#{config[:project_page]}/issues"
                           when :forge_url
                             v + '/' + config[:name].tr('-', '/')
                           when :description
                             (config[:summary].nil?) ? v : (config[:summary]).to_s
                           when :source
                             (v.empty?) ? "https://github.com/#{config[:name].gsub(/\//, '/puppet-')}" : v
                           else
                             v
                           end
          config[k.to_sym] = ask( "\t" + sprintf("%-20s", "Module #{k}"), default_answer)
        end
        config[:shortname] = name = config[:name].gsub(/.*[-\/]/, '')
        config[:docs_project] = ask("\tRead the Docs (RTFD) project:", config[:name].downcase.gsub(/\//, '-puppet-'))
        tags = ask("\tKeywords (comma-separated list of tags)", config[:shortname])
        config[:tags] = tags.split(',')
        list_license    = FalkorLib::Config::Puppet::Modules::DEFAULTS[:licenses]
        default_license = FalkorLib::Config::Puppet::Modules::DEFAULTS[:metadata][:license]
        idx = list_license.index(default_license) unless default_license.nil?
        license = select_from(list_license,
                              'Select the license index for the Puppet module:',
                              (idx.nil?) ? 1 : idx + 1)
        config[:license] = license unless license.empty?
        puts "\t" + sprintf("%-20s", "Module License:") + config[:license]

        # Supported platforms
        config[:platforms] = [ 'debian' ]
        config[:dependencies] = [{
          "name" => "puppetlabs-stdlib",
          "version_requirement" => ">=4.2.2 <5.0.0"
        }]
        config[:params] = %w(ensure protocol port packagename)
        #ap config
        # Bootstrap the directory
        templatedir = File.join( FalkorLib.templates, 'puppet', 'modules')
        init_from_template(templatedir, moduledir, config, :erb_exclude => [ 'templates\/[^\/]*variables\.erb$' ],
                                                           :no_interaction => true)
        # Rename the files / element templatename
        Dir["#{moduledir}/**/*"].each do |e|
          next unless e =~ /templatename/
          info "renaming #{e}"
          newname = e.gsub(/templatename/, name.to_s)
          run %( mv #{e} #{newname} )
        end
        # Update docs directory
        run %( ln -s ../README.md #{moduledir}/docs/overview.md )
        info "Generating the License file"
        authors = (config[:author].empty?) ? 'UNKNOWN' : config[:author]
        Dir.chdir(moduledir) do
          run %( licgen #{config[:license].downcase} #{authors} )
        end
        info "Initialize RVM"
        init_rvm(moduledir)
        unless FalkorLib::Git.init?(moduledir)
          init_gitflow = FalkorLib::Git.command?('flow')
          warn "Git #{(init_gitflow) ? '[Flow]' : ''} is not initialized in #{moduledir}."
          a = ask("Proceed to git-flow initialization (Y|n)", 'Yes')
          return if a =~ /n.*/i
          (init_gitflow) ? FalkorLib::GitFlow.init(moduledir) : FalkorLib::Git.init(moduledir)
        end

        # Propose to commit the key files
        if FalkorLib::Git.init?(moduledir)
          if FalkorLib::GitFlow.init?(moduledir)
            info "=> preparing git-flow feature for the newly created module '#{config[:name]}'"
            FalkorLib::GitFlow.start('feature', "bootstrapping", moduledir)
          end
          [ 'metadata.json',
            'docs/', 'mkdocs.yml', 'LICENSE', '.gitignore', '.pmtignore',
            '.ruby-version', '.ruby-gemset', 'Gemfile',
            '.vagrant_init.rb', 'Rakefile', 'Vagrantfile' ].each do |f|
            FalkorLib::Git.add(File.join(moduledir, f))
          end
        end
      end # init

      ####
      # Parse a given modules to collect information
      # Supported options:
      #   :no_interaction [boolean]: do not interact
      #
      def parse(moduledir = Dir.pwd, options = {
        :no_interaction => false
      })
        name = File.basename(moduledir)
        metadata = metadata(moduledir, :use_symbols => false,
                                       :extras         => false,
                                       :no_interaction => options[:no_interaction])
        puts metadata.to_yaml
        # error "The module #{name} does not exist" unless File.directory?( moduledir )
        jsonfile = File.join( moduledir, 'metadata.json')
        # error "Unable to find #{jsonfile}" unless File.exist?( jsonfile )
        # metadata = JSON.parse( IO.read( jsonfile ) )
        ref = JSON.pretty_generate( metadata )
        metadata["classes"]     = classes(moduledir)
        metadata["definitions"] = definitions(moduledir)
        deps        = deps(moduledir)
        listed_deps = metadata["dependencies"]
        missed_deps = []
        metadata["dependencies"].each do |dep|
          lib = dep["name"].gsub(/^[^\/-]+[\/-]/, '')
          if deps.include?( lib )
            deps.delete( lib )
          else
            unless lib =~ /stdlib/
              warn "The library '#{dep['name']}' is not analyzed as part of the #{metadata['shortname']} module"
              missed_deps << dep
            end
          end
        end
        unless deps.empty?
          deps.each do |l|
            next if [name, metadata["name"], name.gsub(/.*-/, ''), metadata["name"].gsub(/.*-/, '') ].include? ( l )
            warn "The module '#{l}' is missing in the dependencies thus added"
            login   = ask("[Github] login for the module '#{l}'")
            version = ask("Version requirement (ex: '>=1.0.0 <2.0.0' or '1.2.3' or '1.x')")
            metadata["dependencies"] << {
              "name"                => "#{login}/#{l}",
              "version_requirement" => version.to_s
            }
          end
        end
        content = JSON.pretty_generate( metadata )
        info "Metadata configuration for the module '#{name}'"
        puts content
        show_diff_and_write(content, jsonfile, :no_interaction => options[:no_interaction],
                                               :json_pretty_format => true)
        metadata
      end # parse

      ###
      # Retrieves the metadata from the metadata.json file in `moduledir`.
      # Supported options:
      #   :use_symbols [boolean]: convert all keys to symbols
      #   :extras  [boolean]: add extra keys
      #
      def metadata(moduledir = Dir.pwd, options = {
        :use_symbols => true,
        :extras => true,
        :no_interaction => false
      })
        add_extras = (options[:extras].nil?) ? true : options[:extras]
        name = File.basename( moduledir )
        error "The module #{name} does not exist" unless File.directory?( moduledir )
        jsonfile = File.join( moduledir, 'metadata.json')
        error "Unable to find #{jsonfile}" unless File.exist?( jsonfile )
        metadata = JSON.parse( IO.read( jsonfile ) )
        metadata["docs_project"] = ask("\tRead the Docs (RTFD) project:", (metadata['name'].downcase.gsub(/\//, '-puppet-')).to_s) if metadata["docs_project"].nil?
        if add_extras
          metadata[:shortname] = name.gsub(/.*-/, '')
          metadata[:platforms] = []
          metadata["operatingsystem_support"].each do |e|
            metadata[:platforms] << e["operatingsystem"].downcase unless e["operatingsystem"].nil?
          end
          # Analyse params
          params_manifest = File.join(moduledir, 'manifests', 'params.pp')
          if File.exist?(params_manifest)
            params = []
            File.read(params_manifest).scan(/^\s*\$(.*)\s*=/) do |_m|
              params << Regexp.last_match(1).gsub(/\s+$/, '') unless Regexp.last_match(1).nil?
            end
            metadata[:params] = params.uniq
          end
        end
        if options[:use_symbols]
          # convert string keys to symbols
          metadata.keys.each do |k|
            metadata[(begin
                        k.to_sym
                      rescue
                        k
                      end) || k] = metadata.delete(k)
          end
        end
        metadata
      end # metadata



      ##
      # Upgrade the key files (README etc.) of the puppet module hosted
      # in `moduledir` with the latest version of the FalkorLib template
      # Supported options:
      #   :no_interaction [boolean]: do not interact
      #   :only [Array of string]: update only the listed files
      #   :exclude [Array of string]: exclude from the upgrade the listed
      #                               files
      # return the number of considered files
      def upgrade(moduledir = Dir.pwd,
                  options = {
                    :no_interaction => false,
                    :only    => nil,
                    :exclude => []
                  })
        metadata = metadata(moduledir)
        templatedir = File.join( FalkorLib.templates, 'puppet', 'modules')
        i = 0
        update_from_erb = [
          'README.md',
          'docs/contacts.md',
          'docs/contributing/index.md', 'docs/contributing/layout.md', 'docs/contributing/setup.md', 'docs/contributing/versioning.md',
          'docs/index.md', 'docs/rtfd.md', 'docs/vagrant.md'
        ]
        (update_from_erb + [ 'Gemfile', 'Rakefile', 'Vagrantfile', '.vagrant_init.rb' ]).each do |f|
          next unless options[:exclude].nil? || !options[:exclude].include?( f )
          next unless options[:only].nil?    || options[:only].include?(f)
          info "Upgrade the content of #{f}"
          ans = (options[:no_interaction]) ? 'Yes' : ask(cyan("==> procceed? (Y|n)"), 'Yes')
          next if ans =~ /n.*/i
          if update_from_erb.include?(f)
            puts "=> updating #{f}.erb"
            i += write_from_erb_template(File.join(templatedir, "#{f}.erb"),
                                         File.join(moduledir, f),
                                         metadata,
                                         options)
          else
            i += write_from_template(f, moduledir,
                                     :no_interaction => options[:no_interaction],
                                     :srcdir => templatedir)

          end
        end
        i
      end

      ##
      # initializes or update the (tests/specs/etc.) sub-directory of the
      # `moduledir` using the correcponding ERB files.
      # Supported options:
      #   :no_interaction [boolean]: do not interactww
      #
      # returns the number of considered files
      def upgrade_from_template(moduledir = Dir.pwd,
                                subdir = 'tests',
                                options = {
                                  :no_interaction => false
                                })
        metadata = metadata(moduledir)
        ap metadata
        i = 0
        templatedir = File.join( FalkorLib.templates, 'puppet', 'modules', subdir)
        error "Unable to find the template directory '#{templatedir}" unless File.directory?( templatedir )
        Dir["#{templatedir}/**/*.erb"].each do |erbfile|
          f = File.join(subdir, File.basename(erbfile, '.erb'))
          info "Upgrade the content of #{f}"
          ans = (options[:no_interaction]) ? 'Yes' : ask(cyan("==> procceed? (Y|n)"), 'Yes')
          next if ans =~ /n.*/i
          i += write_from_erb_template(erbfile, File.join(moduledir, f), metadata, options)
        end
        i
      end


      #######
      # Find the classes of a given module
      ###
      def classes(moduledir = Dir.pwd)
        _get_classdefs(moduledir, 'classes')
      end

      #######
      # Find the definitions of a given module
      ###
      def definitions(moduledir = Dir.pwd)
        _get_classdefs(moduledir, 'definitions')
      end

      #######
      # Find the dependencies of a given module
      ###
      def deps(moduledir = Dir.pwd)
        name = File.basename( moduledir )
        error "The module #{name} does not exist" unless File.directory?( moduledir )

        result    = []
        result2   = []
        resulttmp = []

        result << name

        while result != result2
          resulttmp = result.dup
          (result - result2).each do |_x|
            Dir["#{moduledir}/**/*.pp"].each do |ppfile|
              File.read(ppfile).scan(/^\s*(include|require|class\s*{)\s*["']?(::)?([0-9a-zA-Z:{$}\-]*)["']?/) do |_m|
                next if Regexp.last_match(3).nil?
                entry = Regexp.last_match(3).split('::').first
                result << entry unless entry.nil? || entry.empty?
              end
            end
          end
          result.uniq!
          result2 = resulttmp.dup
        end
        result.delete name.to_s
        result
      end

    end
  end # module FalkorLib::Puppet

end # module FalkorLib
