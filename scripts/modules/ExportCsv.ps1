# ExportCsv.ps1 - Export as CSV exchange table

function Export-CsvExchangeTable {
    param(
        [array]$Variables,
        [string]$OutputFolder,
        [string]$ProjectName,
        [hashtable]$PlcConfig
    )

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $safeName = $ProjectName -replace '[\\/:*?"<>|]', '_'
    $fileName = "${safeName}_ExchangeTable_${timestamp}.csv"
    $filePath = Join-Path $OutputFolder $fileName

    $encoding = New-Object System.Text.UTF8Encoding($true)  # UTF-8 with BOM
    $writer = New-Object System.IO.StreamWriter($filePath, $false, $encoding)

    try {
        # PLC header rows
        $plcName = if ($PlcConfig -and $PlcConfig.Name) { $PlcConfig.Name } else { "" }
        $plcIp = if ($PlcConfig -and $PlcConfig.IpAddress) { $PlcConfig.IpAddress } else { "" }
        $plcUnitId = if ($PlcConfig -and $PlcConfig.UnitId) { $PlcConfig.UnitId } else { 1 }

        $writer.WriteLine("$(T 'ColNomAutomate');$plcName")
        $writer.WriteLine("$(T 'ColAdresseIp');$plcIp")
        $writer.WriteLine("$(T 'ColUnitId');$plcUnitId")

        # Column headers
        $writer.WriteLine("$(T 'ColTag');$(T 'ColRegistre');$(T 'ColType');$(T 'ColDescription');$(T 'ColUnite');$(T 'ColRepere');$(T 'ColCoef')")

        # Sort by register address
        $sorted = $Variables | Sort-Object { $_.Register }, { if ($_.Bit) { $_.Bit } else { -1 } }

        foreach ($v in $sorted) {
            $tag = ($v.Name -replace '"', '""')
            if ($tag -match '[;"]') { $tag = "`"$tag`"" }

            $desc = ($v.Description -replace '"', '""')
            if ($desc -match '[;"]') { $desc = "`"$desc`"" }

            $register = $v.Register
            if ($null -ne $v.Bit) {
                $register = "$($v.Register).$($v.Bit)"
            }

            # Unite, Repere, Coef are empty (not available in XSY)
            $writer.WriteLine("$tag;$register;$($v.Type);$desc;;;")
        }
    } finally {
        $writer.Flush()
        $writer.Close()
    }

    return $filePath
}
