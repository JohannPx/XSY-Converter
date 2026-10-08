# XsyParser.ps1 - XSY file parsing, DDT expansion, array expansion
# Translated from edgeMap xsy-import.service.ts

# =================== CONSTANTS ===================

# Disposition memoire M340 / M580 (aide Control Expert, "DDT: Mapping Rules") :
# taille et alignement en OCTETS de chaque type elementaire.
#  - BOOL / EBOOL / BYTE : 1 octet, octet pair ou impair
#  - types 16 bits : alignes sur un octet pair
#  - types 32 bits : alignes sur un double mot (donc sur un %MW pair)
# Les types 64 bits ne sont pas couverts par la documentation : alignes comme les 32 bits.
# Premium, Quantum et le simulateur alignent tout sur 16 bits : regles non gerees ici.
$Script:TYPE_LAYOUT = @{
    BOOL=@{ Size=1; Align=1 }; EBOOL=@{ Size=1; Align=1 }; BYTE=@{ Size=1; Align=1 }
    INT=@{ Size=2; Align=2 }; UINT=@{ Size=2; Align=2 }; WORD=@{ Size=2; Align=2 }
    DINT=@{ Size=4; Align=4 }; UDINT=@{ Size=4; Align=4 }; DWORD=@{ Size=4; Align=4 }
    REAL=@{ Size=4; Align=4 }; TIME=@{ Size=4; Align=4 }; DATE=@{ Size=4; Align=4 }; TOD=@{ Size=4; Align=4 }
    DT=@{ Size=8; Align=4 }; LREAL=@{ Size=8; Align=4 }; LINT=@{ Size=8; Align=4 }; ULINT=@{ Size=8; Align=4 }
}

# Unity Pro type -> normalized format (types exportes)
$Script:TYPE_MAP = @{
    BOOL='BOOL'; EBOOL='BOOL'; INT='INT'; WORD='UINT'; UINT='UINT'
    REAL='REAL'; DINT='DINT'; UDINT='UDINT'; DWORD='UDINT'; TIME='UDINT'
    LREAL='LREAL'; LINT='LINT'; ULINT='ULINT'; STRING='STRING'
}

# Types 16 bits dont un BOOL ExtractBit peut extraire un bit
$Script:WORD_TYPES = @('INT', 'UINT', 'WORD')

# Un BOOL occupe un octet : bit X0 sur l'octet pair d'un %MW, X8 sur l'octet impair
$Script:BYTE_BOOL_BITS = @(0, 8)

$Script:BYTES_PER_REGISTER = 2

$Script:ADDRESS_REGEX = '^(%[A-Z]+)(\d+)(?:\.(\d+))?$'

# Separateur entre le commentaire d'une structure parente et celui de son membre
$Script:DESCRIPTION_SEPARATOR = ' - '

$Script:ARRAY_REGEX = '^ARRAY\[(\d+)\.\.(\d+)\]\s+OF\s+(\w+)$'

# =================== MAIN ENTRY ===================

