![](https://img.shields.io/puppetforge/pdk-version/puppetlabs/windows_puppet_certificates.svg?style=popout)
![](https://img.shields.io/puppetforge/v/puppetlabs/windows_puppet_certificates.svg?style=popout)
![](https://img.shields.io/puppetforge/dt/puppetlabs/windows_puppet_certificates.svg?style=popout)
[![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-windows_puppet_certificates.svg?branch=master)](https://travis-ci.org/puppetlabs/puppetlabs-windows_puppet_certificates)

# windows_puppet_certificates

#### Table of Contents

1. [Description](#description)
2. [Usage](#usage)
3. [Reference](#reference)
4. [Changelog](#changelog)
5. [Limitations](#limitations)
6. [Contributing](#contributing)

## Description

This module takes the Puppet Master CA certificate and Puppet Agent client certificate and imports them into the Windows Certificate Store.

This is useful to allow Windows applications to consume these certificates in a Windows way, for example;

* For client certificate based authentication in EAP in 802.1x

* For automatically trusting the PE Console in web browsers

* For encrypting secrets for the client to consume, for example Hiera eYaml

* For encrypting secrets for the server to consume, for example encrypting Bitlocker keys

## Usage

By default the module will only import the Puppet Master CA cert

``` puppet
include windows_puppet_certificates
```

If you wish to import the master and client certificate you use the following manifest

``` puppet
class { 'windows_puppet_certificates':
  manage_master_cert => true,
  manage_client_cert => true,
}
```

## Reference

This module is documented via
`pdk bundle exec puppet strings generate --format markdown`.
Please see [REFERENCE.md](REFERENCE.md) for more info.

Additionally, a custom fact named `puppet_cert_paths` is included in this
module. A sample of what it adds to the output of `puppet facts` on
Windows is below:

```json
"puppet_cert_paths": {
    "confdir": "C:/ProgramData/PuppetLabs/puppet/etc",
    "ssldir": "C:/ProgramData/PuppetLabs/puppet/etc/ssl",
    "cert_dir": "C:/ProgramData/PuppetLabs/puppet/etc/ssl/certs",
    "ca_path": "C:/ProgramData/PuppetLabs/puppet/etc/ssl/certs/ca.pem",
    "client_cert_path": "C:/ProgramData/PuppetLabs/puppet/etc/ssl/certs/test.example.com.pem",
    "client_key_path": "C:/ProgramData/PuppetLabs/puppet/etc/ssl/private_keys/test.example.com.pem"
},
```

## Changelog

[CHANGELOG.md](CHANGELOG.md) is generated prior to each release via
`pdk bundle exec rake changelog`. This proecss relies on labels that are applied
to each pull request.

## Limitations

Currently the module only supports `ensure => present`, that is the module can only add the certificates, and ensure they exist.

## Contributing

Pull requests are welcome!

