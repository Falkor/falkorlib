-*- mode: markdown; mode: auto-fill; fill-column: 80 -*-

        Time-stamp: <Ven 2014-06-20 00:01 svarrette>
                    _____     _ _              _     _ _
                   |  ___|_ _| | | _____  _ __| |   (_) |__
                   | |_ / _` | | |/ / _ \| '__| |   | | '_ \
                   |  _| (_| | |   < (_) | |  | |___| | |_) |
                   |_|  \__,_|_|_|\_\___/|_|  |_____|_|_.__/

       
        Copyright (c) 2012-2014 Sebastien Varrette <Sebastien.Varrette@uni.lu>
        https://github.com/Falkor/falkorlib


# FalkorLib

| FalkorLib         |
| ----------------- |
| [MIT][license]    |
| [![Gem Version](https://badge.fury.io/rb/falkorlib.png)](http://badge.fury.io/rb/falkorlib) |
| [![Build Status](https://travis-ci.org/Falkor/falkorlib.png)](https://travis-ci.org/Falkor/falkorlib) |
| [Official Gem site](https://rubygems.org/gems/falkorlib) |
| [GitHub Homepage](https://github.com/Falkor/falkorlib) |

Sebastien Varrette aka Falkor's Common library to share Ruby code and `{rake,cap}`
tasks. 

## Installation

You'll typically want to install FalkorLib using [Bundler](http://bundler.io/).
To do this, simply add this line to your application's `Gemfile`:

	gem 'falkorlib'
	
And then execute:

	$> bundle

Or install it yourself as:

	$> gem install falkorlib

**Note** you probably wants to do the above within an isolated environment. See below for some explanation on this setup. 

## Usage 

This library features two aspect

* A set of toolbox functions / components I'm using everywhere in my Ruby developments, more specifically a set of modules: 
  * `FalkorLib::Common`: Recipe for all my toolbox and versatile Ruby functions I'm using everywhere. 
    You'll typically want to include the `FalkorLib::Common` module to bring the corresponding definitions into your scope. Example:
       
			require 'falkorlib'
			include FalkorLib::Common
			
			info 'exemple of information text'
			really_continue?
			run %{ echo 'this is an executed command' }
			
			Falkor.config.debug = true
			run %{ echo 'this is a simulated command that *will not* be executed' }
			error "that's an error text, let's exit with status code 1"all my toolbox printing functions I'm using everywhere 
    
    
  * `FalkorLib::Config`: all configuration aspects, implemented using [configatron](https://github.com/Falkor/falkorlib). `FalkorLib.config` canbe used to customized the defaults settings, for instance by; 
    
    		FalkorLib.config do |c|
            	c.debug = true
        	end
  	
   	 
  * `FalkorLib::Git`: all git operations
  * `FalkorLib::Version`: versioning management 

* Some [rake](https://github.com/jimweirich/rake) tasks to facilitate common operations.
  In general you can simply embedded my tasks by adding the following header in your `Rakefile`:
  
  		# In Rakefile
		require "falkorlib/<object>_tasks"
  
  or 
  
  		#In Rakefile 
  		require "falkorlib/tasks/<object>"

### `FalkorLib` Ruby Modules / Classes Documentation

[Online documentation](https://rubygems.org/gems/falkorlib) is a available. 
Yet to get the latest version, you might want to run 

	$> rake yard:doc

This will generate the documentation in `doc/api/` folder. 

Statistics on the documentation generation (in particular *non*-documented components) can be obtained by 

	$> rake yard:stats 


### Overview of the implemented Rake tasks

You can find the list of implemented Rake tasks (detailed below) in the `lib/falkorlib/*_tasks.rb` files

For a given task object `<obj>` (*git* tasks for instance as proposed in `lib/falkorlib/git_tasks.rb`), you can specialize the corresponding configuration by using the block construction of `FalkorLib.config do |c| ... end` **before** requiring the task file:

	# In Rakefile
	require 'falkorlib'
	
	# Configuration for the 'toto' tasks
	FalkorLib.config.toto do |c|
		toto.foo = bar   # see `rake falkorlib:conf` to print the current configuration of FalkorLib
	end 
	
	require "falkorlib/tasks/toto"    # OR require "falkorlib/toto_tasks"


## Proposed Rake tasks


* **Gem Management**: see `lib/falkorlib/tasks/gem.rake`
* **Git Management**
* ... TODO: complete list		


## Implementation details

If you want to contribute to the code, you shall be aware of the way I organize this gem and implementation details.   

### [RVM](https://rvm.io/) setup

Get the source of this library by cloning the repository as follows: 

	$> git clone git://github.com/Falkor/falkorlib.git

You'll end in the `devel` branch. The precise branching model is explained in
the sequel. 

If you use [RVM](http://beginrescueend.com/), you perhaps wants to create a
separate gemset so that we can create and install this gem in a clean
environment. To do that, proceed as follows:

    $> rvm gemset create falkorlib
    $> rvm gemset use falkorlib

Install bundler if it's not yet done: 

    $> gem install builder

Then install the required dependent gems as follows: 

    $> bundle install 


### Git Branching Model

The Git branching model for this repository follows the guidelines of [gitflow](http://nvie.com/posts/a-successful-git-branching-model/). 
In particular, the central repository holds two main branches with an infinite lifetime: 

* `production`: the branch holding tags of the successive releases of this tutorial
* `devel`: the main branch where the sources are in a state with the latest delivered development changes for the next release. This is the *default* branch you get when you clone the repo, and the one on which developments will take places. 

You should therefore install [git-flow](https://github.com/nvie/gitflow), and probably also its associated [bash completion](https://github.com/bobthecow/git-flow-completion). 
Also, to facilitate the tracking of remote branches, you probably wants to install [grb](https://github.com/webmat/git_remote_branch) (typically via ruby gems). 

Then, to make your local copy of the repository ready to use my git-flow workflow, you have to run the following commands once you cloned it for the first time:

      $> rake setup # Not yet implemented!

### Working in a separate project

To illustrate the usage of the library as a regular user would do, you are advised to dedicate a directory for your tests. Here is for instance the layout of my testing directory:

	$> cd FalkorLibTests
	$> tree .
	.
	├── Gemfile
	├── Gemfile.lock
	├── Rakefile
	└── test
    	└── tester.rb  # in a subdirectory on purpose

	$> cat cat Gemfile 
	source "https://rubygems.org"
	gem 'falkorlib', :path => '~/git/github.com/Falkor/falkorlib'   # or whichever path that works for you

Adapt the `Rakefile` and `tester.rb` file to reflect your tests.


### RSpec tests

I try to define a set of unitary tests to validate the different function of my library using [Rspec](http://rspec.info/)

You can run these tests by issuing:

	$> rake rspec
	
By conventions, you will find all the currently implemented tests in the `spec/` directory, in files having the `_spec.rb` suffix. This is expected from the `rspec` task of the Rakefile (see `lib/falkorlib/tasks/rspec.rake`) for details.   


**Important** Kindly stick to this convention, and feature tests for all definitions/classes/modules you might want to add to `FalkorLib`.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Directory Organization

By default, the gem take all files included in the `.Manifest.txt` file on the
root of the project. Entries of the manifest file are interpreted as `Dir[...]`
patterns so that lazy people may use wilcards like `lib/**/*` 

__IMPORTANT__ If you want to add a file/directory to this gem, remember to add
the associated entry into the manifest file `.Manifest.txt`


## Resources

### Git 

You should become familiar (if not yet) with Git. Consider these resources: 

* [Git book](http://book.git-scm.com/index.html)
* [Github:help](http://help.github.com/mac-set-up-git/)
* [Git reference](http://gitref.org/)

### Links

* [Official Gem site](https://rubygems.org/gems/falkorlib)
* [GitHub](https://github.com/Falkor/falkorlib)
