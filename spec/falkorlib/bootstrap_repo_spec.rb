#!/usr/bin/ruby
#########################################
# bootstrap_vagrant_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Sun 2020-04-12 15:03 svarrette>
#
# @description Check the Bootstrapping operations for a new repo
#
# Copyright (c) 2020 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
##############################################################################

require 'spec_helper'
require 'tmpdir'
require 'fileutils'

describe FalkorLib::Bootstrap do

  include FalkorLib::Common

  dirs = {
    :with_make => Dir.mktmpdir,
    :with_rake => Dir.mktmpdir,
  }

  #_____________
  before :all do
    $stdout.sync = true
    FalkorLib.config[:no_interaction] = true
  end

  #____________
  after :all do
    dirs.each do |t,d|
      FileUtils.remove_entry_secure d
    end
    FalkorLib.config[:no_interaction] = false
  end

  [ :with_make, :with_rake ].each do |ctx|
    # [ :with_make ].each do |ctx|
    # [ :with_rake ].each do |ctx|
    dir = dirs[ctx]
    ########################################################################
    context "bootstrap/repo (#{ctx}) within temporary directory '#{dir}'" do

      it "#repo -- bootstrap a new repository" do
        c = FalkorLib::Bootstrap.repo(dir,
                                      {
                                        :no_interaction => true,
                                        :make => (ctx == :with_make),
                                        :rake => (ctx == :with_rake)
                                      })
        expect(c).to eq(0)
        files_to_check = (ctx == :with_make) ? [ 'Makefile' ] : [ 'Rakefile', 'Gemfile', '.ruby-version', '.ruby-gemset' ]
        files_to_check += [ 'VERSION', 'README.md', '.falkor/config' ]
        files_to_check.each do |f|
          expect(File).to exist( File.join(dir, f))
        end
        if (ctx == :with_make)
          [ '.submodules/Makefiles' ].each do |d|
            expect(File.directory?(File.join(dir, d))).to be true
          end
        end
      end

      it "#repo -- repeat bootstrap" do
        c = capture(:stdout) {
          FalkorLib::Bootstrap.repo(dir,
                                    {
                                      :no_interaction => true,
                                      :make => (ctx == :with_make),
                                      :rake => (ctx == :with_rake)
                                    })
        }
        [
          "Git is already initialized for the repository "
        ].each do |pattern|
          expect(c).to include pattern
        end
      end

    end # context "bootstrap/repo"
  end # each
end
