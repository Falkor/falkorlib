# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Dim 2014-08-31 22:32 svarrette>
################################################################################

require "falkorlib"
require 'open3'
require 'erb'      # required for module generation
require 'diffy'

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
                    $stderr.print red("** [err] #{line}")
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
            status
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

        ## List items from a glob pattern to ask for a unique choice
        # Supported options:
        #   :only_files      [boolean]: list only files in the glob
        #   :only_dirs       [boolean]: list only directories in the glob
        #   :pattern_include [array of strings]: pattern(s) to include for listing
        #   :pattern_exclude [array of strings]: pattern(s) to exclude for listing
        #   :text            [string]: text to put
        def list_items(glob_pattern, options = {})
            list  = { 0 => 'Exit' }
            index = 1
            raw_list = { 0 => 'Exit' }

            Dir["#{glob_pattern}"].each do |elem|
                #puts "=> element '#{elem}' - dir = #{File.directory?(elem)}; file = #{File.file?(elem)}"
                next if (! options[:only_files].nil?) && options[:only_files] && File.directory?(elem)
                next if (! options[:only_dirs].nil?)  && options[:only_dirs]  && File.file?(elem)
                entry = File.basename(elem)
                # unless options[:pattern_include].nil?
                #     select_entry = false
                #     options[:pattern_include].each do |pattern|
                #         #puts "considering pattern '#{pattern}' on entry '#{entry}'"
                #         select_entry |= entry =~ /#{pattern}/
                #     end
                #     next unless select_entry
                # end
                unless options[:pattern_exclude].nil?
                    select_entry = false
                    options[:pattern_exclude].each do |pattern|
                        #puts "considering pattern '#{pattern}' on entry '#{entry}'"
                        select_entry |= entry =~ /#{pattern}/
                    end
                    next if select_entry
                end
                #puts "selected entry = '#{entry}'"
                list[index]     = entry
                raw_list[index] = elem
                index += 1
            end
            text        = options[:text].nil?    ? "select the index" : options[:text]
            default_idx = options[:default].nil? ? 0 : options[:default]
            raise SystemExit.new('Empty list') if index == 1
            #ap list
            #ap raw_list
            # puts list.to_yaml
            # answer = ask("=> #{text}", "#{default_idx}")
            # raise SystemExit.new('exiting selection') if answer == '0'
            # raise RangeError.new('Undefined index')   if Integer(answer) >= list.length
            # raw_list[Integer(answer)]
            select_from(list, text, default_idx, raw_list)
        end

        ## Display a indexed list to select an i
        def select_from(list, text = 'Select the index', default_idx = 0, raw_list = list)
            error "list and raw_list differs in size" if list.size != raw_list.size
            l     = list
            raw_l = raw_list
            if list.kind_of?(Array)
                l = raw_l = { 0 => 'Exit' }
                list.each_with_index do |e, idx|
                    l[idx+1] = e
                    raw_l[idx+1] = raw_list[idx]
                end
            end
            puts l.to_yaml
            answer = ask("=> #{text}", "#{default_idx}")
            raise SystemExit.new('exiting selection') if answer == '0'
            raise RangeError.new('Undefined index')   if Integer(answer) >= l.length
            raw_l[Integer(answer)]
        end # select_from


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

        #################################
        ### [ERB] template generation ###
        #################################

        # Bootstrap the destination directory `rootdir` using the template
        # directory `templatedir`. the hash table `config` hosts the elements to
        # feed ERB files which **should** have the extension .erb.
        # The initialization is performed as follows:
        # * a rsync process is initiated to duplicate the directory structure
        #   and the symlinks, and exclude .erb files
        # * each erb files (thus with extension .erb) is interpreted, the
        #   corresponding file is generated without the .erb extension
        # Supported options:
        #   :erb_exclude [array of strings]: pattern(s) to exclude from erb file
        #                                    interpretation and thus to copy 'as is'
        def init_from_template(templatedir, rootdir, config = {}, options = {})
            error "Unable to find the template directory" unless File.directory?(templatedir)
            warning "about to initialize/update the directory #{rootdir}"
            really_continue?
            run %{ mkdir -p #{rootdir} } unless File.directory?( rootdir )
            run %{ rsync --exclude '*.erb' -avzu #{templatedir}/ #{rootdir}/ }
            Dir["#{templatedir}/**/*.erb"].each do |erbfile|
                relative_outdir = Pathname.new( File.realpath( File.dirname(erbfile) )).relative_path_from Pathname.new(templatedir)
                filename = File.basename(erbfile, '.erb')
                outdir   = File.realpath( File.join(rootdir, relative_outdir.to_s) )
                outfile  = File.join(outdir, filename)
                unless options[:erb_exclude].nil?
                    exclude_entry = false
                    options[:erb_exclude].each do |pattern|
                        exclude_entry |= erbfile =~ /#{pattern}/
                    end
                    if exclude_entry
                        info "copying non-interpreted ERB file"
                        # copy this file since it has been probably excluded from teh rsync process
                        run %{ cp #{erbfile} #{outdir}/ }
                        next
                    end
                end
                # Let's go
                info "updating '#{relative_outdir.to_s}/#{filename}'"
                puts "  using ERB template '#{erbfile}'"
                write_from_erb_template(erbfile, outfile, config)
            end
        end

        ## ERB generation of the file destfile usung the source template file `erbsrc`
        def write_from_erb_template(erbfile, outfile, config = {})
            error "Unable to find the template file #{erbfile}" unless File.exists? (erbfile )
            template = File.read("#{erbfile}")
            output   = ERB.new(template, nil, '<>')
	        content  = output.result(binding)
            if File.exists?( outfile )
                ref = File.read( outfile )
	            return if ref == content
	            warn "the file '#{outfile}' already exists and will be overwritten."
	            warn "Expected difference: \n------"
	            Diffy::Diff.default_format = :color
	            puts Diffy::Diff.new(ref, content, :context => 1)
            else
	            watch =  ask( cyan("  ==> Do you want to see the generated file before commiting the writing (y|N)"), 'No')
	            puts content if watch =~ /y.*/i
            end
	        proceed = ask( cyan("  ==> proceed with the writing (Y|n)"), 'Yes')
            return if proceed =~ /n.*/i
            info("=> writing #{outfile}")
            File.open("#{outfile}", "w+") do |f|
		        f.puts content
            end
        end 



        ### RVM init
        def init_rvm(rootdir = Dir.pwd, gemset = '')
            rvm_files = {
                :version => File.join(rootdir, '.ruby-version'),
                :gemset  => File.join(rootdir, '.ruby-gemset')
            }
            unless File.exists?( "#{rvm_files[:version]}")
                v = select_from(FalkorLib.config[:rvm][:rubies],
                                "Select RVM ruby to configure for this directory",
                                3)
                File.open( rvm_files[:version], 'w') do |f|
                    f.puts v
                end
            end
            unless File.exists?( "#{rvm_files[:gemset]}")
                g = gemset.empty? ? ask("Enter RVM gemset name for this directory", File.basename(rootdir)) : gemset
                File.open( rvm_files[:gemset], 'w') do |f|
                    f.puts g
                end
            end

        end


    end
end
