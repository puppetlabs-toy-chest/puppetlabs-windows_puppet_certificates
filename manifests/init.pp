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
