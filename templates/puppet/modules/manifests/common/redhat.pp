# File::      <tt>common/redhat.pp</tt>
# Author::    <%= config[:author] %> (<%= config[:mail] %>)
# Copyright:: Copyright (c) <%= Time.now.year %> <%= config[:author] %>
# License::   <%= config[:license].capitalize %>
#
# ------------------------------------------------------------------------------
# = Class: <%= config[:shortname] %>::debian
#
# Specialization class for Debian systems
class <%= config[:shortname] %>::common::redhat inherits <%= config[:shortname] %>::common { }
