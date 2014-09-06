#!/usr/bin/env ruby 
##########################################################################
# vagrant_init.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Ven 2014-09-05 11:39 svarrette>
#
# @description 
#
# Copyright (c) 2014 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
##############################################################################

require 'json'
require 'falkorlib'

include FalkorLib::Common

# Load metadata
basedir   = File.directory?('/vagrant') ? '/vagrant' : Dir.pwd
jsonfile  = File.join( basedir, 'metadata.json')

error "Unable to find the metadata.json" unless File.exists?(jsonfile)

metadata   = JSON.parse( IO.read( jsonfile ) )
name = metadata["name"].gsub(/^[^\/-]+[\/-]/,'') 
metadata["dependencies"].each do |dep|
	lib = dep["name"]
	run %{ puppet module install #{lib} } 
end

modulepath=`puppet config print modulepath`.chomp
moduledir=modulepath.split(':').first

puts "#{modulepath}"
puts "#{moduledir}" 

info "set symlink to the '#{modulepath} module for loca developments"
run %{ ln -s #{basedir} #{moduledir}/#{name}  } unless File.exists?("#{moduledir}/#{name}")
