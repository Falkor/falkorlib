#!/usr/bin/ruby
# coding: utf-8
#########################################
# bootstrap_latex_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Sun 2016-11-13 21:33 svarrette>
#
# @description Check the Bootstrapping operations for LaTeX-based projects
#
# Copyright (c) 2013 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
##############################################################################

require 'spec_helper'
require 'tmpdir'
require 'fileutils'

describe FalkorLib::Bootstrap do

  include FalkorLib::Common

  dir = Dir.mktmpdir
  supported_latex_types = [ :article ]
  # I give up on making the compilation working on travis (it currently fails
  # with the message 'LaTeX Error: There's no line here to end. l.57') I could
  # not figure out as it works fine on vagrant/ubuntu-precise and mac.
  supported_latex_types << :beamer unless ENV['TRAVIS_CI_RUN']

  #_____________
  before :all do
    $stdout.sync = true
    FalkorLib.config[:no_interaction] = true
  end

  #____________
  after :all do
    FileUtils.remove_entry_secure dir
    FalkorLib.config[:no_interaction] = false
  end

  ########################################################################
  context "bootstrap/latex within temporary directory '#{dir}'" do

    it "#latex -- unsupported type" do
      expect { FalkorLib::Bootstrap::latex(dir, :toto) }.to raise_error (SystemExit)
    end

    ###### LaTeX slides
    supported_latex_types.each do |type|
      it "#latex(#{type})" do
        name = "latex-#{type}"
        projectdir = case type
                     when :beamer
                       'slides'
                     when :article
                       'articles'
                     end
        subdirname = File.join(projectdir, "#{Time.now.year}", name)
        subdir     = File.join(dir, subdirname)
        srcdir     = File.join(subdir, 'src')
        trashdir   = File.join(srcdir, FalkorLib.config[:templates][:trashdir])
        imagedir   = File.join(srcdir, 'images')
        c = FalkorLib::Bootstrap::latex(dir, type, {
                                          :name => name
                                        })
        # check that everything was set accordingly
        expect(FalkorLib::Git.init?(dir)).to be true

        # check expected git submodules
        submodules = [ 'Makefiles' ]
        submodules << 'beamerthemeFalkor' if type == :beamer
        submodules.each do |d|
          expect(Dir.exist?( File.join(dir, FalkorLib.config.git[:submodulesdir], d))).to be true
        end

        # check main files at the root directory
        main_root_files = [ '.gitmodules', 'VERSION', 'README.md' ]
        main_root_files.each do |f|
          expect(File.exist?(File.join(dir, f))).to be true
        end

        # check main LaTeX project directory
        expect(Dir.exist?(subdir)).to be true
        main_files = [ '.root', '.makefile.d', 'Makefile']
        main_files.each do |f|
          file = File.join(subdir, f)
          expect(File.exist?(file)).to be true
        end
        v = File.readlink(File.join(subdir, 'Makefile'))
        expect(v).to include '.makefile.d/latex_src'

        # check src directory
        expect(Dir.exist?(srcdir)).to be true
        src_latex_symlinks = [ 'Makefile', '_style.sty', '.gitignore' ]
        src_latex_symlinks.each do |f|
          file = File.join(srcdir, f)
          expect(File.exist?(file)).to be true
          expect(File.readlink(file)).to include '.makefile.d/latex'
        end

        src_latex_files = [ "#{name}.tex" ]
        src_latex_files  << '_content.md' if type == :beamer
        src_latex_files = [ '_abstract.tex', '_conclusion.tex', '_experiments.tex', '_introduction.tex', 'biblio.bib', '_related_works.tex' ] if type == :article
        src_latex_files.each do |f|
          file = File.join(srcdir, f)
          expect(File.exist?(file)).to be true
        end
        if type == :beamer
          [ 'beamerthemeFalkor' ].each do |f|
            file = File.join(srcdir, "#{f}.sty")
            expect(File.exist?(file)).to be true
            expect(File.readlink(file)).to include File.join(FalkorLib.config[:git][:submodulesdir], f)
          end
        end
        # trash dir
        expect(Dir.exist?(trashdir)).to be true
        # check images dir
        expect(Dir.exist?(imagedir)).to be true
        main_files.each do |f|
          file = File.join(imagedir, f)
          expect(File.exist?(file)).to be true
        end
        image_makefile = File.join(imagedir, 'Makefile')
        expect(File.readlink(image_makefile)).to include '.makefile.d/images'

        # Finally try to compile it
        if command?('make') && command?('pandoc')
          [ "#{srcdir}", "#{subdir}" ].each do |d|
            t = run %( make -C #{d} )
            expect(t).to eq(0)
            pdf = File.join(srcdir, "#{name}.pdf")
            expect(File.exist?(pdf)).to be true
          end
        end
      end
    end





  end # context "bootstrap/latex"

end
