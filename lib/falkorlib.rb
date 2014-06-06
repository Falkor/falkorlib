# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Ven 2014-06-06 17:06 svarrette>
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

end # module FalkorLib

require "falkorlib/version"
require "falkorlib/loader"

