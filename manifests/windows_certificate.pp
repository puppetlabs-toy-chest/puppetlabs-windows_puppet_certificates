define windows_puppet_certificates::windows_cert (
  $cert_path,
  $key_path,
  $cert_type,
) {
  exec { $name:
    command  => template('profile/windows/puppet_certs_command.ps1'),
    onlyif   => template('profile/windows/puppet_certs_onlyif.ps1'),
    provider => powershell,
  }
}