function Import-XsyFile {
    param([string]$FilePath)

    $state = Get-AppState
    $errors = [System.Collections.ArrayList]::new()

    # Load XML
    [xml]$doc = Get-Content $FilePath -Encoding UTF8

    # Validate root element
    $root = $doc.VariablesExchangeFile
    if (-not $root) {
        throw (T "MsgInvalidXsy")
    }

    # Project name
    $contentHeader = $root.SelectSingleNode('contentHeader')
    $projectName = if ($contentHeader) { $contentHeader.GetAttribute('name') } else { $null }
    if (-not $projectName) { $projectName = "Unknown" }

    # Build DDT map
    $ddtMap = Build-DDTMap -RootNode $root

    # Process variables
    $dataBlock = $root.SelectSingleNode('dataBlock')
    $rawVars = if ($dataBlock) { $dataBlock.SelectNodes('variables') } else { $null }
    if (-not $rawVars) { $rawVars = @() }

    $stats = @{ ExcludedEbool = 0; ExcludedByte = 0 }
    $items = Expand-Variables -Variables $rawVars -DDTMap $ddtMap -Errors $errors -Stats $stats

    if ($items.Count -eq 0) {
        throw (T "MsgNoVariables")
    }

    # Deduplicate
    $uniqueItems = Remove-DuplicateVariables -Items $items -Errors $errors

    # Store in AppState
    $state.ProjectName = $projectName
    $state.ParsedVariables = $uniqueItems
    $state.DDTDefinitions = $ddtMap
    $state.ParseErrors = @($errors)
    $state.VariableCount = $uniqueItems.Count
    $state.ExcludedEbool = $stats.ExcludedEbool
    $state.ExcludedByte = $stats.ExcludedByte

    return @{
        ProjectName = $projectName
        VariableCount = $uniqueItems.Count
        ErrorCount = $errors.Count
        ExcludedEbool = $stats.ExcludedEbool
        ExcludedByte = $stats.ExcludedByte
    }
}

# =================== DDT MAP ===================

function Build-DDTMap {
    param([System.Xml.XmlElement]$RootNode)

    $map = @{}
    $ddtSources = $RootNode.SelectNodes('DDTSource')
    if (-not $ddtSources -or $ddtSources.Count -eq 0) { return $map }

    foreach ($source in $ddtSources) {
        $ddtName = $source.GetAttribute('DDTName')
        if (-not $ddtName) { continue }

        $members = [System.Collections.ArrayList]::new()
        $structNode = $source.SelectSingleNode('structure')
        if (-not $structNode) { continue }
        $vars = $structNode.SelectNodes('variables')
        if (-not $vars -or $vars.Count -eq 0) { continue }

        foreach ($v in $vars) {
            $member = @{
                Name       = $v.GetAttribute('name')
                TypeName   = $v.GetAttribute('typeName')
                Comment    = (Extract-Comment -Node $v)
                ExtractBit = $null
            }

            # Check for ExtractBit attribute
            $attrs = $v.SelectNodes('attribute')
            if ($attrs -and $attrs.Count -gt 0) {
                foreach ($a in $attrs) {
                    if ($a.GetAttribute('name') -eq 'ExtractBit') {
                        $member.ExtractBit = [int]$a.GetAttribute('value')
                        break
                    }
                }
            }

            $members.Add($member) | Out-Null
        }

        $map[$ddtName] = @{
            Name    = $ddtName
            Members = @($members)
        }
    }

    return $map
}

# =================== ADDRESS PARSING ===================

function Parse-TopologicalAddress {
    param([string]$Address)

    if ($Address -match $Script:ADDRESS_REGEX) {
        $result = @{
            Zone     = $Matches[1]
            Register = [int]$Matches[2]
            Bit      = $null
        }
        if ($Matches[3]) {
            $result.Bit = [int]$Matches[3]
        }
        return $result
    }
    return $null
}

# =================== VARIABLE EXPANSION ===================

