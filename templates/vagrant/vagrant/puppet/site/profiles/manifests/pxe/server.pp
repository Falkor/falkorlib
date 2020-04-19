# -*- mode: puppet; -*-
# Time-stamp: <Wed 2020-04-15 16:28 svarrette>
###########################################################################################
# Profile (base) class used for a PXE server general settings
#
# Documentation on puppet/pxe class: https://forge.puppet.com/puppet/pxe

class profiles::pxe::server
{
  include ::tftp
  include ::pxe
}
