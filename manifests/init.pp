# @summary Add Puppet Master CA and Agent certificates to the Windows Certificate Store.
#
# This module takes the Puppet Master CA certificate and Puppet Agent client
# certificate and imports them into the Windows Certificate Store and marks the
# public key as Not Exportable. This is useful to allow Windows applications to
# consume these certificates in a Windows way. For example:
# - for client certificate based authentication in EAP in 802.1x
# - for automatically trusting the PE Console in web browsers
# - for encrypting secrets for the client to consume, for example Hiera eYaml
# - for encrypting secrets for the server to consume, for example encrypting Bitlocker keys
#
# @example Just import the Puppet Master CA certificate
#   include windows_puppet_certificates
#
# @example Import master and client certificate
#   class { 'windows_puppet_certificates':
#     manage_master_cert => true,
#     manage_client_cert => true,
#   }
#
# @param ensure
#   Valid options are `present` and `absent`
#   Default: present
# @param manage_master_cert
#   When set to true the module will import the Puppet Master CA certificate
#   into the computer Trusted Root CA certificate store.
#   Default: true
# @param manage_client_cert
#   When set to true the module will import the Puppet Client certificate, and
#   private key, into the computer Personal certificate store.
#   Default: false - importing a private key should be an explicit decision.
class windows_puppet_certificates(
    Enum['present', 'absent'] $ensure = 'present',
    Boolean $manage_master_cert = true,
    Boolean $manage_client_cert = false,
    String $confdir_path = 'c:/programdata/puppetlabs/puppet/etc',
  ) {
  if $manage_master_cert {
    # Add the Puppet Master certificate into the Trusted Root CA
    windows_puppet_certificates::windows_certificate { 'puppet_master_windows_certificate':
      ensure    => $ensure,
      cert_path => "${confdir_path}/ssl/certs/ca.pem",
      key_path  => undef,
      cert_type => 'trusted_root_ca',
    }
  }

  if $manage_client_cert {
    # Add the client certificate (with private key) to the Personal certificates
    windows_puppet_certificates::windows_certificate { 'puppet_client_windows_certificate':
      ensure    => $ensure,
      cert_path => "${confdir_path}/ssl/certs/${::clientcert}.pem",
      key_path  => "${confdir_path}/ssl/private_keys/${::clientcert}.pem",
      cert_type => 'personal',
    }
  }
}