function Expand-Variables {
    param(
        $Variables,
        [hashtable]$DDTMap,
        [System.Collections.ArrayList]$Errors,
        [hashtable]$Stats
    )

    $items = [System.Collections.ArrayList]::new()

    foreach ($v in $Variables) {
        $name = $v.GetAttribute('name')
        $typeName = $v.GetAttribute('typeName')
        $addr = $v.GetAttribute('topologicalAddress')

        # Skip variables without address
        if (-not $addr) { continue }

        $parsed = Parse-TopologicalAddress -Address $addr
        if (-not $parsed) {
            $Errors.Add("Variable `"$name`" : adresse `"$addr`" non reconnue, ignoree") | Out-Null
            continue
        }

        # Exclure les EBOOL (zone %M, coils) : espace d'adressage Modbus distinct
        # des registres %MW, non exporte. Comptabilise pour affichage a l'utilisateur.
        if ($parsed.Zone -eq '%M') {
            $Stats.ExcludedEbool++
            continue
        }

        # Garder uniquement la zone %MW
        if ($parsed.Zone -ne '%MW') { continue }

        $comment = Extract-Comment -Node $v

        # Type exporte localise directement : %MWxxxx ou %MWxxxx.b (bit extrait d'un mot)
        $format = $Script:TYPE_MAP[$typeName]
        if ($format) {
            $items.Add((New-VariableItem -Name $name -Format $format -UnityType $typeName `
                -Description $comment -Register $parsed.Register -Bit $parsed.Bit `
                -IsWordBit ($null -ne $parsed.Bit) -Zone $parsed.Zone)) | Out-Null
            continue
        }

        # ARRAY, DDT, BYTE... : deployes selon la disposition memoire M340/M580
        if (-not (Get-TypeLayout -TypeName $typeName -DDTMap $DDTMap)) {
            if ($typeName -match $Script:ARRAY_REGEX) {
                $Errors.Add("Variable `"$name`" : type ARRAY `"$typeName`" non supporte, ignore") | Out-Null
            } else {
                # FB, R_TRIG, TP... ou DDT dont un membre est inconnu
                $Errors.Add("Variable `"$name`" : type `"$typeName`" inconnu (pas de DDT), ignore") | Out-Null
            }
            continue
        }

        $expanded = Expand-TypedValue -Name $name -TypeName $typeName `
            -ByteAddress ($parsed.Register * $Script:BYTES_PER_REGISTER) -Zone $parsed.Zone `
            -DDTMap $DDTMap -Errors $Errors -Stats $Stats -Description $comment
        foreach ($item in $expanded) { $items.Add($item) | Out-Null }
    }

    return @($items)
}

# Deploie une valeur de type quelconque placee a l'adresse OCTET donnee (depuis %MW0).
# L'appelant garantit que le type a une disposition connue (cf. Get-TypeLayout).
function Expand-TypedValue {
    param(
        [string]$Name,
        [string]$TypeName,
        [int]$ByteAddress,
        [string]$Zone,
        [hashtable]$DDTMap,
        [System.Collections.ArrayList]$Errors,
        [hashtable]$Stats,
        [string]$Description
    )

    $register = [int][Math]::Floor($ByteAddress / $Script:BYTES_PER_REGISTER)

    # BYTE : exclu de l'export (comme les EBOOL), comptabilise
    if ($TypeName -eq 'BYTE') {
        $Stats.ExcludedByte++
        return @()
    }

    # BOOL : un octet, adresse sur X0 (octet pair) ou X8 (octet impair).
    # Deux BOOL consecutifs partagent ainsi le meme %MW (bits 0 et 8).
    if ($TypeName -eq 'BOOL' -or $TypeName -eq 'EBOOL') {
        $bit = $Script:BYTE_BOOL_BITS[$ByteAddress % $Script:BYTES_PER_REGISTER]
        return @(New-VariableItem -Name $Name -Format 'BOOL' -UnityType $TypeName `
            -Description $Description -Register $register -Bit $bit -IsWordBit $false -Zone $Zone)
    }

    $format = $Script:TYPE_MAP[$TypeName]
    if ($format) {
        return @(New-VariableItem -Name $Name -Format $format -UnityType $TypeName `
            -Description $Description -Register $register -Bit $null -IsWordBit $false -Zone $Zone)
    }

    if ($TypeName -match $Script:ARRAY_REGEX) {
        $startIdx = [int]$Matches[1]
        $endIdx = [int]$Matches[2]
        $elementType = $Matches[3]
        $elementSize = (Get-TypeLayout -TypeName $elementType -DDTMap $DDTMap).Size

        $items = [System.Collections.ArrayList]::new()
        for ($idx = $startIdx; $idx -le $endIdx; $idx++) {
            $expanded = Expand-TypedValue -Name "$Name[$idx]" -TypeName $elementType `
                -ByteAddress ($ByteAddress + ($idx - $startIdx) * $elementSize) -Zone $Zone `
                -DDTMap $DDTMap -Errors $Errors -Stats $Stats -Description $Description
            foreach ($item in $expanded) { $items.Add($item) | Out-Null }
        }
        return @($items)
    }

    $ddtDef = $DDTMap[$TypeName]
    if ($ddtDef) {
        return Expand-DDT -ParentName $Name -DDTDef $ddtDef -BaseByte $ByteAddress -Zone $Zone `
            -DDTMap $DDTMap -Errors $Errors -Stats $Stats -ParentDescription $Description
    }

    # DATE, TOD, DT : dimensionnes pour ne pas decaler la suite, mais sans format d'export
    $Errors.Add("Variable `"$Name`" : type `"$TypeName`" non exportable, ignore") | Out-Null
    return @()
}

# =================== DDT EXPANSION ===================

function Expand-DDT {
    param(
        [string]$ParentName,
        [hashtable]$DDTDef,
        [int]$BaseByte,
        [string]$Zone,
        [hashtable]$DDTMap,
        [System.Collections.ArrayList]$Errors,
        [hashtable]$Stats,
        [string]$ParentDescription
    )

    $items = [System.Collections.ArrayList]::new()
    $byteOffset = 0
    $lastWordRegister = [int][Math]::Floor($BaseByte / $Script:BYTES_PER_REGISTER)

    foreach ($member in $DDTDef.Members) {
        $memberName = "$ParentName.$($member.Name)"
        $memberDescription = Join-Description -Parent $ParentDescription -Own $member.Comment

        # BOOL avec ExtractBit : bit extrait du WORD/INT precedent, n'avance pas l'offset
        if ($null -ne $member.ExtractBit) {
            $items.Add((New-VariableItem -Name $memberName -Format 'BOOL' -UnityType 'BOOL' `
                -Description $memberDescription -Register $lastWordRegister -Bit $member.ExtractBit `
                -IsWordBit $true -Zone $Zone)) | Out-Null
            continue
        }

        $layout = Get-TypeLayout -TypeName $member.TypeName -DDTMap $DDTMap
        if (-not $layout) {
            # Taille inconnue : les membres suivants ne peuvent plus etre adresses
            $Errors.Add("DDT $ParentName : type `"$($member.TypeName)`" inconnu pour `"$($member.Name)`", membres suivants ignores") | Out-Null
            break
        }

        $byteOffset = Get-AlignedOffset -Offset $byteOffset -Align $layout.Align
        $memberByte = $BaseByte + $byteOffset

        if ($Script:WORD_TYPES -contains $member.TypeName) {
            $lastWordRegister = [int]($memberByte / $Script:BYTES_PER_REGISTER)
        }

        $expanded = Expand-TypedValue -Name $memberName -TypeName $member.TypeName `
            -ByteAddress $memberByte -Zone $Zone -DDTMap $DDTMap -Errors $Errors -Stats $Stats `
            -Description $memberDescription
        foreach ($item in $expanded) { $items.Add($item) | Out-Null }

        $byteOffset += $layout.Size
    }

    return @($items)
}

# =================== MEMORY LAYOUT ===================

# Taille et alignement en OCTETS d'un type, disposition M340/M580 :
#  - elementaire : cf. TYPE_LAYOUT
#  - ARRAY : elements contigus, alignement de l'element
#  - DDT : membres dans l'ordre de declaration, chacun a son alignement ; la structure
#    prend l'alignement le plus contraignant de ses membres et sa taille est completee
#    jusqu'a un multiple de cet alignement
# Retourne $null si le type, ou l'un de ses membres, est inconnu.
# NB : les BYTE sont dimensionnes (pour ne pas decaler les membres suivants)
# meme s'ils sont exclus de l'export.
function Get-TypeLayout {
    param(
        [string]$TypeName,
        [hashtable]$DDTMap
    )

    $layout = $Script:TYPE_LAYOUT[$TypeName]
    if ($layout) { return $layout }

    if ($TypeName -match $Script:ARRAY_REGEX) {
        $count = [int]$Matches[2] - [int]$Matches[1] + 1
        $element = Get-TypeLayout -TypeName $Matches[3] -DDTMap $DDTMap
        if (-not $element) { return $null }
        return @{ Size = $count * $element.Size; Align = $element.Align }
    }

    $ddtDef = $DDTMap[$TypeName]
    if (-not $ddtDef) { return $null }

    $byteOffset = 0
    $align = 1
    foreach ($member in $ddtDef.Members) {
        if ($null -ne $member.ExtractBit) { continue }

        $memberLayout = Get-TypeLayout -TypeName $member.TypeName -DDTMap $DDTMap
        if (-not $memberLayout) { return $null }

        $byteOffset = (Get-AlignedOffset -Offset $byteOffset -Align $memberLayout.Align) + $memberLayout.Size
        $align = [Math]::Max($align, $memberLayout.Align)
    }

    return @{ Size = (Get-AlignedOffset -Offset $byteOffset -Align $align); Align = $align }
}

function Get-AlignedOffset {
    param([int]$Offset, [int]$Align)

    return [int]([Math]::Ceiling($Offset / $Align) * $Align)
}

function New-VariableItem {
    param(
        [string]$Name,
        [string]$Format,
        [string]$UnityType,
        [string]$Description,
        [int]$Register,
        $Bit,
        [bool]$IsWordBit,
        [string]$Zone
    )

    $address = if ($null -ne $Bit) { "${Zone}${Register}.$Bit" } else { "${Zone}${Register}" }
    return @{
        Name        = $Name
        Type        = $Format
        UnityType   = $UnityType
        Description = $Description
        Register    = $Register
        Bit         = $Bit
        IsWordBit   = $IsWordBit  # %MWxxxx.b = bit extrait d'un mot ; sinon BOOL adresse X0/X8
        Zone        = $Zone
        Address     = $address
    }
}

# =================== HELPERS ===================

# Concatene le commentaire des structures parentes avec celui du membre.
# Un parent sans commentaire n'ajoute pas de prefixe ; un membre sans commentaire
# conserve la chaine des parents seule.
function Join-Description {
    param([string]$Parent, [string]$Own)

    if (-not $Parent) { return $Own }
    if (-not $Own) { return $Parent }
    return "$Parent$Script:DESCRIPTION_SEPARATOR$Own"
}

# Retourne le commentaire d'un noeud, normalise : retours ligne et espaces consecutifs
# compactes en un espace simple, bords supprimes. Evite les doubles espaces autour du
# separateur lors du chainage (cf. Join-Description) et les sauts de ligne qui casseraient
# une ligne CSV ou var_lst.
function Extract-Comment {
    param([System.Xml.XmlElement]$Node)

    $comment = $Node.SelectSingleNode('comment')
    if (-not $comment) { return '' }
    $text = $comment.InnerText
    if (-not $text) { return '' }
    return ($text -replace '\s+', ' ').Trim()
}

function Remove-DuplicateVariables {
    param(
        [array]$Items,
        [System.Collections.ArrayList]$Errors
    )

    $seen = @{}
    $result = [System.Collections.ArrayList]::new()

    foreach ($item in $Items) {
        $name = $item.Name
        if ($seen.ContainsKey($name)) {
            $count = $seen[$name] + 1
            $seen[$name] = $count
            $newName = "${name}_${count}"
            $Errors.Add("Variable `"$name`" dupliquee, renommee en `"$newName`"") | Out-Null
            $newItem = $item.Clone()
            $newItem.Name = $newName
            $result.Add($newItem) | Out-Null
        } else {
            $seen[$name] = 1
            $result.Add($item) | Out-Null
        }
    }

    return @($result)
}
