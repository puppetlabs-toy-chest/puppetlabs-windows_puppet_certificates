$cert_path = '<%= @cert_path %>'
$key_path = '<%= @key_path %>'
$cert_type = '<%= @cert_type %>'

$VerbosePreference = 'Continue'
$ErrorActionPreference = 'Stop'

Write-Verbose "Importing C# code..."

# From https://stackoverflow.com/questions/7400500/how-to-get-private-key-from-pem-file
# Under CC2.5 license - andrew.fox
# Changes made to suit this script
Add-Type -TypeDefinition @"
using System;
using System.IO;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.Security.Principal;
using System.Security.AccessControl;

namespace PuppetCerts
{
    public static class PEMToX509
    {
        const string KEY_HEADER = "-----BEGIN RSA PRIVATE KEY-----";
        const string KEY_FOOTER = "-----END RSA PRIVATE KEY-----";

        public static X509Certificate2 Convert(string pem)
        {
            try
            {
                byte[] pemCertWithPrivateKey = System.Text.Encoding.ASCII.GetBytes(pem);

                RSACryptoServiceProvider rsaPK = GetRSA(pem);

                X509Certificate2 cert = new X509Certificate2();
                cert.Import(pemCertWithPrivateKey, "", X509KeyStorageFlags.MachineKeySet | X509KeyStorageFlags.PersistKeySet);

                if (rsaPK != null)
                {
                    cert.PrivateKey = rsaPK;
                }

                return cert;
            }
            catch
            {
                return null;
            }
        }

        private static RSACryptoServiceProvider GetRSA(string pem)
        {
            RSACryptoServiceProvider rsa = null;

            if (IsPrivateKeyAvailable(pem))
            {
                RSAParameters privateKey = DecodeRSAPrivateKey(pem);

                SecurityIdentifier everyoneSI = new SecurityIdentifier(WellKnownSidType.WorldSid, null);
                CryptoKeyAccessRule rule = new CryptoKeyAccessRule(everyoneSI, CryptoKeyRights.FullControl, AccessControlType.Allow);

                CspParameters cspParameters = new CspParameters();
                cspParameters.KeyContainerName = "MY_C_NAME";
                cspParameters.ProviderName = "Microsoft Strong Cryptographic Provider";
                cspParameters.ProviderType = 1;
                cspParameters.Flags = CspProviderFlags.UseNonExportableKey | CspProviderFlags.UseMachineKeyStore;

                cspParameters.CryptoKeySecurity = new CryptoKeySecurity();
                cspParameters.CryptoKeySecurity.SetAccessRule(rule);

                rsa = new RSACryptoServiceProvider(cspParameters);
                rsa.PersistKeyInCsp = true;
                rsa.ImportParameters(privateKey);
            }

            return rsa;
        }

        private static bool IsPrivateKeyAvailable(string privateKeyInPEM)
        {
            return (privateKeyInPEM != null && privateKeyInPEM.Contains(KEY_HEADER)
                && privateKeyInPEM.Contains(KEY_FOOTER));
        }

