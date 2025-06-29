<#
.SYNOPSIS
    Populates DNS CSVs and project scaffolding for Terraform Route53 automation.
.DESCRIPTION
    Creates all required DNS CSV files and project files for a Route53 Terraform setup, with robust logging and error handling.
.PARAMETER BasePath
    The root directory for the project. Defaults to 'C:\\AWSRepo\\LetsEncryptUpdates'.
.EXAMPLE
    .\populate_dns_csvs.ps1 -BasePath 'D:\\MyProject'
.NOTES
    Idempotent, safe to re-run. Logs actions to both file and console.
#>
[CmdletBinding()]
param(
    [string]$BasePath = "C:\AWSRepo\LetsEncryptUpdates"
)

$ErrorActionPreference = 'Stop'
$recordPath = Join-Path $BasePath "records"

$logPath = Join-Path $BasePath 'populate_dns_csvs.log'

function Write-Log {
    <#
    .SYNOPSIS
        Logs a message to file and console with timestamp.
    .PARAMETER Message
        The message to log.
    #>
    param(
        [string]$Message
    )
    $timestamped = "[$(Get-Date -Format o)] $Message"
    try {
        $timestamped | Out-File -FilePath $logPath -Append -ErrorAction Stop
    } catch {
        Write-Warning "Failed to write to log file: $_"
    }
    if ($Host.UI.RawUI -and $Host.Name -ne 'ServerRemoteHost') {
        Write-Host $timestamped
    }
}

Write-Log "Script started."

# Create base directory
try {
    if (!(Test-Path -Path $BasePath)) {
        New-Item -Path $BasePath -ItemType Directory | Out-Null
        Write-Log "Created base directory: $BasePath"
    }
} catch {
    Write-Log "ERROR: Failed to create base directory: $_"
    throw
}

# Create records directory
try {
    if (!(Test-Path -Path $recordPath)) {
        New-Item -Path $recordPath -ItemType Directory | Out-Null
        Write-Log "Created records directory: $recordPath"
    }
} catch {
    Write-Log "ERROR: Failed to create records directory: $_"
    throw
}

# DNS record data as arrays of objects and immediate CSV export
$aRecords = @(
    [PSCustomObject]@{
        enabled = 'yes'
        record_name = 'app.aws.rjglabs.com'
        ip_addr = '192.0.2.1'
        zone_id = 'Z046442633YP8JTC6AZR3'
        ttl = 300
        comment = 'App server'
    }
)
$aRecords | Export-Csv -Path (Join-Path $BasePath 'records\a_records.csv') -NoTypeInformation

$aaaaRecords = @(
    [PSCustomObject]@{
        enabled = 'yes'
        record_name = 'ipv6.aws.rjglabs.com'
        ipv6_addr = '2001:0db8:85a3:0000:0000:8a2e:0370:7334'
        zone_id = 'Z046442633YP8JTC6AZR3'
        ttl = 300
        comment = 'IPv6 app server'
    }
)
$aaaaRecords | Export-Csv -Path (Join-Path $BasePath 'records\aaaa_records.csv') -NoTypeInformation

$cnameRecords = @(
    [PSCustomObject]@{
        enabled = 'yes'
        record_name = 'login.aws.rjglabs.com'
        target_name = 'login.external.com'
        zone_id = 'Z046442633YP8JTC6AZR3'
        ttl = 300
        comment = 'Login alias'
    }
)
$cnameRecords | Export-Csv -Path (Join-Path $BasePath 'records\cname_records.csv') -NoTypeInformation

$aAliasRecords = @(
    [PSCustomObject]@{
        enabled = 'yes'
        record_name = 'root.aws.rjglabs.com'
        alias_target_dns = 'dualstack.elb.amazonaws.com'
        alias_hosted_zone_id = 'Z35SXDOTRQ7X7K'
        zone_id = 'Z046442633YP8JTC6AZR3'
        ttl = 60
        comment = 'ELB alias'
    }
)
$aAliasRecords | Export-Csv -Path (Join-Path $BasePath 'records\a_alias_records.csv') -NoTypeInformation

$txtRecords = @(
    [PSCustomObject]@{
        enabled = 'yes'
        record_name = 'spf.aws.rjglabs.com'
        txt_value = 'v=spf1 include:mailgun.org ~all'
        zone_id = 'Z046442633YP8JTC6AZR3'
        ttl = 300
        comment = 'SPF record'
    }
)
$txtRecords | Export-Csv -Path (Join-Path $BasePath 'records\txt_records.csv') -NoTypeInformation

