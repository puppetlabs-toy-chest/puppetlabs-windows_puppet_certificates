# @param cert_path
#   The path to the certificate file
# @param cert_type
#   The type of certificate being acted upon.
#   Valid values are `trusted_root_ca` and `personal`
# @param ensure
#   Currently only `present` is supported
#   Default: present
# @param key_path
#   The path to the key file
define windows_puppet_certificates::windows_certificate (
  Stdlib::Windowspath $cert_path,
  Enum['trusted_root_ca', 'personal'] $cert_type,
  Enum['present'] $ensure = 'present',
  Optional[Stdlib::Windowspath] $key_path,
) {
  exec { $name:
    command  => template('windows_puppet_certificates/puppet_certs_common.ps1', 'windows_puppet_certificates/puppet_certs_command.ps1'),
    onlyif   => template('windows_puppet_certificates/puppet_certs_common.ps1', 'windows_puppet_certificates/puppet_certs_onlyif.ps1'),
    provider => powershell,
  }
}
