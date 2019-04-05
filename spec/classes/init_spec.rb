require 'spec_helper'

describe 'windows_puppet_certificates' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      context 'with defaults' do
        let(:facts) do
          facts.merge(
            puppet_cert_paths: {
              confdir: 'C:/ProgramData/PuppetLabs/puppet/etc',
            },
          )
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'with manage_client_cert => true' do
        let(:facts) do
          facts.merge(
            puppet_cert_paths: {
              confdir: 'C:/ProgramData/PuppetLabs/puppet/etc',
            },
          )
        end

        let(:params) do
          { 'manage_client_cert' => true }
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'with confdir_path => "c:/programdata/puppetlabs/puppet/etc"' do
        let(:params) do
          { 'confdir_path' => 'c:/programdata/puppetlabs/puppet/etc' }
        end

        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
