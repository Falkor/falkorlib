# Installs a rake task to generate API documentation using yard.
#
# This file installs the 'rake yard' task. It is automatically generated by Noe from
# your .noespec file, and should therefore be configured there, under the
# variables/rake_tasks/yard entry, as illustrated below:
#
# variables:
#   rake_tasks:
#     yard:
#       files: lib/**/*.rb
#       options: []
#       ...
#
# If you have specific needs requiring manual intervention on this file,
# don't forget to set safe-override to false in your noe specification:
#
# template-info:
#   manifest:
#     tasks/yard.rake:
#       safe-override: false
#
# This file has been written to conform to yard v0.6.4. More information about
# yard and the rake task installed below can be found on http://yardoc.org/
#
begin
    require "yard"
    desc "Generate yard documentation"
    YARD::Rake::YardocTask.new(:yard) do |t|
        # Array of options passed to yardoc commandline. See 'yardoc --help' about this
        t.options = ["--output-dir", "doc/api", "-", "README.md", "CHANGELOG.md", "LICENCE.md"]

        # Array of ruby source files (and any extra documentation files
        # separated by '-')
        t.files = ["lib/**/*.rb"]

        # A proc to call before running the task
        # t.before = proc{ }

        # A proc to call after running the task
        t.after = proc{ 
			puts "\nFull documentation is now generated -- you probably want now to\n\t open doc/api/index.html"
		}

        # An optional lambda to run against all objects being generated.
        # Any object that the lambda returns false for will be excluded
        # from documentation.
        # t.verifier = lambda{|obj| true}
		
    end
rescue LoadError
    task :yard do
        abort 'yard is not available. In order to run yard, you must: gem install yard'
    end
end


