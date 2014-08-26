# File::      <tt><%= config[:name] %>.pp</tt>
# Author::    <%= ENV['GIT_AUTHOR_NAME'] %> (<%= ENV['GIT_AUTHOR_MAIL'] %>)
# Copyright:: Copyright (c) <%= Time.now.year %> <%= config[:author] %>
# License::   <%= config[:license] %>
#
# ------------------------------------------------------------------------------
# = Class: <%= config[:name] %>
#
# <%= config[:summary] %>
#
# == Parameters:
#
# $ensure:: *Default*: 'present'. Ensure the presence (or absence) of <%= config[:name] %>
#
# == Actions:
#
# Install and configure <%= config[:name] %>
#
# == Requires:
#
# n/a
#
# == Sample Usage:
#
#     import <%= config[:name] %>
#
# You can then specialize the various aspects of the configuration,
# for instance:
#
#         class { '<%= config[:name] %>':
#             ensure => 'present'
#         }
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
#
# [Remember: No empty lines between comments and class definition]
#
class <%= config[:name] %>(
    $ensure = $<%= config[:name] %>::params::ensure
)
inherits <%= config[:name] %>::params
{
    info ("Configuring <%= config[:name] %> (with ensure = ${ensure})")

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("<%= config[:name] %> 'ensure' parameter must be set to either 'absent' or 'present'")
    }

    case $::operatingsystem {
        debian, ubuntu:         { include <%= config[:name] %>::debian }
        redhat, fedora, centos: { include <%= config[:name] %>::redhat }
        default: {
            fail("Module $module_name is not supported on $operatingsystem")
        }
    }
}

# ------------------------------------------------------------------------------
# = Class: <%= config[:name] %>::common
#
# Base class to be inherited by the other <%= config[:name] %> classes
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
class <%= config[:name] %>::common {

    # Load the variables used in this module. Check the <%= config[:name] %>-params.pp file
    require <%= config[:name] %>::params

    package { '<%= config[:name] %>':
        name    => "${<%= config[:name] %>::params::packagename}",
        ensure  => "${<%= config[:name] %>::ensure}",
    }
    # package { $<%= config[:name] %>::params::extra_packages:
    #     ensure => 'present'
    # }

    if $<%= config[:name] %>::ensure == 'present' {

        # Prepare the log directory
        file { "${<%= config[:name] %>::params::logdir}":
            ensure => 'directory',
            owner  => "${<%= config[:name] %>::params::logdir_owner}",
            group  => "${<%= config[:name] %>::params::logdir_group}",
            mode   => "${<%= config[:name] %>::params::logdir_mode}",
            require => Package['<%= config[:name] %>'],
        }

        # Configuration file
        # file { "${<%= config[:name] %>::params::configdir}":
        #     ensure => 'directory',
        #     owner  => "${<%= config[:name] %>::params::configdir_owner}",
        #     group  => "${<%= config[:name] %>::params::configdir_group}",
        #     mode   => "${<%= config[:name] %>::params::configdir_mode}",
        #     require => Package['<%= config[:name] %>'],
        # }
        # Regular version using file resource
        file { '<%= config[:name] %>.conf':
            path    => "${<%= config[:name] %>::params::configfile}",
            owner   => "${<%= config[:name] %>::params::configfile_owner}",
            group   => "${<%= config[:name] %>::params::configfile_group}",
            mode    => "${<%= config[:name] %>::params::configfile_mode}",
            ensure  => "${<%= config[:name] %>::ensure}",
            #content => template("<%= config[:name] %>/<%= config[:name] %>conf.erb"),
            #source => "puppet:///modules/<%= config[:name] %>/<%= config[:name] %>.conf",
            #notify  => Service['<%= config[:name] %>'],
            require => [
                        #File["${<%= config[:name] %>::params::configdir}"],
                        Package['<%= config[:name] %>']
                        ],
        }

        # # Concat version
        # include concat::setup
        # concat { "${<%= config[:name] %>::params::configfile}":
        #     warn    => false,
        #     owner   => "${<%= config[:name] %>::params::configfile_owner}",
        #     group   => "${<%= config[:name] %>::params::configfile_group}",
        #     mode    => "${<%= config[:name] %>::params::configfile_mode}",
        #     #notify  => Service['<%= config[:name] %>'],
        #     require => Package['<%= config[:name] %>'],
        # }
        # # Populate the configuration file
        # concat::fragment { "${<%= config[:name] %>::params::configfile}_header":
        #     target  => "${<%= config[:name] %>::params::configfile}",
        #     ensure  => "${<%= config[:name] %>::ensure}",
        #     content => template("<%= config[:name] %>/<%= config[:name] %>_header.conf.erb"),
        #     #source => "puppet:///modules/<%= config[:name] %>/<%= config[:name] %>_header.conf",
        #     order   => '01',
        # }
        # concat::fragment { "${<%= config[:name] %>::params::configfile}_footer":
        #     target  => "${<%= config[:name] %>::params::configfile}",
        #     ensure  => "${<%= config[:name] %>::ensure}",
        #     content => template("<%= config[:name] %>/<%= config[:name] %>_footer.conf.erb"),
        #     #source => "puppet:///modules/<%= config[:name] %>/<%= config[:name] %>_footer.conf",
        #     order   => '99',
        # }

        # PID file directory
        # file { "${<%= config[:name] %>::params::piddir}":
        #     ensure  => 'directory',
        #     owner   => "${<%= config[:name] %>::params::piddir_user}",
        #     group   => "${<%= config[:name] %>::params::piddir_group}",
        #     mode    => "${<%= config[:name] %>::params::piddir_mode}",
        # }

        file { "${<%= config[:name] %>::params::configfile_init}":
            owner   => "${<%= config[:name] %>::params::configfile_owner}",
            group   => "${<%= config[:name] %>::params::configfile_group}",
            mode    => "${<%= config[:name] %>::params::configfile_mode}",
            ensure  => "${<%= config[:name] %>::ensure}",
            #content => template("<%= config[:name] %>/default/<%= config[:name] %>.erb"),
            #source => "puppet:///modules/<%= config[:name] %>/default/<%= config[:name] %>.conf",
            notify  =>  Service['<%= config[:name] %>'],
            require =>  Package['<%= config[:name] %>']
        }

        service { '<%= config[:name] %>':
            name       => "${<%= config[:name] %>::params::servicename}",
            enable     => true,
            ensure     => running,
            hasrestart => "${<%= config[:name] %>::params::hasrestart}",
            pattern    => "${<%= config[:name] %>::params::processname}",
            hasstatus  => "${<%= config[:name] %>::params::hasstatus}",
            require    => [
                           Package['<%= config[:name] %>'],
                           File["${<%= config[:name] %>::params::configfile_init}"]
                           ],
            subscribe  => File['<%= config[:name] %>.conf'],
        }
    }
    else
    {
        # Here $<%= config[:name] %>::ensure is 'absent'

    }

}


# ------------------------------------------------------------------------------
# = Class: <%= config[:name] %>::debian
#
# Specialization class for Debian systems
class <%= config[:name] %>::debian inherits <%= config[:name] %>::common { }

# ------------------------------------------------------------------------------
# = Class: <%= config[:name] %>::redhat
#
# Specialization class for Redhat systems
class <%= config[:name] %>::redhat inherits <%= config[:name] %>::common { }



