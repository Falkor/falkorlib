#!/usr/bin/ruby
#########################################
# bootstrap_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Thu 2018-11-08 16:26 svarrette>
#
# @description Check the basic Bootstrapping operations
#
# Copyright (c) 2013 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
##############################################################################

require 'spec_helper'
require 'tmpdir'
require 'fileutils'

describe FalkorLib::Bootstrap do

  include FalkorLib::Common

  dirs = {
    :without_git => Dir.mktmpdir,
    :with_git    => Dir.mktmpdir,
    #:default     => Dir.mktmpdir
  }
  before :all do
    $stdout.sync = true
    FalkorLib.config[:no_interaction] = true
  end

  after :all do
    dirs.each do |t,d|
      #next if t == :with_git
      FileUtils.remove_entry_secure d
    end
    FalkorLib.config[:no_interaction] = false
  end

  [ :without_git, :with_git ].each do |ctx|
  # [ :with_git ].each do |ctx|
    dir = dirs[ctx]
    #############################################################
    context "bootstrap/base (#{ctx}) within temporary directory '#{dir}'" do

      if ctx == :with_git
        it "initialize Git in the temporary directory #{dir}" do
          c = FalkorLib::Git.init(dir)
          expect(c).to eq(0)
          t = FalkorLib::Git.init?(dir)
          expect(t).to be true
        end

        #### root Makefile creation  #########
        it "#makefile -- bootstrap root makefile" do
          c = FalkorLib::Bootstrap.makefile(dir)
          t = File.exists?( File.join(dir, 'Makefile'))
        end

      end


      #### Trash creation  #########
      it "#trash" do
        c = FalkorLib::Bootstrap.trash(dir)
        t = File.exists?( File.join(dir, FalkorLib.config[:templates][:trashdir], '.gitignore'))
        expect(t).to be true
        expect(c).to eq(0)
      end

      it "#trash - repeat on an existing trash dir" do
        c = FalkorLib::Bootstrap.trash(dir)
        expect(c).to eq(1)
      end

      it "#trash - change target trash dir" do
        newtrashname = 'tmp/mytrash'
        c = FalkorLib::Bootstrap.trash(dir,newtrashname)
        t = File.exists?( File.join(dir, newtrashname, '.gitignore'))
        expect(t).to be true
        expect(c).to eq(0)
      end


      ### Bootstrap a VERSION file
      it "#versionfile" do
        f = File.join(dir, 'VERSION')
        FalkorLib::Bootstrap.versionfile(dir)
        t = File.exist?(f)
        expect(t).to be true
        v = FalkorLib::Versioning.get_version(dir)
        expect(v).to eq('0.0.0')
      end

      it "#versionfile -- non standard file and version" do
        opts = {
          :file    => 'version.txt',
          :version => '1.2.14'
        }
        f = File.join(dir, opts[:file])
        FalkorLib::Bootstrap.versionfile(dir, opts)
        t = File.exist?(f)
        expect(t).to be true
        v = FalkorLib::Versioning.get_version(dir, { :source => { :filename => opts[:file] }})
        expect(v).to eq(opts[:version])
      end

      ### Message Of The Day generation
      it "#motd" do
        motdfile = File.join(dir, 'motd')
        description = "Thats_a_description_hard_to_forge"
        FalkorLib::Bootstrap.motd(dir, {
                                    :desc => description,
                                    :no_interaction => true })
        expect(File).to exist(motdfile)
        expect(File.read(File.realpath(motdfile))).to include "=== #{description} ==="
      end

      ### README creation
      it "#readme" do
        readme = File.join(dir, 'README.md')
        #Array.new(6).each { |e|  STDIN.should_receive(:gets).and_return('') }
        #STDIN.should_receive(:gets).and_return('')
        #STDIN.should_receive(:gets).and_return('1')
        FalkorLib::Bootstrap.readme(dir, { :no_interaction => true })
        expect(File).to exist( readme )
        File.read(File.realpath( readme )) do |f|
          [
            "## Synopsis",                 # from header_readme.erb
            "## Issues / Feature request", # from readme_issues.erb
            "### Git",                     # from readme_git.erb
            "## Contributing"              # from footer_readme.erb
          ].each do |pattern|
            f.should include "#{pattern}"
          end
        end
      end

      ### LICENSE file generation
      it "#license -- don't generate LICENSE by default" do
        license = File.join(dir, 'LICENSE')
        FalkorLib::Bootstrap.license(dir)
        expect(File).not_to exist( license )
      end


      it "#licence -- Generate LICENSE files for all supported licenses" do
        FalkorLib::Config::Bootstrap::DEFAULTS[:licenses].keys.each do |lic|
          # drop for some special cases
          next if [ 'none', 'BSD', 'CC-by-nc-sa'].include?(lic)
          authors = "Dummy Author"
          license = File.join(dir, "LICENSE.#{lic.downcase}")
          FalkorLib::Bootstrap.license(dir, lic, authors, { :filename => license })
          expect(File).to exist( license )
        end
      end

      if ctx == :without_git
        it "#repo -- bootstrap a new repository" do
          c = FalkorLib::Bootstrap.repo(dir, { :no_interaction => true, :make => true, :git_flow => false })
          [ 'Makefile', 'VERSION', 'README.md' ].each do |f|
            expect(File).to exist( File.join(dir, f))
          end
        end
      end

      if ctx == :with_git
        it "#gitcrypt -- owner is empty" do
          c = FalkorLib::Bootstrap.gitcrypt(dir, { :owner => '', :no_interaction => true })
          [ '.git-crypt' ].each do |d|
            expect(File.directory?(File.join(dir, d))).to be false
          end
          expect(File).to exist( File.join(dir, '.gitattributes'))
          expect(File).to exist( File.join(dir, '.git', 'git-crypt', 'keys', 'default'))
          expect(File).to exist( File.join(dir, FalkorLib::Config::Bootstrap::DEFAULTS[:gitcrypt][:hooksdir], FalkorLib::Config::Bootstrap::DEFAULTS[:gitcrypt][:hook]))
          expect(File).to exist( File.join(dir, '.git','hooks','pre-commit'))
        end
        # it "#gitcrypt -- owner" do
        #   c = FalkorLib::Bootstrap.gitcrypt(dir, { :no_interaction => true })
        #   [ '.git-crypt' ].each do |d|
        #     expect(File.directory?(File.join(dir, d))).to be true
        #   end
        #   #expect(File).to exist( File.join(dir, '.git-crypt', 'keys', 'default', '0', '*.gpg'))
        #   # TODO check gpg file
        # end
      end


    end # context "bootstrap/base"
  end # each

end
