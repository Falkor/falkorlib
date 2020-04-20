# File::      <tt>default.pp</tt>
# Author::    UL HPC Team (<hpc-team@uni.lu>)
# Copyright:: Copyright (c) 2020 Sebastien Varrette
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
node default {
  # Setup pre and post run stages
  # Typically these are only needed in special cases but are good to have
  stage { ['pre', 'post']: }
  Stage['pre'] -> Stage['main'] -> Stage['post']
  Package{ ensure => 'present' }

  # Check that the hiera configuration is working...
  # if not the puppet provisioning will fail.
  $msg=lookup('msg')
  notice("Role: ${::role}")
  notice("Welcome Message: '${msg}'")

  if (lookup('profiles', undef, undef, false)) {
    lookup('profiles', {merge => unique}).contain
  }
}
