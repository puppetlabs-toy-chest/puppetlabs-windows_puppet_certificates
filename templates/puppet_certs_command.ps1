$cert_path = '<%= @cert_path %>'
$key_path = '<%= @key_path %>'
$cert_type = '<%= @cert_type %>'

$VerbosePreference = 'Continue'
$ErrorActionPreference = 'Stop'

Import-CSharpCode

if (-not (Test-Path -Path $cert_path)) {
  Write-Verbose "Certificate $cert_path does not exist"
  exit 1
}

Write-Verbose "Loading certificate(s) from disk..."
$raw_content = [System.IO.File]::ReadAllText($cert_path)

Write-Verbose "Opening certificate store $cert_type ..."
$storename = $null
switch ($cert_type)
{
  'trusted_root_ca' { $storename = [System.Security.Cryptography.X509Certificates.StoreName]::Root; break }
  'personal'        { $storename = [System.Security.Cryptography.X509Certificates.StoreName]::My; break }
  default           { Throw "Unknown certificate type $cert_type" }
}
$cert_store = New-Object -Type System.Security.Cryptography.X509Certificates.X509Store($storename, [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine)
$cert_store.Open('ReadWrite')

$pfx_key_content = ''
if ($key_path -ne '') { $pfx_key_content = [System.IO.File]::ReadAllText($key_path) }

$raw_content | Out-Certificate | ForEach-Object -Process {
  # Need to convert the Base64 Certificate back into a PEM format so that we can
  # add the private key content if required.
  $interim_pem = "-----BEGIN CERTIFICATE-----`n${_}`n-----END CERTIFICATE-----`n${pfx_key_content}"
  $pfx = [PuppetCerts.PEMToX509]::Convert($interim_pem)
  if ($null -eq $pfx) { Throw "Interim PFX content is not valid" }

  $cert_thumbprint = $pfx.Thumbprint.ToUpper()
  Write-Verbose "Certificate thumbprint is $cert_thumbprint"

  Write-Verbose "Checking if certificate exists..."
  $found = $cert_store.Certificates | Where-Object { $_.Thumbprint.ToUpper() -eq $cert_thumbprint } | Select-Object -First 1

  if ($null -ne $found) {
    Write-Verbose "Certificate already exists"
  } else {
    Write-Verbose "Adding certificate to the store..."
    $cert_store.Add($pfx) | Out-Null

    Write-Verbose "Certificate added"
  }

}

$cert_store.Close | Out-Null
exit 0
