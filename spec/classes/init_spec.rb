require 'spec_helper'

describe 'windows_puppet_certificates' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          puppet_sslpaths: {
            'privatedir' => {
              'path' => 'C:/ProgramData/PuppetLabs/puppet/etc/ssl/private',
              'path_exists' => true,
            },
            'privatekeydir' => {
              'path' => 'C:/ProgramData/PuppetLabs/puppet/etc/ssl/private_keys',
              'path_exists' => true,
            },
            'publickeydir' => {
              'path' => 'C:/ProgramData/PuppetLabs/puppet/etc/ssl/public_keys',
              'path_exists' => true,
            },
            'certdir' => {
              'path' => 'C:/ProgramData/PuppetLabs/puppet/etc/ssl/certs',
              'path_exists' => true,
            },
            'requestdir' => {
              'path' => 'C:/ProgramData/PuppetLabs/puppet/etc/ssl/certificate_requests',
              'path_exists' => true,
            },
            'hostcrl' => {
              'path' => 'C:/ProgramData/PuppetLabs/puppet/etc/ssl/crl.pem',
              'path_exists' => true,
            },
          },
        )
      end

      context 'with defaults' do
        it { is_expected.to compile.with_all_deps }
      end

      context 'with manage_client_cert => true' do
        let(:params) do
          { 'manage_client_cert' => true }
        end

        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
