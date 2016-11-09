# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Thu 2016-11-10 00:40 svarrette>
################################################################################
# Interface for the main Bootstrapping operations
#

require "falkorlib"
require "falkorlib/common"
require "falkorlib/bootstrap"

require 'erb'      # required for module generation
require 'artii'
require 'facter'

include FalkorLib::Common


module FalkorLib
  module Bootstrap
    module_function

    ###### latex ######
    # Bootstrap a LaTeX sub-project of type <type> within a given repository <dir>.
    # Supported types:
    #  * :beamer    LaTeX Beamer Slides
    #  * :article   LaTeX article
    #  * :ieee      LaTeX IEEE article
    #  * :ieee_jnl  LaTeX IEEE journal
    #  * :letter    LaTeX Letter
    # Supported options:
    #  * :force [boolean] force action
    ##
    def latex(dir = Dir.pwd, type = :beamer, options = {})
      ap options if options[:debug]
      error "Unsupported type" unless [ :beamer, :article, :ieee, :letter ].include?( type )
      path   = normalized_path(dir)
      config = FalkorLib::Config::Bootstrap::DEFAULTS[:latex].clone
      if type == :letter
        config.merge!(FalkorLib::Config::Bootstrap::DEFAULTS[:letter].clone)
        [ :title, :subtitle, :image ].each { |k| config.delete k }
      end
      config.deep_merge!(FalkorLib::Config::Bootstrap::DEFAULTS[:letter].clone) if type == :letter
      # initiate the repository if needed
      unless File.directory?( path )
        warn "The directory '#{path}' does not exists and will be created"
        really_continue? unless options[:force]
        run %{ mkdir -p #{path} }
      end
      repo(path, options) unless FalkorLib::Git.init?(path)
      rootdir = FalkorLib::Git.rootdir(path)
      info "Initiate a LaTeX #{type} project from the Git root directory: '#{rootdir}'"
      really_continue? unless options[:force]
      relative_path_to_root = (Pathname.new( FalkorLib::Git.rootdir(dir) ).relative_path_from Pathname.new( File.realpath(path))).to_s
      config[:name] = options[:name] ? options[:name] : ask("\tEnter the name of the #{type} LaTeX project: ", File.basename(path))
      raise FalkorLib::ExecError "Empty project name" if config[:name].empty?
      default_project_dir =  (Pathname.new( File.realpath(path) ).relative_path_from Pathname.new( FalkorLib::Git.rootdir(dir))).to_s
      if relative_path_to_root == '.'
        default_project_dir = case type
                              when :article, :ieee
                                "articles/#{Time.now.year}/#{config[:name]}"
                              when :beamer
                                "slides/#{Time.now.year}/#{config[:name]}"
                              when :bookchapter
                                "chapters/#{config[:name]}"
                              when :letter
                                "letters/#{Time.now.year}/#{config[:name]}"
                              else
                                "#{config[:name]}"
                              end
      else
        default_project_dir += "/#{config[:name]}" unless default_project_dir =~ /#{config[:name]}$/
      end
      project_dir = options[:dir] ? options[:dir] : ask("\tLaTeX Sources directory (relative to the Git root directory)", "#{default_project_dir}")
      raise FalkorLib::ExecError "Empty project directory" if project_dir.empty?
      src_project_dir = File.join(project_dir, 'src')
      srcdir = File.join(rootdir, src_project_dir)
      if File.exists?(File.join(srcdir, '.root'))
        warn "The directory '#{project_dir}' seems to have been already initialized"
        really_continue? unless options[:force]
      end
      FalkorLib::GitFlow.start('feature', config[:name], rootdir) if FalkorLib::GitFlow.init?(rootdir)
      # === prepare Git submodules ===
      info " ==> prepare the relevant Git submodules"
      submodules = {}
      submodules['Makefiles'] = { :url   => 'https://github.com/Falkor/Makefiles.git',
                                  :branch => 'devel'
                                } if [ :article, :beamer, :bookchapter].include?(type)
      submodules['beamerthemeFalkor'] = { :url => 'https://github.com/Falkor/beamerthemeFalkor' } if type == :beamer
      FalkorLib::Git.submodule_init(rootdir, submodules)
      info "bootstrapping the #{type} project sources in '#{src_project_dir}'"
      # Create the project directory
      Dir.chdir( rootdir ) do
        run %{ mkdir -p #{src_project_dir}/images } unless File.directory?("#{srcdir}/images")
      end
      info "populating '#{src_project_dir}'"
      #FalkorLib::Bootstrap::Link.root(srcdir, { :verbose => true} )
      FalkorLib::Bootstrap::Link.makefile(srcdir, { :no_interaction => true })
      [ '_style.sty', '.gitignore' ].each do |f|
        Dir.chdir( srcdir ) do
          dst = ".makefile.d/latex/#{f}"
          run %{ ln -s #{dst} #{f} } unless File.exist?( File.join(srcdir, f) )
        end
      end
      if type == :beamer
        f = 'beamerthemeFalkor.sty'
        dst = "#{FalkorLib.config[:git][:submodulesdir]}/beamerthemeFalkor/#{f}"
        Dir.chdir( srcdir ) do
          run %{ ln -s .root/#{dst} #{f} } unless File.exist?( File.join(srcdir, f) )
        end
      end

      # Bootstrap the directory
      templatedir = File.join( FalkorLib.templates, 'latex', "#{type}")
      unless File.exists?( File.join(srcdir, "#{config[:name]}.tex"))
        info "gathering information for the LaTeX templates"
        prefix = case type
                 when :article, :ieee
                   'Article '
                 when :beamer
                   'Slides '
                 when :bookchapter
                   'Book Chapter '
                 when :letter
                   'Letter '
                 else
                   ''
                 end
        config.each do |k,v|
          next if k == :name
          config[k.to_sym] = ask( "\t" + sprintf("%-20s", "#{prefix}#{k.capitalize}"), v)
        end
        init_from_template(templatedir, srcdir, config, {:no_interaction => true,
                                                         :no_commit      => true })
        # Rename the main file
        Dir.chdir( srcdir ) do
          run %{ mv main.tex #{config[:name]}.tex }
        end
      end
      # Create the trash directory
      trash(srcdir)

      # populate the images/ directory
      baseimages  = File.join( FalkorLib.templates, 'latex', 'images')
      #images_makefile_src = "#{FalkorLib.config[:git][:submodulesdir]}/Makefiles/generic/Makefile.insrcdir"
      images = File.join(srcdir, 'images')
      info "populating the image directory"
      Dir.chdir( images ) do
        run %{ rsync -avzu #{baseimages}/ . }
        run %{ ln -s ../.root .root } unless File.exists?(File.join(images, '.root'))
        #run %{ ln -s .root/#{images_makefile_src} Makefile } unless File.exists?(File.join(images, 'Makefile'))
      end
      FalkorLib::Bootstrap::Link.makefile(images, { :images => true, :no_interaction => true } )

      # Prepare the src/ directory
      FalkorLib::Bootstrap::Link.makefile(File.join(rootdir, project_dir), { :src => true, :no_interaction => true } )


      # default_project_dir = case type
      #               when :beamer
      #                   "slides/#{Time.new.yea}"
      #               end
    end # project



  end # module Bootstrap
end # module FalkorLib
