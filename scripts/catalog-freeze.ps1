param(
    [string]$CatalogPath = ".\docs\catalog.json",
    [string]$ManifestPath = ".\freeze\FREEZE_MANIFEST.generated.json"
)

$ErrorActionPreference = "Stop"

$Full = (Resolve-Path $CatalogPath).Path
$Catalog = Get-Content $Full -Raw | ConvertFrom-Json

if (-not $Catalog.catalogVersion -or [int]$Catalog.catalogVersion -lt 1) {
    throw "catalogVersion must be >= 1"
}
if ([string]::IsNullOrWhiteSpace([string]$Catalog.generatedAt)) {
    throw "generatedAt is required"
}
try { [DateTimeOffset]::Parse([string]$Catalog.generatedAt) | Out-Null } catch {
    throw "generatedAt must be an ISO/RFC3339 timestamp"
}
if (-not $Catalog.channels -or $Catalog.channels.Count -lt 1) {
    throw "channels must contain at least one entry"
}

$Ids = @{}
$Numbers = @{}
$AllowedStatus = @("online","offline","maintenance")

foreach ($c in $Catalog.channels) {
    $Id = [string]$c.id
    $Num = [int]$c.number
    if ([string]::IsNullOrWhiteSpace($Id)) { throw "blank id" }
    if ($Id -notmatch '^[a-z0-9][a-z0-9-]{1,63}$') { throw "invalid id: $Id" }
    if ($Num -le 0) { throw "number must be > 0: $Id" }
    if ($Ids.ContainsKey($Id)) { throw "duplicate id: $Id" }
    if ($Numbers.ContainsKey([string]$Num)) { throw "duplicate number: $Num" }
    if ([string]::IsNullOrWhiteSpace([string]$c.name)) { throw "blank name: $Id" }
    if ([string]::IsNullOrWhiteSpace([string]$c.category)) { throw "blank category: $Id" }
    if (-not ([string]$c.streamUrl).StartsWith("https://")) { throw "non-HTTPS streamUrl: $Id" }
    if ($c.logoUrl -and -not ([string]$c.logoUrl).StartsWith("https://")) { throw "non-HTTPS logoUrl: $Id" }
    if ($AllowedStatus -notcontains ([string]$c.status).ToLowerInvariant()) { throw "invalid status: $Id" }
    $Ids[$Id] = $true
    $Numbers[[string]$Num] = $true
}

$Hash = (Get-FileHash -Path $Full -Algorithm SHA256).Hash.ToLowerInvariant()
$ShaFile = Join-Path (Split-Path $Full -Parent) "catalog.sha256"
"$Hash  catalog.json" | Set-Content -Path $ShaFile -Encoding ASCII

$Manifest = [ordered]@{
    freezeId = "ZTS-0.2B-CATALOG-REV-$($Catalog.catalogVersion)"
    frozenAt = (Get-Date).ToString("o")
    catalogFile = "docs/catalog.json"
    catalogVersion = [int]$Catalog.catalogVersion
    channelCount = $Catalog.channels.Count
    sha256 = $Hash
    contractStatus = "FROZEN"
}
$Manifest | ConvertTo-Json -Depth 10 | Set-Content -Path $ManifestPath -Encoding UTF8

Write-Host "[PASS] ZTS catalog freeze"
Write-Host "       Version : $($Catalog.catalogVersion)"
Write-Host "       Channels: $($Catalog.channels.Count)"
Write-Host "       SHA-256 : $Hash"
Write-Host "       Manifest: $ManifestPath"
