# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Mon 2023-12-04 16:37 svarrette>
################################################################################
# Interface for Bootstrapping MkDocs
#

require "falkorlib"
require "falkorlib/common"
require "falkorlib/bootstrap"

require 'erb' # required for module generation
require 'artii'
require 'facter'

include FalkorLib::Common

module FalkorLib
  module Bootstrap #:nodoc:

    module_function

    ###### vagrant ######
    # Initialize Vagrant in the current directory
    # Supported options:
    #  * :force       [boolean] force overwritting
    ##
    def vagrant(dir = Dir.pwd, options = {})
      info "Initialize Vagrant (see https://www.vagrantup.com/)"
      path = normalized_path(dir)
      use_git = FalkorLib::Git.init?(path)
      rootdir = (use_git) ? FalkorLib::Git.rootdir(path) : path
      templatedir = File.join( FalkorLib.templates, 'vagrant')
      config = FalkorLib::Config::Bootstrap::DEFAULTS[:vagrant].clone
      if options[:os]
        config[:os] = options[:os]
      else
        config[:os] = select_from(config[:boxes].keys,
                    "Select OS to configure within your vagrant boxes by default",
                    (config[:boxes].keys.find_index(config[:os]) + 1))
      end
      # Eventually adapt default provider and IP range
      providers = ['virtualbox', 'libvirt']
      default_provider = (config[:os] =~ /_uefi$/) ? 'libvirt': 'virtualbox'
      info "OS selected: #{config[:os]} (thus with default provider: #{default_provider})"
      config[:provider] = select_from(providers,
        "Confirm vagrant hypervisor provider:",
        providers.find_index(default_provider)+1)
      config[:range] = case config[:provider]
                       when 'libvirt'
                         '192.168.122.1/24'
                       else
                         '192.168.56.0/21'
                       end
      [ :ram, :vcpus, :domain, :range ].each do |k|
        config[k.to_sym] = ask("\tDefault #{k.capitalize}:", config[k.to_sym])
      end

      puts config.to_yaml
      FalkorLib::GitFlow.start('feature', 'vagrant', rootdir) if (use_git && FalkorLib::GitFlow.init?(rootdir))
      init_from_template(templatedir, rootdir, config,
                         :no_interaction => true,
                         :no_commit => true)
      confdir    = File.join(dir, 'vagrant')
      [ 'config.yaml.sample' ].each do |f|
        FalkorLib::Git.add(File.join(confdir, "#{f}")) if use_git
      end
      scriptsdir = File.join(confdir, 'scripts')
      [ 'bootstrap.sh'].each do |f|
        FalkorLib::Git.add(File.join(scriptsdir, "#{f}")) if use_git
      end
      [ '.gitignore', '.ruby-version' ].each do |f|
        FalkorLib::Git.add(File.join(rootdir, "#{f}")) if (use_git && File.exist?(File.join(rootdir, "#{f}")))
      end
      return 0
      #exit_status.to_i
    end # vagrant

  end # module Bootstrap
end # module FalkorLib