$mxRecords = @(
    [PSCustomObject]@{
        enabled = 'yes'
        record_name = 'aws.rjglabs.com'
        priority = 10
        mail_server = 'mail1.aws.rjglabs.com'
        zone_id = 'Z046442633YP8JTC6AZR3'
        ttl = 300
        comment = 'Primary mail server'
    }
)
$mxRecords | Export-Csv -Path (Join-Path $BasePath 'records\mx_records.csv') -NoTypeInformation

$nsRecords = @(
    [PSCustomObject]@{
        enabled = 'yes'
        record_name = 'aws.rjglabs.com'
        ns_server = 'ns-2048.awsdns-64.com'
        zone_id = 'Z046442633YP8JTC6AZR3'
        ttl = 172800
        comment = 'Delegation to AWS NS'
    }
)
$nsRecords | Export-Csv -Path (Join-Path $BasePath 'records\ns_records.csv') -NoTypeInformation

$srvRecords = @(
    [PSCustomObject]@{
        enabled = 'yes'
        record_name = '_sip._tcp.aws.rjglabs.com'
        priority = 10
        weight = 5
        port = 5060
        target = 'sipserver.aws.rjglabs.com'
        zone_id = 'Z046442633YP8JTC6AZR3'
        ttl = 300
        comment = 'VoIP service'
    }
)
$srvRecords | Export-Csv -Path (Join-Path $BasePath 'records\srv_records.csv') -NoTypeInformation

$ptrRecords = @(
    [PSCustomObject]@{
        enabled = 'yes'
        record_name = '1.2.0.192.in-addr.arpa'
        ptr_target = 'app.aws.rjglabs.com'
        zone_id = 'Z046442633YP8JTC6AZR3'
        ttl = 300
        comment = 'Reverse DNS'
    }
)
$ptrRecords | Export-Csv -Path (Join-Path $BasePath 'records\ptr_records.csv') -NoTypeInformation

$caaRecords = @(
    [PSCustomObject]@{
        enabled = 'yes'
        record_name = 'aws.rjglabs.com'
        flags = 0
        tag = 'issue'
        value = 'letsencrypt.org'
        zone_id = 'Z046442633YP8JTC6AZR3'
        ttl = 300
        comment = 'Allow LetsEncrypt'
    }
)
$caaRecords | Export-Csv -Path (Join-Path $BasePath 'records\caa_records.csv') -NoTypeInformation

$spfRecords = @(
    [PSCustomObject]@{
        enabled = 'yes'
        record_name = 'spf.aws.rjglabs.com'
        spf_value = 'v=spf1 include:spf.protection.outlook.com -all'
        zone_id = 'Z046442633YP8JTC6AZR3'
        ttl = 300
        comment = 'SPF for Office 365'
    }
)
$spfRecords | Export-Csv -Path (Join-Path $BasePath 'records\spf_records.csv') -NoTypeInformation

$dmarcRecords = @(
    [PSCustomObject]@{
        enabled = 'yes'
        record_name = '_dmarc.aws.rjglabs.com'
        txt_value = 'v=DMARC1; p=quarantine; rua=mailto:dmarc-reports@aws.rjglabs.com'
        zone_id = 'Z046442633YP8JTC6AZR3'
        ttl = 300
        comment = 'DMARC policy for AWS domain'
    }
)
$dmarcRecords | Export-Csv -Path (Join-Path $BasePath 'records\dmarc_records.csv') -NoTypeInformation

$soaRecords = @(
    [PSCustomObject]@{
        enabled = 'yes'
        record_name = 'example.com.'
        mname = 'ns1.example.com.'
        rname = 'hostmaster.example.com.'
        serial = 2025062901
        refresh = 7200
        retry = 3600
        expire = 1209600
        minimum = 3600
        zone_id = 'Z046442633YP8JTC6AZR3'
        ttl = 300
        comment = 'SOA record'
    }
)
$soaRecords | Export-Csv -Path (Join-Path $BasePath 'records\soa_records.csv') -NoTypeInformation

$naptrRecords = @(
    [PSCustomObject]@{
        enabled = 'yes'
        record_name = '_sip._udp.example.com'
        order = 100
        preference = 50
        flags = 's'
        service = 'SIP+D2U'
        regexp = '!^.*$!sip:info@example.com!.'
        replacement = '.'
        zone_id = 'Z046442633YP8JTC6AZR3'
        ttl = 300
        comment = 'NAPTR record'
    }
)
$naptrRecords | Export-Csv -Path (Join-Path $BasePath 'records\naptr_records.csv') -NoTypeInformation

$tlsaRecords = @(
    [PSCustomObject]@{
        enabled = 'yes'
        record_name = '_443._tcp.example.com'
        usage = 3
        selector = 1
        matching = 1
        zone_id = 'Z046442633YP8JTC6AZR3'
        ttl = 300
        comment = 'TLSA record'
    }
)
$tlsaRecords | Export-Csv -Path (Join-Path $BasePath 'records\tlsa_records.csv') -NoTypeInformation

