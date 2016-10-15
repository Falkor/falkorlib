# -*- encoding: utf-8 -*-
###########################################################################################
# Time-stamp: <Mon 2016-06-27 10:37 svarrette>
###########################################################################################
#  ____               _       _           _        __        __              _
# / ___| _   _ ___   / \   __| |_ __ ___ (_)_ __   \ \      / /_ _ _ __ _ __(_) ___  _ __
# \___ \| | | / __| / _ \ / _` | '_ ` _ \| | '_ \   \ \ /\ / / _` | '__| '__| |/ _ \| '__|
#  ___) | |_| \__ \/ ___ \ (_| | | | | | | | | | |   \ V  V / (_| | |  | |  | | (_) | |
# |____/ \__, |___/_/   \_\__,_|_| |_| |_|_|_| |_|    \_/\_/ \__,_|_|  |_|  |_|\___/|_|
#        |___/
##########################################################################################
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
#
# * [Source code](https://github.com/Falkor/sysadmin-warrior)
# * [Official Gem](https://rubygems.org/gems/sysadmin-warrior)
##########################################################################################
require "falkorlib"

# Sebastien Varrette aka Falkor's Common library to share Ruby code
# and `{rake,cap}` tasks
module SysAdminWarrior

  # Return the root directory of the gem
  def self.root
    File.expand_path '../..', __FILE__
  end

  def self.lib
    File.join root, 'lib'
  end

  def self.templates
    File.join root, 'templates'
  end

end # module SysAdminWarrior


require "sysadmin-warrior/version"
require "sysadmin-warrior/loader"
