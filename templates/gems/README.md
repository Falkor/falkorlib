-*- mode: markdown; mode: visual-line; fill-column: 80 -*-

[![Licence](https://img.shields.io/badge/license-MIT-blue.svg)](http://opensource.org/licenses/MIT)
![By Falkor](https://img.shields.io/badge/by-Falkor-blue.svg) [![github](https://img.shields.io/badge/git-github-lightgray.svg)](https://github.com/Falkor/sysadmin-warrior) [![Issues](https://img.shields.io/badge/issues-github-green.svg)](https://github.com/Falkor/sysadmin-warrior/issues)

       Time-stamp: <Mon 2016-02-22 22:04 svarrette>

          _____                       _           _        __          __             _               _______    __          ___  
         / ____|             /\      | |         (_)       \ \        / /            (_)             / / ____|  /\ \        / \ \ 
        | (___  _   _ ___   /  \   __| |_ __ ___  _ _ __    \ \  /\  / /_ _ _ __ _ __ _  ___  _ __  | | (___   /  \ \  /\  / / | |
         \___ \| | | / __| / /\ \ / _` | '_ ` _ \| | '_ \    \ \/  \/ / _` | '__| '__| |/ _ \| '__| | |\___ \ / /\ \ \/  \/ /  | |
         ____) | |_| \__ \/ ____ \ (_| | | | | | | | | | |    \  /\  / (_| | |  | |  | | (_) | |    | |____) / ____ \  /\  /   | |
        |_____/ \__, |___/_/    \_\__,_|_| |_| |_|_|_| |_|     \/  \/ \__,_|_|  |_|  |_|\___/|_|    | |_____/_/    \_\/  \/    | |
                 __/ |                                                                               \_\                      /_/ 
                |___/                                                                                                             
       Copyright (c) 2016 Sebastien Varrette <Sebastien.Varrette@uni.lu>


## Synopsis

SysAdmin Warrior (SAW) is a Command Line Interface (CLI) designed to make the life of system administrator easier

## Installation / Repository Setup

This repository is hosted on [Github](https://github.com/Falkor/sysadmin-warrior). 

* To clone this repository, proceed as follows (adapt accordingly):

        $> mkdir -p ~/git/github.com/Falkor
        $> cd ~/git/github.com/Falkor
        $> git clone https://github.com/Falkor/sysadmin-warrior.git

Now ensure [RVM](https://rvm.io/) is correctly configured for this repository:

     $> rvm current

Configure the dependencies detailed in the [`Gemfile`](Gemfile) through the [Bundler](http://bundler.io/):

     $> gem install bundler
     $> bundle install
     $> rake -T     # should work ;)

**`/!\ IMPORTANT`**: Once cloned, initiate your local copy of the repository by running: 

    $> cd sysadmin-warrior
    $> rake setup

This will initiate the [Git submodules of this repository](.gitmodules) and setup the [git flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) layout for this repository.

Later on, you can upgrade the [Git submodules](.gitmodules) to the latest version by running:

    $> rake git:submodules:upgrade

If upon pulling the repository, you end in a state where another collaborator have upgraded the Git submodules for this repository, you'll end in a dirty state (as reported by modifications within the `.submodules/` directory). In that case, just after the pull, you **have to run** the following to ensure consistency with regards the Git submodules:

    $> rake git:submodules:update




## Issues / Feature request

You can submit bug / issues / feature request using the [`Falkor/sysadmin-warrior` Project Tracker](https://github.com/Falkor/sysadmin-warrior/issues)



## Advanced Topics

### Git

This repository make use of [Git](http://git-scm.com/) such that you should have it installed on your working machine: 

       $> apt-get install git-core # On Debian-like systems
       $> yum install git          # On CentOS-like systems
       $> brew install git         # On Mac OS, using [Homebrew](http://mxcl.github.com/homebrew/)
       $> port install git         # On Mac OS, using MacPort

Consider these resources to become more familiar (if not yet) with Git:

* [Simple Git Guide](http://rogerdudler.github.io/git-guide/)
* [Git book](http://book.git-scm.com/index.html)
* [Github:help](http://help.github.com/mac-set-up-git/)
* [Git reference](http://gitref.org/)

At least, you shall configure the following variables

       $> git config --global user.name "Your Name Comes Here"
       $> git config --global user.email you@yourdomain.example.com
       # configure colors
       $> git config --global color.diff auto
       $> git config --global color.status auto
       $> git config --global color.branch auto

Note that you can create git command aliases in `~/.gitconfig` as follows: 

       [alias]
           up = pull origin
           pu = push origin
           st = status
           df = diff
           ci = commit -s
           br = branch
           w  = whatchanged --abbrev-commit
           ls = ls-files
           gr = log --graph --oneline --decorate
           amend = commit --amend

Consider my personal [`.gitconfig`](https://github.com/Falkor/dotfiles/blob/master/git/.gitconfig) as an example -- if you decide to use it, simply copy it in your home directory and adapt the `[user]` section. 

### [Git-flow](https://github.com/nvie/gitflow)

The Git branching model for this repository follows the guidelines of
[gitflow](http://nvie.com/posts/a-successful-git-branching-model/).
In particular, the central repository holds two main branches with an infinite lifetime:

* `production`: the *production-ready* branch
* `devel`: the main branch where the latest developments interviene. This is the *default* branch you get when you clone the repository.

Thus you are more than encouraged to install the [git-flow](https://github.com/nvie/gitflow) extensions following the [installation procedures](https://github.com/nvie/gitflow/wiki/Installation) to take full advantage of the proposed operations. The associated [bash completion](https://github.com/bobthecow/git-flow-completion) might interest you also.

### Releasing mechanism

The operation consisting of releasing a new version of this repository is automated by a set of tasks within the root `Rakefile`.

In this context, a version number have the following format:

      <major>.<minor>.<patch>[-b<build>]

where:

* `< major >` corresponds to the major version number
* `< minor >` corresponds to the minor version number
* `< patch >` corresponds to the patching version number
* (eventually) `< build >` states the build number _i.e._ the total number of commits within the `devel` branch.

Example: \`1.0.0-b28\`

The current version number is stored in the root file `VERSION`. __/!\ NEVER MAKE ANY MANUAL CHANGES TO THIS FILE__

For more information on the version, run:

     $> rake version:info

If a new version number such be bumped, you simply have to run:

      $> rake version:bump:{major,minor,patch}

This will start the release process for you using `git-flow`.
Once you have finished to commit your last changes, make the release effective by running:

      $> rake version:release

It will finish the release using `git-flow`, create the appropriate tag in the `production` branch and merge all things the way they should be.

### Ruby stuff: RVM, Rakefile and Ruby gems

The various operations that can be conducted from this repository are piloted from a [`Rakefile`](https://github.com/ruby/rake) and assumes you have a running [Ruby](https://www.ruby-lang.org/en/) installation. You'll also need [Ruby Gems](https://rubygems.org/) to facilitate the installation of ruby libraries.

       $> apt-get install ruby rubygems  # On Debian-like systems

Install the [rake](https://rubygems.org/gems/rake) gem as follows:

       $> gem install rake

In order to have a consistent environment among the collaborators of this project, [Bundler](http://bundler.io/) is also used. Configuration of [Bundler](http://bundler.io/) is made via the [`Gemfile[.lock]` files](http://bundler.io/v1.3/gemfile.html).

Last but not least, I like to work on [Sandboxed environments](https://hpc.uni.lu/blog/2014/create-a-sandboxed-python-slash-ruby-environment/) and a great tool for that is [RVM](https://rvm.io/).
[RVM](https://rvm.io/) gives you compartmentalized independent ruby setups. 
This means that ruby, gems and irb are all separate and self-contained - from the system, and from each other.  Sandboxing with [RVM](https://rvm.io/) is straight-forward via the [notion of gemsets](https://rvm.io/gemsets) and is managed via the `.ruby-{version,gemset}` files. 

If things are fine, you should  be able to access the list of available tasks by running:

       $> rake -T

You probably want to activate the bash-completion for rake tasks.
I personally use the one provided [here](https://github.com/ai/rake-completion).

## Licence

This project is released under the terms of the [MIT](LICENCE) licence. 

[![Licence](http://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/License_icon-mit-2.svg/200px-License_icon-mit-2.svg.png)](http://opensource.org/licenses/MIT)

## Contributing

That's quite simple:

1. [Fork](https://help.github.com/articles/fork-a-repo/) it
2. Create your own feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new [Pull Request](https://help.github.com/articles/using-pull-requests/)
