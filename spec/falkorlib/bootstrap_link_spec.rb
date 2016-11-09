#!/usr/bin/ruby
#########################################
# bootstrap_link_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Wed 2016-11-09 17:43 svarrette>
#
# @description Check the Bootstrapping operations for [sym]link
#
# Copyright (c) 2013 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
##############################################################################

require 'spec_helper'
require 'tmpdir'
require 'fileutils'

describe FalkorLib::Bootstrap::Link do

  include FalkorLib::Common

  dir        = Dir.mktmpdir
  subdirname = 'sub/dir'
  supported_makefiles = [
    :repo, :generic, :latex, :src, :gnuplot, :images, :markdown
  ]
  makefile_d = '.makefile.d'

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
  context "bootstrap/link within temporary directory '#{dir}'" do

    subdir  = File.join(dir, subdirname)
    dotroot = File.join(subdir, '.root')

    it "initialize Git in the temporary directory #{dir}" do
      c = FalkorLib::Git.init(dir)
      expect(c).to eq(0)
      t = FalkorLib::Git.init?(dir)
      expect(t).to be true
    end

    ### '.root' symlink
    it "#root" do
      FileUtils.mkdir_p( subdir )
      c = FalkorLib::Bootstrap::Link.root(subdir)
      expect(c).to eq(0)
      t = File.exists?(dotroot)
      expect(t).to be true
      v = File.readlink(dotroot)
      expect(v).to eq('../..')
    end

    it "#root again, link already existing" do
      t = FalkorLib::Bootstrap::Link.root(subdir)
      expect(t).to eq(1)
      c = capture(:stdout) { FalkorLib::Bootstrap::Link.root(subdir) }
      expect(c).to include "the symbolic link '.root' already exists"
    end

    it "#root -- different symlink name" do
      linkname       = '.custom-root'
      custom_dotroot = File.join(subdir, linkname)
      c = FalkorLib::Bootstrap::Link.root(subdir, { :name => linkname })
      expect(c).to eq(0)
      t = File.exists?(custom_dotroot)
      expect(t).to be true
      v = File.readlink(custom_dotroot)
      expect(v).to eq('../..')
    end

    it "#root -- at git rootdir" do
      c = capture(:stdout) { FalkorLib::Bootstrap::Link.root(dir) }
      expect(c).to include 'Already at the root directory of the Git repository'
    end

    ###### My favorite Makefiles
    supported_makefiles.each do |type|

      workdir       = File.join(dir, "#{type}")
      makefile      = File.join(workdir, 'Makefile')
      dotmakefile_d = File.join(workdir, makefile_d)

      it "#makefile -- type '#{type}'" do
        FileUtils.mkdir_p(workdir)
        c = FalkorLib::Bootstrap::Link.makefile(workdir, { type.to_sym => true })
        expect(c).to eq(0)

        # check existence of symlinks
        d = File.exists?(dotmakefile_d)
        expect(d).to be true
        t = File.exists?(makefile)
        expect(t).to be true

        # check targets of symlinks
        vd = File.readlink(dotmakefile_d)
        expect(vd).to include File.join(FalkorLib.config[:git][:submodulesdir], 'Makefiles')

        v = File.readlink(makefile)
        expect(v).to include "#{type}"
      end
    end

    type = 'latex'
    it "#makefile -- again (type #{type}), links already existing" do
      workdir = File.join(dir, type)  # for instance
      makefile      = File.join(workdir, 'Makefile')
      pre_check = File.exists?(makefile)
      expect(pre_check).to be true

      t = FalkorLib::Bootstrap::Link.makefile(workdir, { type.to_sym => true })
      expect(t).to eq(1)
      c = capture(:stdout) {
        FalkorLib::Bootstrap::Link.makefile(workdir, { type.to_sym => true })
      }
      [
        "the git submodule 'Makefiles' is already setup",
        "the symbolic link '.root' already exists",
        "Makefile already setup"
      ].each do |pattern|
        expect(c).to include pattern
      end
    end

  end # context "bootstrap/link"

end