        private static RSAParameters DecodeRSAPrivateKey(string privateKeyInPEM)
        {
            if (IsPrivateKeyAvailable(privateKeyInPEM) == false)
                throw new ArgumentException("bad format");

            string keyFormatted = privateKeyInPEM;

            int cutIndex = keyFormatted.IndexOf(KEY_HEADER);
            keyFormatted = keyFormatted.Substring(cutIndex, keyFormatted.Length - cutIndex);
            cutIndex = keyFormatted.IndexOf(KEY_FOOTER);
            keyFormatted = keyFormatted.Substring(0, cutIndex + KEY_FOOTER.Length);
            keyFormatted = keyFormatted.Replace(KEY_HEADER, "");
            keyFormatted = keyFormatted.Replace(KEY_FOOTER, "");
            keyFormatted = keyFormatted.Replace("\r", "");
            keyFormatted = keyFormatted.Replace("\n", "");
            keyFormatted = keyFormatted.Trim();

            byte[] privateKeyInDER = System.Convert.FromBase64String(keyFormatted);

            byte[] paramModulus;
            byte[] paramDP;
            byte[] paramDQ;
            byte[] paramIQ;
            byte[] paramE;
            byte[] paramD;
            byte[] paramP;
            byte[] paramQ;

            MemoryStream memoryStream = new MemoryStream(privateKeyInDER);
            BinaryReader binaryReader = new BinaryReader(memoryStream);

            ushort twobytes = 0;
            int elements = 0;
            byte bt = 0;

            try
            {
                twobytes = binaryReader.ReadUInt16();
                if (twobytes == 0x8130) 
                    binaryReader.ReadByte();
                else if (twobytes == 0x8230) 
                    binaryReader.ReadInt16();
                else 
                    throw new CryptographicException("Wrong data");

                twobytes = binaryReader.ReadUInt16();
                if (twobytes != 0x0102) 
                    throw new CryptographicException("Wrong data");

                bt = binaryReader.ReadByte();
                if (bt != 0x00) 
                    throw new CryptographicException("Wrong data");

                elements = GetIntegerSize(binaryReader);
                paramModulus = binaryReader.ReadBytes(elements);

                elements = GetIntegerSize(binaryReader);
                paramE = binaryReader.ReadBytes(elements);

                elements = GetIntegerSize(binaryReader);
                paramD = binaryReader.ReadBytes(elements);

                elements = GetIntegerSize(binaryReader);
                paramP = binaryReader.ReadBytes(elements);

                elements = GetIntegerSize(binaryReader);
                paramQ = binaryReader.ReadBytes(elements);

                elements = GetIntegerSize(binaryReader);
                paramDP = binaryReader.ReadBytes(elements);

                elements = GetIntegerSize(binaryReader);
                paramDQ = binaryReader.ReadBytes(elements);

                elements = GetIntegerSize(binaryReader);
                paramIQ = binaryReader.ReadBytes(elements);

                EnsureLength(ref paramD, 256);
                EnsureLength(ref paramDP, 128);
                EnsureLength(ref paramDQ, 128);
                EnsureLength(ref paramE, 3);
                EnsureLength(ref paramIQ, 128);
                EnsureLength(ref paramModulus, 256);
                EnsureLength(ref paramP, 128);
                EnsureLength(ref paramQ, 128);

                RSAParameters rsaParameters = new RSAParameters();
                rsaParameters.Modulus = paramModulus;
                rsaParameters.Exponent = paramE;
                rsaParameters.D = paramD;
                rsaParameters.P = paramP;
                rsaParameters.Q = paramQ;
                rsaParameters.DP = paramDP;
                rsaParameters.DQ = paramDQ;
                rsaParameters.InverseQ = paramIQ;

                return rsaParameters;
            }
            finally
            {
                binaryReader.Close();
            }
        }

        private static int GetIntegerSize(BinaryReader binary)
        {
            byte bt = 0;
            byte lowbyte = 0x00;
            byte highbyte = 0x00;
            int count = 0;

            bt = binary.ReadByte();

            if (bt != 0x02) 
                return 0;

            bt = binary.ReadByte();

            if (bt == 0x81) 
                count = binary.ReadByte();
            else if (bt == 0x82)
            {
                highbyte = binary.ReadByte();
                lowbyte = binary.ReadByte();
                byte[] modint = { lowbyte, highbyte, 0x00, 0x00 };
                count = BitConverter.ToInt32(modint, 0);
            }
            else 
                count = bt;

            while (binary.ReadByte() == 0x00)
                count -= 1;

            binary.BaseStream.Seek(-1, SeekOrigin.Current);

            return count;
        }

        private static void EnsureLength(ref byte[] data, int desiredLength)
        {
            if (data == null || data.Length >= desiredLength)
                return;

            int zeros = desiredLength - data.Length;

            byte[] newData = new byte[desiredLength];
            Array.Copy(data, 0, newData, zeros, data.Length);

            data = newData;
        }
    }
}
"@

if (-not (Test-Path -Path $cert_path)) {
  Write-Verbose "Certificate $cert_path does not exist"
  exit 1
}

Write-Verbose "Loading certificate(s) from disk..."
$raw_content = [System.IO.File]::ReadAllText($cert_path)
$certs = $raw_content -Split '(?<!^)(?=-----BEGIN CERTIFICATE-----)' 

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

$certs | ForEach {
    if ($key_path -ne '') {
      $pfx_content += [System.IO.File]::ReadAllText($key_path)
    }
    $pfx = [PuppetCerts.PEMToX509]::Convert($_)

    $cert_thumbprint = $pfx.Thumbprint.ToUpper()
    Write-Verbose "Certificate thumbprint is $cert_thumbprint"

    Write-Verbose "Checking if certificate exists..."
    $found = $false
    $cert_store.Certificates | % {
      $found = $found -or ($_.Thumbprint.ToUpper() -eq $cert_thumbprint)
    }

    if ($found) {
      Write-Verbose "Certificate already exists"
      Continue
    }

    Write-Verbose "Adding certificate to the store..."
    $cert_store.Add($pfx) | Out-Null
    $cert_store.Close | Out-Null

    Write-Verbose "Certificate added"
}
