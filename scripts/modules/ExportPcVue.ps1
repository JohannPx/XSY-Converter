# ExportPcVue.ps1 - Export as PcVue Architect CSV (multi-file, grouped)

function Export-PcVueArchitect {
    param(
        [array]$Variables,
        [string]$OutputFolder,
        [string]$ProjectName
    )

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $safeName = $ProjectName -replace '[\\/:*?"<>|]', '_'
    $pcvueFolder = Join-Path $OutputFolder "PcVue_${safeName}_${timestamp}"
    New-Item -ItemType Directory -Path $pcvueFolder -Force | Out-Null

    # Group variables by top-level name (before first ".")
    $groups = Group-VariablesByEquipment -Variables $Variables

    $files = @()

    foreach ($groupName in ($groups.Keys | Sort-Object)) {
        $groupVars = $groups[$groupName]
        $safeGroup = $groupName -replace '[\\/:*?"<>|]', '_'
        $csvFile = Join-Path $pcvueFolder "${safeGroup}.csv"

        $encoding = New-Object System.Text.UTF8Encoding($true)  # UTF-8 with BOM
        $writer = New-Object System.IO.StreamWriter($csvFile, $false, $encoding)

        try {
            # Header
            $writer.WriteLine("$(T 'ColNom');$(T 'ColAdresseMW');$(T 'ColAdresseX');$(T 'ColType');$(T 'ColDescription');$(T 'ColDecalage');$(T 'ColWBIT');$(T 'ColTrame')")

            # Find base register for this group (trame reference)
            $baseRegister = [int]::MaxValue
            foreach ($gv in $groupVars) {
                if ($gv.Register -lt $baseRegister) { $baseRegister = $gv.Register }
            }
            $trame = "MW${baseRegister}"

            # Sort by register
            $sorted = $groupVars | Sort-Object { $_.Register }, { if ($_.Bit) { $_.Bit } else { -1 } }

            foreach ($v in $sorted) {
                $nom = ($v.Name -replace '"', '""')
                if ($nom -match '[;"]') { $nom = "`"$nom`"" }

                $desc = ($v.Description -replace '"', '""')
                if ($desc -match '[;"]') { $desc = "`"$desc`"" }

                $adresseMW = $v.Register

                # BOOL byte-packe -> Adresse X (X0/X8) ; bit extrait d'un mot -> WBIT
                $adresseX = ""
                $wbit = 0
                if ($v.Type -eq 'BOOL' -and $null -ne $v.Bit) {
                    if ($v.IsWordBit) {
                        $wbit = $v.Bit
                    } else {
                        $adresseX = "X$($v.Bit)"
                    }
                }

                # Decalage : offset en OCTETS depuis la base du groupe (trame)
                $decalage = ($v.Register - $baseRegister) * 2
                if ($null -ne $v.Bit -and $v.Bit -ge 8) { $decalage += 1 }

                # Type: use Unity original type
                $type = $v.UnityType

                $writer.WriteLine("$nom;$adresseMW;$adresseX;$type;$desc;$decalage;$wbit;$trame")
            }
        } finally {
            $writer.Flush()
            $writer.Close()
        }

        $files += $csvFile
    }

    return @{
        Folder = $pcvueFolder
        Files  = $files
    }
}

function Group-VariablesByEquipment {
    param([array]$Variables)

    $groups = @{}

    foreach ($v in $Variables) {
        $name = $v.Name
        $dotIndex = $name.IndexOf('.')
        if ($dotIndex -gt 0) {
            $groupName = $name.Substring(0, $dotIndex)
        } else {
            $groupName = "Divers"
        }

        if (-not $groups.ContainsKey($groupName)) {
            $groups[$groupName] = @()
        }
        $groups[$groupName] += $v
    }

    return $groups
}