$sshfpRecords = @(
    [PSCustomObject]@{
        enabled = 'yes'
        record_name = 'ssh.example.com'
        algorithm = 1
        type = 1
        fingerprint = '123456789abcdef...'
        zone_id = 'Z046442633YP8JTC6AZR3'
        ttl = 300
        comment = 'SSHFP record'
    }
)
$sshfpRecords | Export-Csv -Path (Join-Path $BasePath 'records\sshfp_records.csv') -NoTypeInformation

$uriRecords = @(
    [PSCustomObject]@{
        enabled = 'yes'
        record_name = 'sip.example.com'
        priority = 10
        weight = 1
        target = 'sip:info@example.com'
        zone_id = 'Z046442633YP8JTC6AZR3'
        ttl = 300
        comment = 'URI record'
    }
)
$uriRecords | Export-Csv -Path (Join-Path $BasePath 'records\uri_records.csv') -NoTypeInformation

$locRecords = @(
    [PSCustomObject]@{
        enabled = 'yes'
        record_name = 'loc.example.com'
        version = 0
        size = 1
        horiz_precision = 10000
        vert_precision = 10
        latitude = '37 47 0.000 N'
        longitude = '122 24 0.000 W'
        altitude = '10.00m'
        zone_id = 'Z046442633YP8JTC6AZR3'
        ttl = 300
        comment = 'LOC record'
    }
)
$locRecords | Export-Csv -Path (Join-Path $BasePath 'records\loc_records.csv') -NoTypeInformation

$certRecords = @(
    [PSCustomObject]@{
        enabled = 'yes'
        record_name = 'cert.example.com'
        flags = 0
        tag = 'PKIX'
        value = 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQ...'
        zone_id = 'Z046442633YP8JTC6AZR3'
        ttl = 300
        comment = 'CERT record'
    }
)
$certRecords | Export-Csv -Path (Join-Path $BasePath 'records\cert_records.csv') -NoTypeInformation

$svcbRecords = @(
    [PSCustomObject]@{
        enabled = 'yes'
        record_name = '_svc.example.com'
        priority = 1
        params = 'alpn=h2 port=443'
        zone_id = 'Z046442633YP8JTC6AZR3'
        ttl = 300
        comment = 'SVCB record'
    }
)
$svcbRecords | Export-Csv -Path (Join-Path $BasePath 'records\svcb_records.csv') -NoTypeInformation

$httpsRecords = @(
    [PSCustomObject]@{
        enabled = 'yes'
        record_name = '_https.example.com'
        priority = 1
        params = 'alpn=h2 port=443'
        zone_id = 'Z046442633YP8JTC6AZR3'
        ttl = 300
        comment = 'HTTPS record'
    }
)
$httpsRecords | Export-Csv -Path (Join-Path $BasePath 'records\https_records.csv') -NoTypeInformation

# Other (empty) files in project root and .github/workflows
$otherFiles = @(
    "main.tf",
    "variables.tf",
    "outputs.tf",
    ".gitignore",
    ".github\workflows\dns-update.yml"
)

# Create the rest as empty files
foreach ($file in $otherFiles) {
    $fullPath = Join-Path $BasePath $file
    $folder = Split-Path $fullPath -Parent
    try {
        if (!(Test-Path -Path $folder)) {
            New-Item -Path $folder -ItemType Directory -Force | Out-Null
            Write-Log "Created directory: $folder"
        }
        if (!(Test-Path -Path $fullPath)) {
            New-Item -Path $fullPath -ItemType File | Out-Null
            Write-Log "Created empty file: $fullPath"
        }
    } catch {
        $err = $_
        Write-Log ('ERROR: Failed to create file or directory for ' + $file + ': ' + $err)
        throw
    }
}

Write-Log "Script completed successfully."

# Ensure log file is .gitignored
$gitignorePath = Join-Path $BasePath '.gitignore'
$logRelativePath = 'populate_dns_csvs.log'
try {
    if (Test-Path $gitignorePath) {
        $gitignoreContent = Get-Content $gitignorePath -Raw
        if ($gitignoreContent -notmatch [regex]::Escape($logRelativePath)) {
            Add-Content -Path $gitignorePath -Value $logRelativePath
            Write-Log "Added $logRelativePath to .gitignore."
        }
    } else {
        Set-Content -Path $gitignorePath -Value $logRelativePath
        Write-Log "Created .gitignore and added $logRelativePath."
    }
} catch {
    Write-Log "ERROR: Failed to update .gitignore: $_"
}

Write-Log "Project structure and all DNS CSVs created at $BasePath, including all record types. Log: $logPath"
