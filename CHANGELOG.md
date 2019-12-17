# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2019-12-19

### Changed

- Add handling of multiple certs in a single PEM ([Pull Request](https://github.com/puppetlabs/puppetlabs-windows_puppet_certificates/pull/8))

## [0.1.0] - 2019-09-13

This is the initial release of the puppetlabs/windows_puppet_certificates module.

This module takes the Puppet Master CA certificate and Puppet Agent client certificate and imports them into the Windows Certificate Store.

This is useful to allow Windows applications to consume these certificates in a Windows way, for example;

  * For client certificate based authentication in EAP in 802.1x
  * For automatically trusting the PE Console in web browsers
  * For encrypting secrets for the client to consume, for example Hiera eYaml
  * For encrypting secrets for the server to consume, for example encrypting Bitlocker keys
  * For example, you could use it to manage the certificates for SSL winrm (https://forge.puppet.com/nekototori/winrmssl)

**Features**

**Bugfixes**

**Known Issues**
