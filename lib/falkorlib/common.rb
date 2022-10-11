# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Sun 2020-04-12 14:38 svarrette>
################################################################################

require "falkorlib"
require 'open3'
require 'erb' # required for module generation
require 'diffy'
require 'json'
require "pathname"
require "facter"

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
      (COLOR == true) ? Term::ANSIColor.bold(str) : str
    end

    # Print a text in green
    def green(str)
      (COLOR == true) ? Term::ANSIColor.green(str) : str
    end

    # Print a text in red
    def red(str)
      (COLOR == true) ? Term::ANSIColor.red(str) : str
    end

    # Print a text in cyan
    def cyan(str)
      (COLOR == true) ? Term::ANSIColor.cyan(str) : str
    end

    # Print an info message
    def info(str)
      puts green("[INFO] " + str)
    end

    # Print an warning message
    def warning(str)
      puts cyan("/!\\ WARNING: " + str)
    end
    # alias_method :warn, :warning  # FIXME erb invokes also its own warn method

    ## Print an error message and abort
    def error(str)
      #abort red("*** ERROR *** " + str)
      $stderr.puts red("*** ERROR *** " + str)
      exit 1
    end

    ## simple helper text to mention a non-implemented feature
    def not_implemented
      error("NOT YET IMPLEMENTED")
    end

    ##############################
    ### Interaction functions  ###
    ##############################

    ## Ask a question
    def ask(question, default_answer = '')
      return default_answer if FalkorLib.config[:no_interaction]
      print "#{question} "
      print "[Default: #{default_answer}]" unless default_answer == ''
      print ": "
      STDOUT.flush
      answer = STDIN.gets.chomp
      (answer.empty?) ? default_answer : answer
    end

    ## Ask whether or not to really continue
    def really_continue?(default_answer = 'Yes')
      return if FalkorLib.config[:no_interaction]
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
      $?.exitstatus
    end

    ## Execute in a given directory
    def execute_in_dir(path, cmd)
      exit_status = 0
      Dir.chdir(path) do
        exit_status = run %( #{cmd} )
      end
      exit_status
    end # execute_in_dir

    ## Execute a given command - exit if status != 0
    def exec_or_exit(cmd)
      status = execute(cmd)
      if (status.to_i.nonzero?)
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
        system(cmd.to_s) unless FalkorLib.config.debug
        exit_status = $?.exitstatus
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

      Dir[glob_pattern.to_s].each do |elem|
        #puts "=> element '#{elem}' - dir = #{File.directory?(elem)}; file = #{File.file?(elem)}"
        next if (!options[:only_files].nil?) && options[:only_files] && File.directory?(elem)
        next if (!options[:only_dirs].nil?)  && options[:only_dirs]  && File.file?(elem)
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
      text        = (options[:text].nil?)    ? "select the index" : options[:text]
      default_idx = (options[:default].nil?) ? 0 : options[:default]
      raise SystemExit, 'Empty list' if index == 1
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
      if list.is_a?(Array)
        l = raw_l = { 0 => 'Exit' }
        list.each_with_index do |e, idx|
          l[idx + 1] = e
          raw_l[idx + 1] = raw_list[idx]
        end
      end
      puts l.to_yaml
      answer = ask("=> #{text}", default_idx.to_s)
      raise SystemExit, 'exiting selection' if answer == '0'
      raise RangeError, 'Undefined index'   if Integer(answer) >= l.length
      raw_l[Integer(answer)]
    end # select_from

    ## Display a indexed list to select multiple indexes
    def select_multiple_from(list, text = 'Select the index', default_idx = 1, raw_list = list)
      error "list and raw_list differs in size" if list.size != raw_list.size
      l     = list
      raw_l = raw_list
      if list.is_a?(Array)
        l = raw_l = { 0 => 'Exit', 1 => 'End of selection' }
        list.each_with_index do |e, idx|
          l[idx + 2] = e
          raw_l[idx + 2] = raw_list[idx]
        end
      end
      puts l.to_yaml
      choices = Array.new
      answer  = 0
      begin
        choices.push(raw_l[Integer(answer)]) if Integer(answer) > 1
        answer = ask("=> #{text}", default_idx.to_s)
        raise SystemExit, 'exiting selection' if answer == '0'
        raise RangeError, 'Undefined index'   if Integer(answer) >= l.length
      end while Integer(answer) != 1
    choices
    end # select_multiple_from

    ###############################
    ### YAML File loading/store ###
    ###############################

    # Return the yaml content as a Hash object
    def load_config(file)
      unless File.exist?(file)
        raise FalkorLib::Error, "Unable to find the YAML file '#{file}'"
      end
      loaded = YAML.load_file(file)
      unless loaded.is_a?(Hash)
        raise FalkorLib::Error, "Corrupted or invalid YAML file '#{file}'"
      end
      loaded
    end

    # Store the Hash object as a Yaml file
    # Supported options:
    #   :header         [string]: additional info to place in the header of the (stored) file
    #   :no_interaction [boolean]: do not interact
    def store_config(filepath, hash, options = {})
      content  = "# " + File.basename(filepath) + "\n"
      content += "# /!\\ DO NOT EDIT THIS FILE: it has been automatically generated\n"
      if options[:header]
        options[:header].split("\n").each { |line| content += "# #{line}" }
      end
      content += hash.to_yaml
      show_diff_and_write(content, filepath, options)
      # File.open( filepath, 'w') do |f|
      #     f.print "# ", File.basename(filepath), "\n"
      #     f.puts "# /!\\ DO NOT EDIT THIS FILE: it has been automatically generated"
      #     if options[:header]
      #         options[:header].split("\n").each do |line|
      #             f.puts "# #{line}"
      #         end
      #     end
      #     f.puts hash.to_yaml
      # end
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
    #   :no_interaction [boolean]: do not interact
    def init_from_template(templatedir, rootdir, config = {},
                           options = {
                             :erb_exclude    => [],
                             :no_interaction => false
                           })
      error "Unable to find the template directory" unless File.directory?(templatedir)
      warning "about to initialize/update the directory #{rootdir}"
      really_continue? unless options[:no_interaction]
      run %( mkdir -p #{rootdir} ) unless File.directory?( rootdir )
      run %( rsync --exclude '*.erb' --exclude '.texinfo*' -avzu #{templatedir}/ #{rootdir}/ )
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
            run %( cp #{erbfile} #{outdir}/ )
            next
          end
        end
        # Let's go
        info "updating '#{relative_outdir}/#{filename}'"
        puts "  using ERB template '#{erbfile}'"
        write_from_erb_template(erbfile, outfile, config, options)
      end
    end

    ###
    # ERB generation of the file `outfile` using the source template file `erbfile`
    # Supported options:
    #   :no_interaction [boolean]: do not interact
    #   :srcdir         [string]: source dir for all considered ERB files
    def write_from_erb_template(erbfile, outfile, config = {},
                                options = {
                                  :no_interaction => false
                                })
      erbfiles = (erbfile.is_a?(Array)) ? erbfile : [ erbfile ]
      content = ""
      erbfiles.each do |f|
        erb = (options[:srcdir].nil?) ? f : File.join(options[:srcdir], f)
        unless File.exist?(erb)
          warning "Unable to find the template ERBfile '#{erb}'"
          really_continue? unless options[:no_interaction]
          next
        end
        #puts config.to_yaml
        content += ERB.new(File.read(erb.to_s), nil, '<>').result(binding)
      end
      # error "Unable to find the template file #{erbfile}" unless File.exists? (erbfile )
      # template = File.read("#{erbfile}")
      # output   = ERB.new(template, nil, '<>')
      # content  = output.result(binding)
      show_diff_and_write(content, outfile, options)
    end

    ## Show the difference between a `content` string and an destination file (using Diff algorithm).
    # Obviosuly, if the outfile does not exists, no difference is proposed.
    # Supported options:
    #   :no_interaction [boolean]:     do not interact
    #   :json_pretty_format [boolean]: write a json content, in pretty format
    #   :no_commit [boolean]:          do not (offer to) commit the changes
    # return 0 if nothing happened, 1 if a write has been done
    def show_diff_and_write(content, outfile, options = {
      :no_interaction => false,
      :json_pretty_format => false,
      :no_commit => false
    })
      if File.exist?( outfile )
        ref = File.read( outfile )
        if options[:json_pretty_format]
          ref = JSON.pretty_generate(JSON.parse( IO.read( outfile ) ))
        end
        if ref == content
          warn "Nothing to update"
          return 0
        end
        warn "the file '#{outfile}' already exists and will be overwritten."
        warn "Expected difference: \n------"
        Diffy::Diff.default_format = :color
        puts Diffy::Diff.new(ref, content, :context => 1)
      else
        watch = (options[:no_interaction]) ? 'no' : ask( cyan("  ==> Do you want to see the generated file before commiting the writing (y|N)"), 'No')
        puts content if watch =~ /y.*/i
      end
      proceed = (options[:no_interaction]) ? 'yes' : ask( cyan("  ==> proceed with the writing (Y|n)"), 'Yes')
      return 0 if proceed =~ /n.*/i
      info("=> writing #{outfile}")
      File.open(outfile.to_s, "w+") do |f|
        f.write content
      end
      if FalkorLib::Git.init?(File.dirname(outfile)) && !options[:no_commit]
        do_commit = (options[:no_interaction]) ? 'yes' : ask( cyan("  ==> commit the changes (Y|n)"), 'Yes')
        FalkorLib::Git.add(outfile, "update content of '#{File.basename(outfile)}'") if do_commit =~ /y.*/i
      end
      1
    end


    ## Blind copy of a source file `src` into its destination directory `dstdir`
    # Supported options:
    #   :no_interaction [boolean]: do not interact
    #   :srcdir [string]: source directory, make the `src` file relative to that directory
    #   :outfile [string]: alter the outfile name (File.basename(src) by default)
    #   :no_commit [boolean]:          do not (offer to) commit the changes
    def write_from_template(src, dstdir, options = {
      :no_interaction => false,
      :no_commit      => false,
      :srcdir         => '',
      :outfile        => ''
    })
      srcfile = (options[:srcdir].nil?) ? src : File.join(options[:srcdir], src)
      error "Unable to find the source file #{srcfile}" unless File.exist?( srcfile )
      error "The destination directory '#{dstdir}' do not exist" unless File.directory?( dstdir )
      dstfile = (options[:outfile].nil?) ? File.basename(srcfile) : options[:outfile]
      outfile = File.join(dstdir, dstfile)
      content = File.read( srcfile )
      show_diff_and_write(content, outfile, options)
    end # copy_from_template


    ### RVM init
    def init_rvm(rootdir = Dir.pwd, gemset = '')
      rvm_files = {
        :version => File.join(rootdir, '.ruby-version'),
        :gemset  => File.join(rootdir, '.ruby-gemset')
      }
      unless File.exist?( (rvm_files[:version]).to_s)
        v = select_from(FalkorLib.config[:rvm][:rubies],
                        "Select RVM ruby to configure for this directory",
                        3)
        File.open( rvm_files[:version], 'w') do |f|
          f.puts v
        end
      end
      unless File.exist?( (rvm_files[:gemset]).to_s)
        g = (gemset.empty?) ? ask("Enter RVM gemset name for this directory", File.basename(rootdir)) : gemset
        File.open( rvm_files[:gemset], 'w') do |f|
          f.puts g
        end
      end
    end

    ###### normalize_path ######
    # Normalize a path and return the absolute path foreseen
    # Ex: '.' return Dir.pwd
    # Supported options:
    #  * :relative   [boolean] return relative path to the root dir
    ##
    def normalized_path(dir = Dir.pwd, options = {})
      rootdir = (FalkorLib::Git.init?(dir)) ? FalkorLib::Git.rootdir(dir) : dir
      path = dir
      path = Dir.pwd if dir == '.'
      path = File.join(Dir.pwd, dir) unless (dir =~ /^\// || (dir == '.'))
      if (options[:relative] || options[:relative_to])
        root = (options[:relative_to]) ? options[:relative_to] : rootdir
        relative_path_to_root = Pathname.new( File.realpath(path) ).relative_path_from Pathname.new(root)
        path = relative_path_to_root.to_s
      end
      path
    end # normalize_path

  end
end
