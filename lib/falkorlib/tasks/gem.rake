# -*- encoding: utf-8 -*-
################################################################################
# gem.rake - Special tasks for the management of Gem operations
# Time-stamp: <Dim 2014-08-31 22:59 svarrette>
#
# Copyright (c) 2014 Sebastien Varrette <Sebastien.Varrette@uni.lu>
#               http://varrette.gforge.uni.lu
################################################################################

require 'falkorlib'
require 'falkorlib/tasks'
require 'falkorlib/git'
require 'rubygems/tasks'

#.....................
namespace :gem do
    Gem::Tasks::Console.new(:command => 'pry')

    ###########  gem:release   ###########
    desc "Release the gem "
    task :release => [ :build ] do |t|
        pkgdir = Gem::Tasks::Project::PKG_DIR
        Dir.glob("*.gemspec") do |gemspecfile|
            spec = Gem::Specification::load(gemspecfile)
            name    = spec.name
            version = spec.version
            gem     = File.join( pkgdir , "#{name}-#{version}.gem")
            unless File.exists?( gem )
                warn "Unable to find the built gem '#{gem}'... Thus exiting."
                next
            end
            info t.comment + " '#{gem}'"
            really_continue?
            a = run %{
              gem push #{gem}
            }
            error "Unable to publish the gem '#{gem}'" if a.to_i != 0
        end
    end # task gem:release
	task :publish, :release

    ###########   info   ###########
    desc "Informations on the gem"
    task :info do |t|
        require "rubygems"
        Dir.glob("*.gemspec") do |gemspecfile|
            spec = Gem::Specification::load(gemspecfile)
            info t.comment + " '#{spec.name}' (version #{spec.version})"
            puts <<-eos
- Summary:     #{spec.summary}
- Author:      #{spec.author} #{spec.email}
- Licence:     #{spec.license}
- Homepage:    #{spec.homepage}
- Description: #{spec.description}
eos
        end



    end # task info



end # namespace gem

# Until [Issue#13](https://github.com/postmodern/rubygems-tasks/issues/13) it solved,
# I have to remain in the global tasks not embedded in a namespace
#Gem::Tasks::Install.new
Gem::Tasks::Build::Gem.new(:sign => true)
Gem::Tasks::Sign::Checksum.new
Gem::Tasks::Sign::PGP.new

# Enhance the build to sign the built gem
Rake::Task['build'].enhance do
    Rake::Task["sign"].invoke if File.directory?(File.join(ENV['HOME'], '.gnupg') )
end

[ 'major', 'minor', 'patch' ].each do |level|
	Rake::Task["version:bump:#{level}"].enhance do 
		warn "about to run the rspec tests to ensure the release can be done"
		really_continue?
		Rake::Task['rspec'].invoke
	end
end 


# Gem::Tasks.new(
#                :console => false,
#                :install => false,
#                :sign    => false,
#                :build   => false,
#                :release => true
#                ) do |tasks|
#   tasks.scm.tag.format = "release-%s",
#   tasks.scm.tag.sign = true
# end



# Gem::Tasks.new(:console => false, :release => false, :sign => true) do |tasks|
#   # tasks.build = {
#   #   :tar => true,
#   #   :zip => true
#   # },


# #     #tasks.scm.tag.format = "release-%s",
# #     #tasks.scm.tag.sign   = true,
# #     #tasks.console.command = 'pry'
# #     # tasks.scm.tag = false
# #     # tasks.sign.checksum   = true
# #     # tasks.sign.pgp        = true
# end
