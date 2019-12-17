# Outputs each Certificate in a PEM file
Function Out-Certificate {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [string] $PEMText
  )

  Process {
    # Split each certificate in the PEM file
    $PEMText -Split '(?:-----BEGIN CERTIFICATE-----|-----END CERTIFICATE-----)' | Where-Object { $_.Length -gt 10 }
  }
}
