define windows_puppet_certificates::windows_certificate (
  # Currently only 'present' is supported
  Enum['present'] $ensure = 'present',
  Stdlib::Windowspath $cert_path,
  Optional[Stdlib::Windowspath] $key_path,
  Enum['trusted_root_ca', 'personal'] $cert_type,
) {
  exec { $name:
    command  => template('windows_puppet_certificates/puppet_certs_command.ps1'),
    onlyif   => template('windows_puppet_certificates/puppet_certs_onlyif.ps1'),
    provider => powershell,
  }
}
