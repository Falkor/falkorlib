Templates
=========

Puppet supports templates and templating via ERB, which is part of the Ruby
standard library and is used for many other projects including Ruby on Rails.
Templates allow you to manage the content of template files, for example
configuration files that cannot yet be managed as a Puppet type. 

Learn more [here](http://projects.puppetlabs.com/projects/puppet/wiki/Puppet_Templating)

You can use templates like this: 

    class <%= config[:name] %> {
        package { <%= config[:name].gsub(/^puppet-/, '') %>: ensure => latest }
        file { "/etc/<%= config[:name] %>.conf":
             content => template("<%= config[:name] %>/myfile.erb")
        }
    }

The templates are searched for in:

    $templatedir/<%= config[:name] %>/myfile.erb
    $modulepath/<%= config[:name] %>/templates/myfile.erb

