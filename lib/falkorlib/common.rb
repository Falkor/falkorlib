# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Jeu 2014-06-26 12:30 svarrette>
################################################################################

require "falkorlib"
require 'open3'


module FalkorLib #:nodoc:

	# @abstract 
	# Recipe for all my toolbox and versatile Ruby functions I'm using
	# everywhere. 
	# You'll typically want to include the `FalkorLib::Common` module to bring
	# the corresponding definitions into yoru scope.
    #
    # @example: 
	#   require 'falkorlib'
	#   include FalkorLib::Common
	#      
	#   info 'exemple of information text'
	#   really_continue?
	#   run %{ echo 'this is an executed command' }
	#
	#   Falkor.config.debug = true
	#   run %{ echo 'this is a simulated command that *will not* be executed' }
	#   error "that's an error text, let's exit with status code 1"
	#
    module Common
        module_function
        ##################################
        ### Default printing functions ###
        ##################################
        # Print a text in bold
        def bold(str)
            COLOR == true ? Term::ANSIColor.bold(str) : str
        end

        # Print a text in green
        def green(str)
            COLOR == true ? Term::ANSIColor.green(str) : str
        end

        # Print a text in red
        def red(str)
            COLOR == true ? Term::ANSIColor.red(str) : str
        end

        # Print a text in cyan
        def cyan(str)
            COLOR == true ? Term::ANSIColor.cyan(str) : str
        end

        # Print an info message
        def info(str)
            puts green("[INFO] " + str)
        end

        # Print an warning message
        def warning(str)
            puts cyan("/!\\ WARNING: " + str)
        end
        alias :warn :warning

        ## Print an error message and abort
        def error(str)
            #abort red("*** ERROR *** " + str)
            $stderr.puts red("*** ERROR *** " + str)
            exit 1
        end

        ## simple helper text to mention a non-implemented feature
        def not_implemented()
            error("NOT YET IMPLEMENTED")
        end

        ##############################
        ### Interaction functions  ###
        ##############################

        ## Ask a question
        def ask(question, default_answer='')
            print "#{question} "
            print "[Default: #{default_answer}]" unless default_answer == ''
            print ": "
            STDOUT.flush
            answer = STDIN.gets.chomp
            return answer.empty?() ? default_answer : answer
        end

        ## Ask whether or not to really continue
        def really_continue?(default_answer = 'Yes')
            pattern = (default_answer =~ /yes/i) ? '(Y|n)' : '(y|N)'
            answer = ask( cyan("=> Do you really want to continue #{pattern}?"), default_answer)
            exit 0 if answer =~ /n.*/i
        end

        ############################
        ### Execution  functions ###
        ############################

        ## Check for the presence of a given command
        def command?(name)
            `which #{name}`
            $?.success?
        end

        ## Execute a given command, return exit code and print nicely stdout and stderr
        def nice_execute(cmd)
	        puts bold("[Running] #{cmd.gsub(/^\s*/, ' ')}")
	        stdout, stderr, exit_status = Open3.capture3( cmd )
	        unless stdout.empty?
		        stdout.each_line do |line|
			        print "** [out] #{line}"
			        $stdout.flush
		        end
	        end 
	        unless stderr.empty?
		        stderr.each_line do |line|
			        print red("** [err] #{line}")        
			        $stderr.flush
		        end		        
	        end 
	        exit_status
        end

        # Simpler version that use the system call
        def execute(cmd)
	        puts bold("[Running] #{cmd.gsub(/^\s*/, ' ')}")
	        system(cmd)
	        $?
        end
         
        ## Execute in a given directory
        def execute_in_dir(path, cmd)
	        exit_status = 0
	        Dir.chdir(path) do
		        exit_status = run %{ #{cmd} }
	        end 
	        exit_status
        end # execute_in_dir



        ## Execute a given command - exit if status != 0
        def exec_or_exit(cmd)
	        status = execute(cmd)
	        if (status.to_i != 0)
		        error("The command '#{cmd}' failed with exit status #{status.to_i}")
            end
	        res
        end

        ## "Nice" way to present run commands
        ## Ex: run %{ hostname -f }
        def run(cmds)
	        exit_status = 0
            puts bold("[Running]\n#{cmds.gsub(/^\s*/, '   ')}")
	        $stdout.flush
            #puts cmds.split(/\n */).inspect
            cmds.split(/\n */).each do |cmd|
                next if cmd.empty?
                system("#{cmd}") unless FalkorLib.config.debug
		        exit_status = $?
            end
	        exit_status
        end

        ###############################
        ### YAML File loading/store ###
        ###############################

        # Return the yaml content as a Hash object
        def load_config(filepath)
            YAML::load_file(filepath)
        end

        # Store the Hash object as a Yaml file
        def store_config(filepath, hash)
            File.open( filepath, 'w') do |f|
                f.print "# ", File.basename(filepath), "\n"
                f.puts "# /!\\ DO NOT EDIT THIS FILE: it has been automatically generated"
                f.puts hash.to_yaml
            end
        end


    end
end
