param(
    [Parameter(Mandatory=$true)]
    [string]$CatalogUrl,
    [string]$ExpectedSha256 = ""
)

$ErrorActionPreference = "Stop"

if (-not $CatalogUrl.StartsWith("https://")) {
    throw "CatalogUrl must use HTTPS"
}

$Temp = Join-Path $env:TEMP ("zahira-catalog-" + [Guid]::NewGuid().ToString("N") + ".json")
try {
    Write-Host "[RUN ] Fetching $CatalogUrl"
    Invoke-WebRequest -UseBasicParsing -Uri $CatalogUrl -OutFile $Temp

    $Catalog = Get-Content $Temp -Raw | ConvertFrom-Json
    if (-not $Catalog.catalogVersion -or [int]$Catalog.catalogVersion -lt 1) { throw "Invalid catalogVersion" }
    if (-not $Catalog.channels -or $Catalog.channels.Count -lt 1) { throw "Empty catalog" }

    $Ids = @{}
    $Numbers = @{}
    foreach ($c in $Catalog.channels) {
        if ($Ids.ContainsKey([string]$c.id)) { throw "Duplicate id: $($c.id)" }
        if ($Numbers.ContainsKey([string]$c.number)) { throw "Duplicate number: $($c.number)" }
        if (-not ([string]$c.streamUrl).StartsWith("https://")) { throw "Non-HTTPS stream: $($c.id)" }
        if ($c.logoUrl -and -not ([string]$c.logoUrl).StartsWith("https://")) { throw "Non-HTTPS logo: $($c.id)" }
        if (@("online","offline","maintenance") -notcontains ([string]$c.status).ToLowerInvariant()) {
            throw "Invalid status: $($c.id)"
        }
        $Ids[[string]$c.id] = $true
        $Numbers[[string]$c.number] = $true
    }

    $Hash = (Get-FileHash $Temp -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($ExpectedSha256 -and $Hash -ne $ExpectedSha256.ToLowerInvariant()) {
        throw "SHA-256 mismatch. Expected $ExpectedSha256, got $Hash"
    }

    Write-Host "[PASS] Remote catalog validation"
    Write-Host "       Version : $($Catalog.catalogVersion)"
    Write-Host "       Channels: $($Catalog.channels.Count)"
    Write-Host "       SHA-256 : $Hash"
}
finally {
    Remove-Item $Temp -Force -ErrorAction SilentlyContinue
}
