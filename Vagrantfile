# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.
  #config.vm.box = "debian/contrib-jessie64"
  config.vm.box = "ubuntu/precise64"

  # Benefit from travis infos
  travis_yaml   = File.join(File.dirname(__FILE__), '.travis.yml')
  travis_config = File.exist?(travis_yaml) ? YAML.load_file(travis_yaml) : {}
  # Manage requested packages installation through 'addons.apt.packages'
  if travis_config['addons']
    if travis_config['addons']['apt']
      if travis_config['addons']['apt']['packages']
        config.vm.provision "shell", inline: <<-SHELL
           sudo apt-get -yq --no-install-suggests --no-install-recommends --force-yes install #{travis_config['addons']['apt']['packages'].join(" ")}
        SHELL
      end
    end
  end
  # Manage pre-hook commands listed under before_install
  if travis_config['before_install']
    config.vm.provision "shell", env: { 'TEXMFLOCAL' => '/tmp/texmf' }, inline: <<-SHELL
       #{travis_config['before_install'].join("\n").gsub(/\.\//, '/home/vagrant/')}
    SHELL
  end


  # Bootstrap the gem dependencies according to two approaches:
  #   1. :system             - rely on system ruby
  #   2. :rvm (experimental) - mimic Travis-CI approach by relying on RVM
  # Any other value for bootstrap_mode will discard this phase
  bootstrap_mode = :none
  next unless [ :system, :rvm ].include?( bootstrap_mode)
  if bootstrap_mode == :system
    # Preliminaries
    config.vm.provision "shell", inline: <<-SHELL
     sudo apt-get install -qq rubygems;
     sudo gem install bundler;

  SHELL
  end





  # # Benefit from travis infos
  # travis_yaml   = File.join(File.dirname(__FILE__), '.travis.yml')
  # travis_config = File.exist?(travis_yaml) ? YAML.load_file(travis_yaml) : {}
  # if travis_config['before_install']
  #   config.vm.provision "shell", inline: <<-SHELL
  #       #{travis_config['before_install'].join("\n")}
  #   SHELL
  # end

  # Post-provision: run bundle
end
