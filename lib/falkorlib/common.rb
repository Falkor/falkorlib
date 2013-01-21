#!/usr/bin/ruby

### Configure colors ###
begin
    require 'term/ansicolor'
    COLOR = true
rescue Exception => e
    puts "/!\\ cannot find the 'term/ansicolor' library"
    puts "    Consider installing it by 'gem install term-ansicolor'"
    COLOR = false
end

module FalkorLib
    module Common

        ##################################
        ### Default printing functions ###
        ##################################

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
        def warn(str)
            warning(str)
        end
        ## Print an error message and abort
        def error(str)
            #abort red("*** ERROR *** " + str)
	        $stderr.puts red("*** ERROR *** " + str)
	        exit 1
        end
        def not_implemented()
            error("NOT YET IMPLEMENTED")
        end

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

        ## Execute a given command - exit if status != 0
        def execute(cmd)
	        sh %{#{cmd}} do |ok, res|
		        if ! ok
			        error("The command '#{cmd}' failed with exit status #{res.exitstatus}")
		        end
	        end
        end



    end
end
