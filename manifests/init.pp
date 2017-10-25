class windows_puppet_certificates(
    Enum['present', 'absent'] $ensure = 'present',
    Boolean $manage_master_cert = true,
    Boolean $manage_client_cert = false,
  ) {
  if $manage_master_cert {
    # Add the Puppet Master certificate into the Trusted Root CA
    windows_puppet_certificates::windows_certificate { 'puppet_master_windows_certificate':
      ensure    => $ensure,
      cert_path => "${::settings::confdir}/ssl/certs/ca.pem",
      key_path  => undef,
      cert_type => 'trusted_root_ca',
    }
  }

  if $manage_client_cert {
    # Add the client certificate (with private key) to the Personal certificates
    windows_puppet_certificates::windows_certificate { 'puppet_client_windows_certificate':
      ensure    => $ensure,
      cert_path => "${::settings::confdir}/ssl/certs/${::clientcert}.pem",
      key_path  => "${::settings::confdir}/ssl/private_keys/${::clientcert}.pem",
      cert_type => 'personal',
    }
  }
}
