# AppState.ps1 - Central state management
# Single source of truth for all application data

$Script:AppState = @{
    # Input
    InputFilePath      = $null
    OutputFolder       = $null

    # Parsed data
    ProjectName        = ""
    ParsedVariables    = @()
    DDTDefinitions     = @{}
    ParseErrors        = @()
    VariableCount      = 0
    ExcludedEbool      = 0
    ExcludedByte       = 0

    # Export formats (checkboxes)
    ExportCsv          = $true
    ExportEwon         = $false
    ExportPcVue        = $false

    # PLC config
    PlcName            = ""
    PlcIpAddress       = "192.168.1.100"
    PlcUnitId          = 1

    # Ewon config
    EwonRepere         = ""
    EwonTopic          = "A"
    EwonPageId         = 1

    # Runtime
    IsExporting        = $false
    LastExportResult   = $null

    # Language
    Language           = "FR"
}

function Get-AppState { return $Script:AppState }

function Set-AppStateValue {
    param([string]$Key, $Value)
    $Script:AppState[$Key] = $Value
}

# Version injectee au build par la CI (sed remplace @APP_VERSION@ par la version resolue).
# Reste le placeholder litteral en mode dev, ce qui declenche le fallback version.json / manifest.json.
$Script:InjectedAppVersion = "@APP_VERSION@"

function Get-AppVersion {
    <#
    .SYNOPSIS
        Retourne la version de l'application (bundle/.exe, version.json du wrapper, ou manifest.json en dev).
    #>

    # 1. Version injectee au build (bundle de production / .exe)
    if ($Script:InjectedAppVersion -and $Script:InjectedAppVersion -notmatch '^@.*@$') {
        return $Script:InjectedAppVersion
    }

    # 2. version.json maintenu par le wrapper C# apres installation/mise a jour
    $versionFile = Join-Path $env:LOCALAPPDATA "XsyConverter\version.json"
    if (Test-Path $versionFile) {
        try {
            $v = (Get-Content $versionFile -Raw | ConvertFrom-Json).version
            if ($v -and $v -ne "0.0.0") { return $v }
        } catch {}
    }

    # 3. Dev : lecture du manifest.json (le script vit dans scripts/modules/)
    $candidates = @(
        (Join-Path $PSScriptRoot "..\..\manifest.json"),
        (Join-Path $PSScriptRoot "..\manifest.json"),
        (Join-Path $PSScriptRoot "manifest.json")
    )
    foreach ($p in $candidates) {
        if (Test-Path $p) {
            try {
                $v = (Get-Content $p -Raw | ConvertFrom-Json).version
                if ($v) { return $v }
            } catch {}
        }
    }

    return "dev"
}
