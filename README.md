
# windows_puppet_certificates

#### Table of Contents

1. [Description](#description)
2. [Usage - Configuration options and additional functionality](#usage)
3. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
4. [Limitations - OS compatibility, etc.](#limitations)

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

include windows_puppet_certificates
```

## Reference

### windows_puppet_certificates

#### manage_master_cert

When set to true the module will manage the Puppet Master CA certificate into the computer Trusted Root CA certificate store.  By default this is set to true

#### manage_client_cert

When set to true the module will manage the Puppet Client certificate, and private key, into the computer Personal certificate store.  By default this is set to false, as importing a private key should be an explicit decision.

The public key is marked as Not Exportable in the certificate store.

## Limitations

Currently the module only supports `ensure => present`, that is the module can only add the certificates, and ensure they exist.
