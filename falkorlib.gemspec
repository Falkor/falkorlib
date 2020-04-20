# -*- coding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require "falkorlib/version"
#$version = FalkorLib::Version.to_s

Gem::Specification.new do |s|
  s.name         = "falkorlib"
  s.version      = FalkorLib::Version.to_s #$version
  s.date         = Time.now.strftime('%Y-%m-%d')
  s.summary      = "Sebastien Varrette aka Falkor's Common library to share Ruby code and {rake,cap} tasks"
  s.description  = "This is my personal library I use to share the Ruby tidbits and Rake tasks I made it for my various projects, and also to bootstrap easily several element of my daily workflow (new git repository, new beamer slides etc.).\n"

  s.homepage     = "https://github.com/Falkor/falkorlib"
  s.licenses     = 'MIT'

  s.authors = ['Sebastien Varrette']
  # The list of author names who wrote this gem.
  s.email   = ['Sebastien.Varrette@uni.lu']

  # Paths in the gem to add to $LOAD_PATH when this gem is activated (required).
  #
  # The default 'lib' is typically sufficient.
  s.require_paths = ["lib"]

  # Files included in this gem.
  #
  # By default, we take all files included in the .Manifest.txt file on root
  # of the project. Entries of the manifest are interpreted as Dir[...]
  # patterns so that lazy people may use wilcards like lib/**/*
  #
  # here = File.expand_path(File.dirname(__FILE__))
  # s.files = File.readlines(File.join(here, '.Manifest.txt')).
  #     inject([]){|files, pattern| files + Dir[File.join(here, pattern.strip)]}.
  #     collect{|x| x[(1+here.size)..-1]}

  # Test files included in this gem.
  #
  s.test_files = Dir["test/**/*"] + Dir["spec/**/*"]

  # Alternative:
  s.files = `git ls-files`.split("\n")
  #s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  #s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  # The path in the gem for executable scripts (optional)
  #
  #s.bindir = "bin"

  s.executables = (Dir["bin/*"]).collect { |f| File.basename(f) }

  ################################################################### REQUIREMENTS & INSTALL
  # Remember the gem version requirements operators and schemes:
  #   =  Equals version
  #   != Not equal to version
  #   >  Greater than version
  #   <  Less than version
  #   >= Greater than or equal to
  #   <= Less than or equal to
  #   ~> Approximately greater than
  #
  # Don't forget to have a look at http://lmgtfy.com/?q=Ruby+Versioning+Policies
  # for setting your gem version.
  #
  # For your requirements to other gems, remember that
  #   ">= 2.2.0"              (optimistic:  specify minimal version)
  #   ">= 2.2.0", "< 3.0"     (pessimistic: not greater than the next major)
  #   "~> 2.2"                (shortcut for ">= 2.2.0", "< 3.0")
  #   "~> 2.2.0"              (shortcut for ">= 2.2.0", "< 2.3.0")
  #
  #s.add_dependency("rake", ">= 10.1.0")
  s.add_runtime_dependency 'rake',              '>= 12.3.3'
  s.add_runtime_dependency 'git_remote_branch', '~> 0'
  s.add_runtime_dependency('minigit',           '~> 0')
  s.add_runtime_dependency("term-ansicolor",    '> 1.3')
  s.add_runtime_dependency("configatron",       '> 3.0')
  s.add_runtime_dependency("awesome_print",     '> 1.2')
  s.add_runtime_dependency("json",              '> 2.0')
  s.add_runtime_dependency("license-generator", '~> 0')
  s.add_runtime_dependency("deep_merge",        '~> 1.2.1')
  s.add_runtime_dependency("diffy",             '>= 3.0')
  s.add_runtime_dependency("logger",            '>= 1.2.8')
  s.add_runtime_dependency("thor",              '>= 1.0')
  s.add_runtime_dependency("artii",             '>= 2.1')
  s.add_runtime_dependency("facter",            '~> 2.4.1')
  s.add_runtime_dependency("activesupport",     '~> 4.0')
  #s.add_runtime_dependency("bundler-stats", '~> 2.0')
  #s.add_runtime_dependency("benchmark", '~> 4.0')
  #s.add_runtime_dependency("mercenary", '>= 0.3.5')


  #
  #
  # One call to add_dependency('gem_name', 'gem version requirement') for each
  # runtime dependency. These gems will be installed with your gem.
  # One call to add_development_dependency('gem_name', 'gem version requirement')
  # for each development dependency. These gems are required for developers
  #
  #s.add_development_dependency("rake",           ">= 10.1.0") #"~> 0.9.2")
  s.add_development_dependency("bundler", "~> 1.0")
  s.add_development_dependency 'rspec', '~> 3.0' #, '>= 2.7.0'
  s.add_development_dependency("pry",    "~> 0.9")
  s.add_development_dependency("yard",   ">= 0.9.20")
  s.add_development_dependency('rubocop', '~> 0.49.0')
  s.add_development_dependency("rubygems-tasks", "~> 0.2")
  s.add_development_dependency("travis",        "~> 1.6")
  s.add_development_dependency("travis-lint",   "~> 1.8")
  s.add_development_dependency('simplecov', '<= 0.17.1')
  #s.add_development_dependency 'codeclimate-test-reporter', '~> 1.0'
  #s.add_development_dependency("codeclimate-test-reporter", '~> 0') #, group: :test, require: nil)
  #s.add_development_dependency("thor-zsh_completion", '>= 0.1.5')
  #s.add_development_dependency("bluecloth",      "~> 2.2.0")
  #s.add_development_dependency("wlang",          "~> 0.10.2")


  # The version of ruby required by this gem
  #
  # Uncomment and set this if your gem requires specific ruby versions.
  #
  # s.required_ruby_version = ">= 0"

  # The RubyGems version required by this gem
  #
  # s.required_rubygems_version = ">= 0"

  # The platform this gem runs on.  See Gem::Platform for details.
  #
  # s.platform = nil

  # Extensions to build when installing the gem.
  #
  # Valid types of extensions are extconf.rb files, configure scripts
  # and rakefiles or mkrf_conf files.
  #
  s.extensions = []

  # External (to RubyGems) requirements that must be met for this gem to work.
  # It's simply information for the user.
  #
  s.requirements = nil

  # A message that gets displayed after the gem is installed
  #
  # Uncomment and set this if you want to say something to the user
  # after gem installation
  #
  s.post_install_message = "Thanks for installing FalkorLib.\n"

  ################################################################### SECURITY

  # The key used to sign this gem.  See Gem::Security for details.
  #
  #s.signing_key = "0xDD01D5C0"

  # The certificate chain used to sign this gem.  See Gem::Security for
  # details.
  #
  # s.cert_chain = []

  ################################################################### RDOC

  # An ARGV style array of options to RDoc
  #
  # See 'rdoc --help' about this
  #
  s.rdoc_options = []

  # Extra files to add to RDoc such as README
  #
  s.extra_rdoc_files = Dir["README.md"] + Dir["CHANGELOG.md"] + Dir["LICENCE.md"]
end
