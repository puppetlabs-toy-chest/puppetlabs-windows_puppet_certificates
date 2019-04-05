require 'puppet'

Facter.add('puppet_cert_paths') do
  setcode do
    confdir = Puppet.settings['confdir']
    ssldir = "#{confdir}/ssl"
    cert_dir = "#{ssldir}/certs"
    ca_path = "#{cert_dir}/ca.pem"
    client_cert_path = "#{cert_dir}/#{Facter.value(:clientcert)}.pem"
    client_key_path = "#{ssldir}/private_keys/#{Facter.value(:clientcert)}.pem"

    {
      'confdir' => confdir,
      'ssldir' => ssldir,
      'cert_dir' => cert_dir,
      'ca_path' => ca_path,
      'client_cert_path' => client_cert_path,
      'client_key_path' => client_key_path,
    }
  end
end
