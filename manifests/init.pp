class windows_puppet_certificates {
  # Add the Puppet Master certificate into the Trusted Root CA
  windows_puppet_certificates::windows_cert { 'puppet_master_windows_certificate':
    cert_path => "${::settings::confdir}/ssl/certs/ca.pem",
    key_path  => '',
    cert_type => 'trusted_root_ca',
  }

  # Add the client certificate (with private key) to the Personal certificates
  windows_puppet_certificates::windows_cert { 'puppet_client_windows_certificate':
    cert_path => "${::settings::confdir}/ssl/certs/${::clientcert}.pem",
    key_path  => "${::settings::confdir}/ssl/private_keys/${::clientcert}.pem",
    cert_type => 'personal',
  }
}
