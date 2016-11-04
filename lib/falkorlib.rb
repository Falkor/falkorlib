# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Fri 2016-11-04 11:06 svarrette>
################################################################################
#                   _____     _ _              _     _ _
#                   |  ___|_ _| | | _____  _ __| |   (_) |__
#                   | |_ / _` | | |/ / _ \| '__| |   | | '_ \
#                   |  _| (_| | |   < (_) | |  | |___| | |_) |
#                   |_|  \__,_|_|_|\_\___/|_|  |_____|_|_.__/
#
################################################################################
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
#
# * [Source code](https://github.com/Falkor/falkorlib)
# * [Official Gem](https://rubygems.org/gems/falkorlib)
################################################################################

require "awesome_print"
#require 'active_support'  # provides so many nice extensions
require 'active_support/core_ext/hash'

begin
    require 'term/ansicolor'
    COLOR = true
rescue Exception => e
    puts "/!\\ cannot find the 'term/ansicolor' library"
    puts "    Consider installing it by 'gem install term-ansicolor'"
    COLOR = false
end

require 'yaml'

# Sebastien Varrette aka Falkor's Common library to share Ruby code
# and `{rake,cap}` tasks
module FalkorLib

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

end # module FalkorLib


require "falkorlib/version"
require "falkorlib/loader"
