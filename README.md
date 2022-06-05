[![Gem Version](https://badge.fury.io/rb/falkorlib.svg)](https://badge.fury.io/rb/falkorlib)
[![Build
Status](https://travis-ci.org/Falkor/falkorlib.svg?branch=devel)](https://travis-ci.org/Falkor/falkorlib)
[![Test
Coverage](https://api.codeclimate.com/v1/badges/9f1c7762f29572b3f8f0/test_coverage)](https://codeclimate.com/github/Falkor/falkorlib/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/9f1c7762f29572b3f8f0/maintainability)](https://codeclimate.com/github/Falkor/falkorlib/maintainability)
[![Inline docs ](http://inch-ci.org/github/Falkor/falkorlib.svg)](http://inch-ci.org/github/Falkor/falkorlib)[![Liberapay receiving](https://img.shields.io/liberapay/receives/Falkor.svg)](https://liberapay.com/Falkor/donate)

                    _____     _ _              _     _ _
                   |  ___|_ _| | | _____  _ __| |   (_) |__
                   | |_ / _` | | |/ / _ \| '__| |   | | '_ \
                   |  _| (_| | |   < (_) | |  | |___| | |_) |
                   |_|  \__,_|_|_|\_\___/|_|  |_____|_|_.__/


        Copyright (c) 2012-2022 Sebastien Varrette <Sebastien.Varrette@uni.lu>

Sebastien Varrette aka Falkor's Common library to share Ruby code, `{rake,cap}`
tasks and project templates

* [MIT Licence](Licence.md)
* [Official Gem site](https://rubygems.org/gems/falkorlib)
* [GitHub Homepage](https://github.com/Falkor/falkorlib)

## Installation

You'll typically want to install FalkorLib using [Bundler](http://bundler.io/).
To do this, simply add this line to your application's `Gemfile`:

	gem 'falkorlib'

And then execute:

	$> bundle

Or install it yourself as:

	$> gem install falkorlib

**Note** you probably wants to do the above within an isolated environment. See
  below for some explanation on this setup.

## Usage

This library features two aspects

* a binary `falkor` I use daily to bootstrap and operate with the projects I'm
  working one -- see below for an brief overview of the provided commands

* A set of toolbox functions / components I'm using everywhere in my Ruby
  developments, more specifically a set of modules:
  - `FalkorLib::Common`: Recipe for all my toolbox and versatile Ruby functions
    I'm using everywhere.
    You'll typically want to include the `FalkorLib::Common` module to bring the
    corresponding definitions into your scope. Example:

    ```ruby
    require 'falkorlib'
    include FalkorLib::Common

    info 'exemple of information text'
    really_continue?
    run %{ echo 'this is an executed command' }

    Falkor.config.debug = true
    run %{ echo 'this is a simulated command that *will not* be executed' }
    error "that's an error text, let's exit with status code 1"all my toolbox printing functions I'm using everywhere
    ```

  * `FalkorLib::Config`: all configuration aspects, implemented using [configatron](https://github.com/Falkor/falkorlib). `FalkorLib.config` canbe used to customized the defaults settings, for instance by;

    ```ruby
    FalkorLib.config do |c|
       c.debug = true
    end
    ```

    __IMPORTANT__: You can also place a special file `.falkorlib.yaml` to customize the
    FalkorLib settings. Most probably, you shall ignore this file in your
    `.gitignore` so you can place there your private settings (tokens etc.)

  - `FalkorLib::Git`: all [git](http://git-scm.com/) operations
  - `FalkorLib::GitFlow`: all [git-flow](http://nvie.com/posts/a-successful-git-branching-model/) operations
  - `FalkorLib::Version`: for the [semantic versioning](http://semver.org/) management of your project.
  - `FalkorLib::Puppet`: for all [puppet](http://puppetlabs.com) operations
  - `FalkorLib::Bootstrap`: for all project bootstrapping


* Some [rake](https://github.com/jimweirich/rake) tasks to facilitate common operations.
  In general you can simply embedded my tasks by adding the following header in your `Rakefile`:

  		# In Rakefile
        require "falkorlib"

        ## Place-holder to customize the configuration of the <object> tasks,
        ## Typically by altering FalkorLib.config.<object>

		require "falkorlib/tasks/<object>" # OR require "falkorlib/<object>_tasks"

## `FalkorLib` Ruby Modules / Classes Documentation

[Online documentation](https://rubygems.org/gems/falkorlib) is a available.
Yet to get the latest version, you might want to run

	$> rake yard:doc

This will generate the documentation in `doc/api/` folder.

Statistics on the documentation generation (in particular *non*-documented components) can be obtained by

	$> rake yard:stats

## Overview of the `falkor` CLI

This library comes with a CLI `falkor`, providing the following [sub] commands.

__Base commands__

| Command                            | Description                                                       |
|------------------------------------|-------------------------------------------------------------------|
| `falkor --version, -V`             | Print the version number of Falkor[Lib]                           |
| `falkor help [COMMAND]`            | Describe available commands or one specific command               |
| `falkor gitcrypt <PATH> [options]` | Initialize git-crypt for the current repository                   |
| `falkor init <PATH> [options]`     | Bootstrap a Git[flow] Repository                                  |
| `falkor mkdocs [options]`          | Initialize mkdocs for the current project                         |
| `falkor motd <PATH> [options]`     | Initiate a 'motd' file - message of the day                       |
| `falkor vagrant [options]`         | Initialize vagrant for the current project                        |

__`falkor link <type> [path]`__

Initialize a special symlink in `<path>` (the current directory by default)

| Command                         | Description                                                                                               |
|---------------------------------|-----------------------------------------------------------------------------------------------------------|
| `falkor link help [COMMAND]`    | Get help on the corresponding sub command                                                                 |
| `falkor link make [options]`    | Create a symlink to one of [Falkor's Makefile](https://github.com/Falkor/Makefiles), set as Git submodule |
| `falkor link rootdir [options]` | Create a symlink `.root` which targets the root of the repository                                         |

__`falkor new <stuff> [path]`__

Initialize the directory `<path>` (the current directory by default) with one of FalkorLib's template(s)

| Command                                 | Description                                                    |
|-----------------------------------------|----------------------------------------------------------------|
| `falkor new help [COMMAND]`             | Describe subcommands or one specific subcommand                |
| `falkor new article [options]`          | Bootstrap a LaTeX Article                                      |
| `falkor new letter [options]`           | LaTeX-based letter                                             |
| `falkor new license [options]`          | Generate an Open-Source License for your project               |
| `falkor new make [options]`             | Initiate one of Falkor's Makefile                              |
| `falkor new pyenv PATH [options]`       | Initialize pyenv/direnv                                        |
| `falkor new readme PATH [options]`      | Initiate a README file in the PATH directory ('./' by default) |
| `falkor new repo NAME [options]`        | Bootstrap a Git Repository                                     |
| `falkor new rvm PATH [options]`         | Initialize RVM                                                 |
| `falkor new slides [options]`           | Bootstrap LaTeX Beamer slides                                  |
| `falkor new trash PATH`                 | Add a Trash directory                                          |
| `falkor new versionfile PATH [options]` | initiate a VERSION file                                        |

__`falkor make <type> [path]`__

| Command                     | Description                                           |
|-----------------------------|-------------------------------------------------------|
| `falkor new help [COMMAND]` | Describe subcommands or one specific subcommand       |
| `falkor make generic`       | Symlink to Generic Makefile for sub directory         |
| `falkor make gnuplot`       | Symlink to a Makefile to compile GnuPlot scripts      |
| `falkor make latex`         | Symlink to a Makefile to compile LaTeX documents      |
| `falkor make repo`          | Create a root Makefile piloting repository operations |


A ZSH completion files is also maintained for this command, you'll find it in [`completion/_falkor`](completion/_falkor)

## Overview of the implemented Rake tasks

You can find the list of implemented Rake tasks (detailed below) in the
`lib/falkorlib/*_tasks.rb` files

As mentioned above, for a given task object `<obj>` (*git* tasks for instance as
proposed in `lib/falkorlib/git_tasks.rb`), you can specialize the corresponding
configuration by using the block construction of `FalkorLib.config do |c|
... end` **before** requiring the task file:

	# In Rakefile
	require 'falkorlib'

	# Configuration for the 'toto' tasks
	FalkorLib.config.toto do |c|
		toto.foo = bar   # see `rake falkorlib:conf` to print the current configuration of FalkorLib
	end

	require "falkorlib/tasks/toto"    # OR require "falkorlib/toto_tasks"


## Proposed Rake tasks

FalkorLib is meant to facilitate many common operations performed within your
projects and piloted via a
[Rakefile](https://github.com/jimweirich/rake/blob/master/doc/rakefile.rdoc).

### Bootstrapping the project

Within your fresh new directory that will hold your project data
(`/path/to/myproject` for instance), you'll need to bootstrap the following
files:

* `.ruby-{version,gemset}`: [RVM](https://rvm.io/) configuration, use the name of the
  project as [gemset](https://rvm.io/gemsets) name
* `Gemfile`: used by `[bundle](http://bundler.io/)`, initialized with `bundle
init` that contain _at least_ the line `gem 'falkorlib'`
* `Gemfile.lock` will be automatically generated once you run `bundle` to
  install the configured gems within your `Gemfile`.
* `Rakefile`: the placeholder for your project tasks.

__Assuming you are in your project directory `/path/to/myproject`__ and that RVM
is installed on your system, you can bootstrap the above file by copy/pasting
all the following command-lines in your terminal:

```
bash <(curl --silent https://raw.githubusercontent.com/Falkor/falkorlib/devel/binscripts/bootstrap.sh)
```
_Note_: you probably want to
[take a look at that script content](https://github.com/Falkor/falkorlib/blob/devel/binscripts/bootstrap.sh)
before running the above command.

Alternatively, assuming you have installed the `falkorlib` gem, you can create a
minimal `Rakefile` (containing `require 'falkorlib'`) and run `rake bootstrap:rvm`.

You can now complete your `Rakefile` depending on the tasks you wish to see.
Below is a detailed overview of the implemented rake tasks in `FalkorLib`.

### Git[Flow] and Versioning Management

Nearly all my projects are organized under [Git](http://git-scm.com/) using the
[gitflow](http://nvie.com/posts/a-successful-git-branching-model/) branching
model.
Thus I create a flexible framework to pilot the interaction with Git, git-flow,
git submodules, git subtrees etc.

Typical [Minimal] setup of your Rakefile, hopefully self-speaking

```
require 'falkorlib'

## placeholder for custom configuration of FalkorLib.config.git and
## FalkorLib.config.gitflow

# Git[Flow] and Versioning management
require "falkorlib/tasks/git"    # OR require "falkorlib/git_tasks"
```

If git is not yet configured in your repository, you'll end with the following
tasks:

```
$> rake -T
fatal: Not a git repository (or any of the parent directories): .git
/!\ WARNING: Git is not initialized for this directory.
/!\ WARNING: ==> consider running 'rake git[:flow]:init' to be able to access the regular git Rake tasks
rake falkorlib:conf  # Print the current configuration of FalkorLib
rake git:flow:init   # Initialize Git-flow repository
rake git:init        # Initialize Git repository
```

### Git-flow configuration

Configuration aspects for git-flow are stored in the
`FalkorLib::Config::GitFlow` module (defined in `lib/falkorlib/git/flow.rb`).

* __[Default Configuration for Gitflow](http://rubydoc.info/gems/falkorlib/FalkorLib/Config/GitFlow)__

You can easily customize these default settings in your Rakefile, __before__ the
`require "falkorlib/tasks/git"` lines. Just proceed with ruby magic as follows:

```
require 'falkorlib'
[...]
# Git flow customization
FalkorLib.config.gitflow do |c|
	c[:branches] = {
		:master	 => 'production',
		:develop => 'devel'
	}
end
[...]
require "falkorlib/tasks/git"
```

Now you can run `rake git:flow:init` to bootstrap your repository with git-flow.

Running `rake -T` shall now raises many new tasks linked to git-flow operations:

```
$> rake -T
rake falkorlib:conf           # Print the current configuration of FalkorLib
rake git:feature:finish       # Finalize the feature operation
rake git:feature:start[name]  # Start a new feature operation on the repository using the git-flow framework
rake git:flow:init            # Initialize your local clone of the repository for the git-flow management
rake setup                    # Setup the repository
rake version:bump:major       # Prepare the major release of the repository
rake version:bump:minor       # Prepare the minor release of the repository
rake version:bump:patch       # Prepare the patch release of the repository
rake version:info             # Get versioning information
rake version:release          # Finalize the release of a given bumped version
```
_Note_: assuming you configured `git-flow` without any `master`, you probably
want now to delete this default branch by running `git branch -d master`

So you can now:

* Start/finish features with `rake git:feature:{start,finish}`
* perform basic git operation with `rake git:{fetch,push,up}`
* initiate semantic versioning of the project (typically with a `VERSION` file
  at the root of your project) with `rake version:bump:{patch,minor,patch}`.
  Note that these tasks make use of the git flow `release` feature.

  Concluding a release is performed by `rake version:release`

### Git submodules configuration

Configuration aspects for git are stored in the
`FalkorLib::Config::Git` module (defined in `lib/falkorlib/git/base.rb`).

* __[Default Configuration for Git](http://rubydoc.info/gems/falkorlib/FalkorLib/Config/Git)__

In particular, you can add as many
[Git submodules](http://git-scm.com/book/en/Git-Tools-Submodules) as you wish as
follows:

```
require 'falkorlib'
[...]
# Git customization
FalkorLib.config.git do |c|
	c[:submodules] = {
		'veewee' => {
			:url    => 'https://github.com/jedi4ever/veewee.git',
			:branch => 'master'    # not mandatory if 'master' actually
		}
	}
end
[...]
require "falkorlib/tasks/git"
```

You can now bootstrap the configured sub-module(s) by running `rake
git:submodules:init`.
In the above scenario, the Git sub-module `veewee` will be initiated in
`.submodules/veewee` -- you can change the root submodules directory by altering
`FalkorLib.config.git[:submodulesdir]` value (see [defaults](http://rubydoc.info/gems/falkorlib/FalkorLib/Config/Git)).

Now you will have new rake tasks available:

      $> rake -T
      [...]
      rake git:submodules:init      # Initialize the Git subtrees defined in FalkorLib.config.git.submodules
      rake git:submodules:update    # Update the git submodules from '/private/tmp/toto'
      rake git:submodules:upgrade   # Upgrade the git submodules to the latest HEAD commit -- USE WITH CAUTION
      [...]


### Git subtree configuration

You can also add as many
[Git subtrees](http://blogs.atlassian.com/2013/05/alternatives-to-git-submodule-git-subtree/)
as you wish -- as follows:

```
require 'falkorlib'
[...]
# Git customization
FalkorLib.config.git do |c|
	 c[:subtrees] = {
		 'easybuild/easyblocks' => {
			 :url	 => 'https://github.com/ULHPC/easybuild-easyblocks.git',
			 :branch => 'develop'
		 },
		 'easybuild/easyconfigs' => {
			 :url	 => 'https://github.com/ULHPC/easybuild-easyconfigs.git',
			 :branch => 'uni.lu'
		 },
     }
end
[...]
require "falkorlib/tasks/git"
```

You can now bootstrap the configured sub-tree(s) by running `rake
git:subtrees:init`.
In the above scenario, the Git sub-trees will be initiated in the
sub-directories `easybuild/easyblocks` and `easybuild/easyconfigs`.

Now you will have new rake tasks available:

```
[...]
rake git:subtrees:diff        # Show difference between local subtree(s) and their remotes
rake git:subtrees:init        # Initialize the Git subtrees defined in FalkorLib.config.git.subtrees
rake git:subtrees:up          # Pull the latest changes from the remote to the local subtree(s)
[...]
```

### Gem Management

See `lib/falkorlib/tasks/gem.rake`: you just have to add the following line to
your Rakefile:

```
require "falkorlib/tasks/gem"    # OR require "falkorlib/gem_tasks"
```

Also, you can adapt the versioning scheme to target a gem management by altering the
[default configurations](http://rubydoc.info/gems/falkorlib/FalkorLib/Config/Versioning)

```
require "falkorlib"
[...]
# Adapt the versioning aspects to target a gem
FalkorLib.config.versioning do |c|
	c[:type] = 'gem'
    c[:source]['gem'][:filename] = 'lib/mygem/version.rb',  # the file to patch
end
[...]
require "falkorlib/tasks/git"
require "falkorlib/tasks/gem"
```

This will bring the following tasks:

```
$> rake -T
[...]
rake build                    # Builds all packages
rake clean                    # Remove any temporary products
rake clobber                  # Remove any generated file
rake gem:console              # Spawns an Interactive Ruby Console
rake gem:info                 # Informations on the gem
rake gem:release              # Release the gem
rake version:bump:major       # Prepare the major release of the repository
rake version:bump:minor       # Prepare the minor release of the repository
rake version:bump:patch       # Prepare the patch release of the repository
rake version:info             # Get versioning information
rake version:release          # Finalize the release of a given bumped version
```
If your gem is coupled with [Code Climate](https://codeclimate.com/), you might
wish to set the code climate token to report the test coverage for you gem (see
[these instructions](http://docs.codeclimate.com/article/104-how-do-i-set-up-test-coverage-for-one-of-my-repos)).
To avoid exposing this token in your (potentially public) repository, simply
set that token in `.falkorlib.yaml` (ignored you shall ignore in your
`.gitignore`) as follows:

```
:tokens:
  :code_climate: 'ACDDD1111222223333....'
```

## FalkorLib Developments / Implementation details

If you want to contribute to the code, you shall be aware of the way I organized
this gem and its implementation details.

### [RVM](https://rvm.io/) setup

Get the source of this library by cloning the repository as follows:

	$> git clone git://github.com/Falkor/falkorlib.git

You'll end in the `devel` branch. The precise branching model is explained in
the sequel.

If you use [RVM](http://beginrescueend.com/), you perhaps wants to create a
separate gemset so that we can create and install this gem in a clean
environment.

* create a file `.ruby-gemset` containing the name of the wished Gemset
  (`falkorlib` for instance)
* create a file `.ruby-version` containing the wished version of Ruby (`2.1.0`
  for instance - check on [Travis](https://travis-ci.org/Falkor/falkorlib) for
  the supported version)

To load these files, you have to re-enter the directory where you cloned
`falkorlib` and placed the above files

To do that, proceed as follows:

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

      $> rake setup

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
	gem 'falkorlib'  #, :path => '~/git/github.com/Falkor/falkorlib'   # or whichever path that works for you

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
