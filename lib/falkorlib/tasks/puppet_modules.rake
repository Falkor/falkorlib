# -*- encoding: utf-8 -*-
################################################################################
# puppet_modules.rake - Special tasks for the management of Puppet modules
# Time-stamp: <Tue 2015-05-19 10:51 svarrette>
#
# Copyright (c) 2014 Sebastien Varrette <Sebastien.Varrette@uni.lu>
#               http://varrette.gforge.uni.lu
################################################################################

require 'rake'
require 'falkorlib'
require 'falkorlib/tasks'
require 'falkorlib/puppet'

#.....................
namespace :bootstrap do
    #.....................
    namespace :puppet do

        ###########  bootstrap:puppet:module   ###########
        desc "Bootstrap a new Puppet module"
        task :module, [:name] do |t, args|
            info "#{t.comment}"
            name = (args.name.nil? or args.name.empty? or args.name == 'name') ? ask("Enter the module name (ex: 'ULHPC/modulename')") : args.name
            error "You need to provide a module name" unless name != ''
            error "The module name cannot contain spaces" if name =~ /\s+/
            moduledir = File.join( FalkorLib.config[:puppet][:modulesdir], name.gsub(/^\w*\//,'puppet-'))
            dir = ask("Destination directory:", moduledir)
            error "The module '#{name}' already exists" if File.directory?(dir)
            FalkorLib::Puppet::Modules.init(dir, name)
        end


    end # namespace bootstrap:puppet
end # namespace bootstrap

require 'json'

#.....................
namespace :puppet do
    include FalkorLib::Common

    if command?('puppet')
        #.....................
        namespace :module do

            ###########   puppet:module:build   ###########
            desc "Build the puppet module to publish it on the Puppet Forge"
            task :build do |t|
                info "#{t.comment}"
                run %{ puppet module build }
				if File.exists? ('metadata.json')
					metadata = JSON.parse( IO.read( 'metadata.json' ) )
					name    = metadata["name"]
					version = metadata["version"]
					url = metadata["forge_url"].nil? ? "https://forge.puppetlabs.com/#{name.gsub(/-/,'/')}" : metadata["forge_url"]
					warn "you can now upload the generated file 'pkg/#{name}-#{version}.tar.gz' on the puppet forge"
					warn "         #{url}"
				end 
            end # task build

            ###########   puppet:module:parse   ###########
            desc "Parse a given module"
            task :parse do |t|
                info "#{t.comment}"
                FalkorLib::Puppet::Modules.parse()
            end # task parse

			###########   puppet:module:validate   ###########
			desc "Validate the module by checking the syntax and programming style of the module"
			task :validate => [
			                #:syntax,
			                :lint
			               ]
#			do
# 				info "validate parsing"
# 				Dir['manifests/**/*.pp'].each do |manifest|
# 					sh "puppet parser validate --noop #{manifest}"
# 				end
# 				Dir['spec/**/*.rb','lib/**/*.rb'].each do |ruby_file|
# 					sh "ruby -c #{ruby_file}" unless ruby_file =~ /spec\/fixtures/
# 				end
# 				Dir['templates/**/*.erb'].each do |template|
# 					sh "erb -P -x -T '-' #{template} | ruby -c"
# 				end
# 				info "checking  style guidelines with puppet-lint"
# 				Rake::Task[:lint].invoke
# 				info "checking syntax"
# 				Rake::Task[:syntax].invoke
# 			end
			
			###########   puppet:module:classes   ###########
			desc "Parse the module for classes definitions"
			task :classes do |t|
				c = FalkorLib::Puppet::Modules.classes()
				info "Implemented classes:"
				puts c.empty? ? red('NONE') : c.to_yaml				
			end # task classes 

			###########   puppet:module:definitions   ###########
			desc "Parse the module for definitions"
			task :definitions do |t|
				d = FalkorLib::Puppet::Modules.definitions()
				info "Implemented definitions:"
				puts d.empty? ? red('NONE') : d.to_yaml				
			end # task definitions

			###########   puppet:module:deps   ###########
			desc "Parse the module for its exact dependencies"
			task :deps do |t|
				d = FalkorLib::Puppet::Modules.deps()
				info "Module dependencies:"
				puts d.empty? ? red('NONE') : d.to_yaml				
			end # task deps


        end
    end # namespace module
end # namespace puppet

#.....................
namespace :templates do

	namespace :upgrade do
		###########   templates:upgrade:all   ###########
		task :all do 
			info "Upgrade all key module files from FalkorLib templates"
			FalkorLib::Puppet::Modules.upgrade()
		end 

		[ 'docs', 'readme', 'rake', 'vagrant' ].each do |t|
			###########   templates:upgrade:{readme,rake,vagrant}   ###########
            desc "Upgrade (overwrite) #{t.capitalize} using the current FalkorLib template"
			task t.to_sym do
				list = case t
				       when 'readme'
					       [ 'README.md' ]
                       when 'docs'
                           [ 'docs/contacts.md',  'docs/contributing/index.md', 'docs/contributing/layout.md', 'docs/contributing/setup.md', 'docs/contributing/versioning.md', 'docs/index.md', 'docs/rtfd.md', 'docs/vagrant.md' ]
                       when 'rake' 
					       [ 'Gemfile', 'Rakefile' ]
				       when 'vagrant'
					       [ 'Vagrantfile', '.vagrant_init.rb']
				       else []
				       end
				#info "Upgrade the module files '#{list.join(',')}' from FalkorLib templates"
				FalkorLib::Puppet::Modules.upgrade(Dir.pwd,{
					                                   :only => list
				                                   })
			end
		end

		###########   templates:upgrade:tests   ###########
		task :tests do 
			info "Upgrade the basic tests manifests in tests/"
			FalkorLib::Puppet::Modules.upgrade_from_template(Dir.pwd, 'tests')
		end 


	end # namespace upgrade
end # namespace module


#.....................
require 'rake/clean'
CLEAN.add   'pkg'

exclude_tests_paths = ['pkg/**/*','spec/**/*']

#.........................................................................
# puppet-lint tasks -- see http://puppet-lint.com/checks/
#
require 'puppet-lint/tasks/puppet-lint'

PuppetLint.configuration.send('disable_autoloader_layout')
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.ignore_paths = exclude_tests_paths

task :lint_info do 
	info "checking  style guidelines with puppet-lint"
end 
task :lint => :lint_info

#.........................................................................
# Puppet-syntax - see https://github.com/gds-operations/puppet-syntax
#
require 'puppet-syntax/tasks/puppet-syntax'
PuppetSyntax.future_parser = true
PuppetSyntax.exclude_paths = exclude_tests_paths  

# task :syntax_info do 
# 	info "checking syntax for Puppet manifests, templates, and Hiera YAML"
# end 
# task :syntax => :syntax_info

#.........................................................................
# rspec-puppet tasks -- see http://rspec-puppet.com/tutorial/
#
# require 'rspec/core/rake_task'

# ########## rspec #################
# desc "Run all RSpec code examples"
# RSpec::Core::RakeTask.new(:rspec) do |t|
# 	t.rspec_opts = File.read("spec/spec.opts").chomp || ""
# end

# SPEC_SUITES = (Dir.entries('spec') - ['.', '..','fixtures']).select {|e| File.directory? "spec/#{e}" }
# namespace :rspec do
# 	SPEC_SUITES.each do |suite|
# 		############ rspec:{classes,defines...} ##########
# 		desc "Run #{suite} RSpec code examples"
# 		RSpec::Core::RakeTask.new(suite) do |t|
# 			t.pattern = "spec/#{suite}/**/*_spec.rb"
# 			t.rspec_opts = File.read("spec/spec.opts").chomp || ""
# 		end
# 	end
# end
# task :default => :rspec




################################################

[ 'major', 'minor', 'patch' ].each do |level|
	task "version:bump:#{level}" => 'puppet:module:validate'
end 

#task 'version:release' => 'puppet:module:build'
Rake::Task["version:release"].enhance do
  Rake::Task["puppet:module:build"].invoke
end
