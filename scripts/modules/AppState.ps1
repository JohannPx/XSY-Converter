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
