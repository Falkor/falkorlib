# Installs a rake task for for running examples written using rspec.
#
# This file installs the 'rake rspec' (aliased as 'rake spec') as well as
# extends 'rake test' to run spec tests, if any. It is automatically generated
# by Noe from your .noespec file, and should therefore be configured there,
# under the variables/rake_tasks/spec_test entry, as illustrated below:
#
# variables:
#   rake_tasks:
#     spec_test:
#       pattern: spec/**/*_spec.rb
#       verbose: true
#       rspec_opts: [--color, --backtrace]
#       ...
#
# If you have specific needs requiring manual intervention on this file,
# don't forget to set safe-override to false in your noe specification:
#
# template-info:
#   manifest:
#     tasks/spec_test.rake:
#       safe-override: false
#
# This file has been written to conform to RSpec v2.4.0. More information about
# rspec and options of the rake task defined below can be found on
# http://relishapp.com/rspec
#
require 'rspec/core'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

# RSpec.configure do |c|
#   c.fail_fast     = true
#   c.color         = true
# end

begin
  require "rspec/core/rake_task"
  #specfiles = Dir.glob['spec/**/*_spec.rb']
  specsuite = {}
  Dir.glob('spec/**/*_spec.rb').each do |f|
    File.basename(f) =~ /^([^_]+)_*/
    specsuite[Regexp.last_match(1)] = [] unless specsuite[Regexp.last_match(1)]
    specsuite[Regexp.last_match(1)] << f
  end
  rspec_opts = [ "--color", "--format d", "--backtrace" ]
  unless specsuite.empty?
    #.....................
    namespace :rspec do
      #.....................
      namespace :suite do
        specsuite.each do |name, _files|
          ###########   #{name}   ###########
          if _files.count == 1
            desc "Run all specs in #{name} spec suite"
            RSpec::Core::RakeTask.new(name.to_sym) do |t|
              t.pattern = "spec/**/#{name}_*spec.rb"
              #t.pattern = "spec/**/git_*spec.rb"
              t.verbose = false
              t.rspec_opts = rspec_opts
            end # task #{name}
          else
            namespace "#{name.to_sym}" do
              desc "Run all specs in #{name} spec suite"
              RSpec::Core::RakeTask.new(:all) do |t|
                t.pattern = "spec/**/#{name}_*spec.rb"
                t.verbose = false
                t.rspec_opts = rspec_opts
              end # task rspec:suite:#{name}:all
              _files.map { |f| File.basename(f, '_spec.rb').gsub("#{name}_", '') }.each do |subname|
                next if subname == name
                desc "Run the '#{subname}' specs in the #{name} spec suite"
                RSpec::Core::RakeTask.new(subname.to_sym) do |t|
                  t.pattern = "spec/**/#{name}_#{subname}*spec.rb"
                  t.verbose = false
                  t.rspec_opts = rspec_opts
                end # task rspec:suite:#{name}:#{subname}
              end
            end # namespace #{name}
          end # id
        end
      end # namespace suite
    end # namespace rspec
  end


  desc "Run RSpec code examples '*_spec.rb' from the spec/ directory"
  RSpec::Core::RakeTask.new(:rspec) do |t|
    # Glob pattern to match files.
    #t.pattern = "spec/**/common_*.rb"
    #t.pattern = "spec/**/versioning_*spec.rb"
    #t.pattern = "spec/**/puppet*spec.rb"
    #t.pattern = "spec/**/bootstrap_spec.rb"
    #t.pattern = "spec/**/git*spec.rb"
    #t.pattern = "spec/**/error*spec.rb"
    #t.pattern = "spec/**/config*spec.rb"

    # Whether or not to fail Rake when an error occurs (typically when
    # examples fail).
    t.fail_on_error = true

    # A message to print to stderr when there are failures.
    t.failure_message = nil

    # Use verbose output. If this is set to true, the task will print the
    # executed spec command to stdout.
    t.verbose = true

    # Use rcov for code coverage?
    #t.rcov = false

    # Path to rcov.
    #t.rcov_path = "rcov"

    # Command line options to pass to rcov. See 'rcov --help' about this
    #t.rcov_opts = []

    # Command line options to pass to ruby. See 'ruby --help' about this
    t.ruby_opts = []

    # Path to rspec
    #t.rspec_path = "rspec"

    # Command line options to pass to rspec. See 'rspec --help' about this
    #t.rspec_opts = ["--color", "--backtrace"]
    t.rspec_opts = rspec_opts #["--color", "--format d", "--backtrace"] # "--format d",
  end
rescue LoadError
  task :spec_test do
    abort 'rspec is not available. In order to run spec, you must: gem install rspec'
  end
ensure
  task :spec => [:spec_test]
  task :test => [:spec_test]
end

#.....................
namespace :setenv do
  ###########   code_climate   ###########
  #desc "Set Code Climate token to report rspec results"
  task :code_climate do |_t|
    unless FalkorLib.config[:tokens].nil? ||
        FalkorLib.config[:tokens][:code_climate].nil? ||
        FalkorLib.config[:tokens][:code_climate].empty?
      ans = ask(cyan("A Code Climate token is set - Do you want to report on Code Climate the result of the process? (y|N)"), 'No')
      ENV['CODECLIMATE_REPO_TOKEN'] = FalkorLib.config[:tokens][:code_climate] if ans =~ /y.*/i
    end
  end # task code_climate
end # namespace set

task :rspec => 'setenv:code_climate'
