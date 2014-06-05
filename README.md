-*- mode: markdown; mode: auto-fill; fill-column: 80 -*-

        Time-stamp: <Jeu 2014-06-05 11:58 svarrette
                      _____     _ _              _ _ _
                     |  ___|_ _| | | _____  _ __| (_) |__
                     | |_ / _` | | |/ / _ \| '__| | | '_ \
                     |  _| (_| | |   < (_) | |  | | | |_) |
                     |_|  \__,_|_|_|\_\___/|_|  |_|_|_.__/
        
        Copyright (c) 2012-2014 Sebastien Varrette <Sebastien.Varrette@uni.lu>
        https://github.com/Falkor/falkorlib


# FalkorLib

[![Build Status](https://travis-ci.org/Falkor/falkorlib.png)](https://travis-ci.org/Falkor/falkorlib)

Sebastien Varrette aka Falkor's Common library to share Ruby code and `{rake,cap}`
tasks. 

## Installation

Add this line to your application's `Gemfile`:

	gem 'falkorlib'
	
And then execute:

	$> bundle

Or install it yourself as:

	$> gem install falkorlib

**Note** you probably wants to do the above within an isolated environment. See below for some explanation on this setup. 

## Usage 

This library features two aspect

* a set of toolbox functions I'm using everywhere in my Ruby developments, structures in various modules below the `FalkorLib` module
* some [rake](https://github.com/jimweirich/rake) tasks to facilitate common operations. 





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


 


### Building the gem from the source

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

### Gem installation 

Add this line to your application's Gemfile:

    gem 'falkorlib'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install falkorlib

## Usage

TODO: Write usage instructions here



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

https://github.com/Falkor/falkorlib
