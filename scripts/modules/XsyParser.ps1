# XsyParser.ps1 - XSY file parsing, DDT expansion, array expansion
# Translated from edgeMap xsy-import.service.ts

# =================== CONSTANTS ===================

# Type sizes in 16-bit Modbus registers
$Script:TYPE_SIZE_REGISTERS = @{
    BOOL=1; EBOOL=1; INT=1; WORD=1; UINT=1; BYTE=1
    REAL=2; DINT=2; UDINT=2
    LREAL=4; LINT=4; ULINT=4
}

# Unity Pro type -> normalized format
$Script:TYPE_MAP = @{
    BOOL='BOOL'; EBOOL='BOOL'; INT='INT'; WORD='UINT'; UINT='UINT'
    REAL='REAL'; DINT='DINT'; UDINT='UDINT'; BYTE='BYTE'
    LREAL='LREAL'; LINT='LINT'; ULINT='ULINT'; STRING='STRING'
}

$Script:ADDRESS_REGEX = '^(%[A-Z]+)(\d+)(?:\.(\d+))?$'

# Safe XML child element access (avoids StrictMode errors on missing properties)
function Get-XmlChild {
    param([System.Xml.XmlElement]$Node, [string]$ChildName)
    $child = $Node.SelectSingleNode($ChildName)
    return $child
}
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

    $stats = @{ ExcludedEbool = 0 }
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

    return @{
        ProjectName = $projectName
        VariableCount = $uniqueItems.Count
        ErrorCount = $errors.Count
        ExcludedEbool = $stats.ExcludedEbool
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

        # 1. Check ARRAY type
        if ($typeName -match $Script:ARRAY_REGEX) {
            $startIdx = [int]$Matches[1]
            $endIdx = [int]$Matches[2]
            $elementType = $Matches[3]

            $expanded = Expand-ArrayType -VarName $name -StartIdx $startIdx -EndIdx $endIdx `
                -ElementType $elementType -ParsedAddress $parsed -Comment $comment
            if ($expanded) {
                foreach ($item in $expanded) { $items.Add($item) | Out-Null }
            } else {
                $Errors.Add("Variable `"$name`" : type ARRAY `"$typeName`" non supporte, ignore") | Out-Null
            }
            continue
        }

        # 2. Check primitive type
        $format = $Script:TYPE_MAP[$typeName]
        if ($format) {
            $items.Add(@{
                Name      = $name
                Type      = $format
                UnityType = $typeName
                Description = $comment
                Register  = $parsed.Register
                Bit       = $parsed.Bit
                IsWordBit = ($null -ne $parsed.Bit)  # %MWxxxx.b = bit extrait d'un mot
                Zone      = $parsed.Zone
                Address   = $addr
            }) | Out-Null
            continue
        }

        # 3. Check DDT type
        $ddtDef = $DDTMap[$typeName]
        if ($ddtDef) {
            $expanded = Expand-DDT -ParentName $name -DDTDef $ddtDef -BaseRegister $parsed.Register `
                -Zone $parsed.Zone -DDTMap $DDTMap -Errors $Errors
            foreach ($item in $expanded) { $items.Add($item) | Out-Null }
            continue
        }

        # Unknown type - skip silently (FB, R_TRIG, TP, etc.)
        $Errors.Add("Variable `"$name`" : type `"$typeName`" inconnu (pas de DDT), ignore") | Out-Null
    }

    return @($items)
}

# =================== ARRAY EXPANSION ===================

function Expand-ArrayType {
    param(
        [string]$VarName,
        [int]$StartIdx,
        [int]$EndIdx,
        [string]$ElementType,
        [hashtable]$ParsedAddress,
        [string]$Comment
    )

    $format = $Script:TYPE_MAP[$ElementType]
    if (-not $format) { return $null }

    $count = $EndIdx - $StartIdx + 1
    $items = [System.Collections.ArrayList]::new()

    if ($ElementType -eq 'BOOL' -or $ElementType -eq 'EBOOL') {
        # Tableau de BOOL : packe 16 bits par mot (bits 0..15 = bits extraits du mot)
        for ($i = 0; $i -lt $count; $i++) {
            $idx = $StartIdx + $i
            $wordOffset = [Math]::Floor($i / 16)
            $bitPosition = $i % 16
            $items.Add(@{
                Name      = "$VarName[$idx]"
                Type      = 'BOOL'
                UnityType = $ElementType
                Description = $Comment
                Register  = $ParsedAddress.Register + $wordOffset
                Bit       = $bitPosition
                IsWordBit = $true
                Zone      = $ParsedAddress.Zone
                Address   = "$($ParsedAddress.Zone)$($ParsedAddress.Register + $wordOffset).$bitPosition"
            }) | Out-Null
        }
    } else {
        $elemSize = $Script:TYPE_SIZE_REGISTERS[$ElementType]
        if (-not $elemSize) { $elemSize = 1 }
        for ($i = 0; $i -lt $count; $i++) {
            $idx = $StartIdx + $i
            $reg = $ParsedAddress.Register + ($i * $elemSize)
            $items.Add(@{
                Name      = "$VarName[$idx]"
                Type      = $format
                UnityType = $ElementType
                Description = $Comment
                Register  = $reg
                Bit       = $null
                IsWordBit = $false
                Zone      = $ParsedAddress.Zone
                Address   = "$($ParsedAddress.Zone)$reg"
            }) | Out-Null
        }
    }

    return @($items)
}

# =================== DDT EXPANSION ===================

function Expand-DDT {
    param(
        [string]$ParentName,
        [hashtable]$DDTDef,
        [int]$BaseRegister,
        [string]$Zone,
        [hashtable]$DDTMap,
        [System.Collections.ArrayList]$Errors
    )

    $items = [System.Collections.ArrayList]::new()
    # Offset en OCTETS depuis BaseRegister (packing memoire Schneider, cf. Get-DDTSizeBytes)
    $byteOffset = 0
    $lastWordRegister = $BaseRegister

    foreach ($member in $DDTDef.Members) {
        # BOOL avec ExtractBit : bit extrait du WORD/INT precedent, n'avance pas l'offset
        if ($null -ne $member.ExtractBit) {
            $items.Add(@{
                Name      = "$ParentName.$($member.Name)"
                Type      = 'BOOL'
                UnityType = 'BOOL'
                Description = if ($member.Comment) { $member.Comment } else { '' }
                Register  = $lastWordRegister
                Bit       = $member.ExtractBit
                IsWordBit = $true
                Zone      = $Zone
                Address   = "${Zone}${lastWordRegister}.$($member.ExtractBit)"
            }) | Out-Null
            continue
        }

        # BOOL simple : occupe 1 octet, adresse sur X0 (octet pair) ou X8 (octet impair).
        # Deux BOOL consecutifs partagent ainsi le meme %MW (bits 0 et 8).
        if ($member.TypeName -eq 'BOOL' -or $member.TypeName -eq 'EBOOL') {
            $register = $BaseRegister + [int][Math]::Floor($byteOffset / 2)
            $bit = if ($byteOffset % 2 -eq 0) { 0 } else { 8 }
            $items.Add(@{
                Name      = "$ParentName.$($member.Name)"
                Type      = 'BOOL'
                UnityType = $member.TypeName
                Description = if ($member.Comment) { $member.Comment } else { '' }
                Register  = $register
                Bit       = $bit
                IsWordBit = $false  # adressage octet X0/X8, pas un bit de mot
                Zone      = $Zone
                Address   = "${Zone}${register}.$bit"
            }) | Out-Null
            $byteOffset += 1
            continue
        }

        # Types multi-octets : alignement sur frontiere de mot (octet pair)
        if ($byteOffset % 2 -ne 0) { $byteOffset += 1 }
        $register = $BaseRegister + [int]($byteOffset / 2)

        $format = $Script:TYPE_MAP[$member.TypeName]
        if ($format) {
            $sizeRegisters = $Script:TYPE_SIZE_REGISTERS[$member.TypeName]
            if (-not $sizeRegisters) { $sizeRegisters = 1 }

            # Memorise le dernier WORD/INT pour les BOOL ExtractBit suivants
            if ($member.TypeName -eq 'WORD' -or $member.TypeName -eq 'INT' -or $member.TypeName -eq 'UINT') {
                $lastWordRegister = $register
            }

            $items.Add(@{
                Name      = "$ParentName.$($member.Name)"
                Type      = $format
                UnityType = $member.TypeName
                Description = if ($member.Comment) { $member.Comment } else { '' }
                Register  = $register
                Bit       = $null
                IsWordBit = $false
                Zone      = $Zone
                Address   = "${Zone}${register}"
            }) | Out-Null
            $byteOffset += $sizeRegisters * 2
        } else {
            # DDT imbrique ou ARRAY dans un DDT
            $nestedDDT = $DDTMap[$member.TypeName]
            if ($nestedDDT) {
                $nestedItems = Expand-DDT -ParentName "$ParentName.$($member.Name)" `
                    -DDTDef $nestedDDT -BaseRegister $register `
                    -Zone $Zone -DDTMap $DDTMap -Errors $Errors
                foreach ($item in $nestedItems) { $items.Add($item) | Out-Null }
                $byteOffset += (Get-DDTSizeBytes -DDTDef $nestedDDT -DDTMap $DDTMap)
            } elseif ($member.TypeName -match $Script:ARRAY_REGEX) {
                # ARRAY dans un DDT
                $startIdx = [int]$Matches[1]
                $endIdx = [int]$Matches[2]
                $elementType = $Matches[3]
                $parsedAddr = @{ Zone = $Zone; Register = $register; Bit = $null }
                $expanded = Expand-ArrayType -VarName "$ParentName.$($member.Name)" `
                    -StartIdx $startIdx -EndIdx $endIdx -ElementType $elementType `
                    -ParsedAddress $parsedAddr -Comment ($member.Comment)
                if ($expanded) {
                    foreach ($item in $expanded) { $items.Add($item) | Out-Null }
                    # Taille du tableau en octets (un ARRAY OF BOOL est packe 16 bits/mot)
                    $arrCount = $endIdx - $startIdx + 1
                    if ($elementType -eq 'BOOL' -or $elementType -eq 'EBOOL') {
                        $byteOffset += [int][Math]::Ceiling($arrCount / 16) * 2
                    } else {
                        $eSize = $Script:TYPE_SIZE_REGISTERS[$elementType]
                        if (-not $eSize) { $eSize = 1 }
                        $byteOffset += ($arrCount * $eSize * 2)
                    }
                }
            } else {
                $Errors.Add("DDT $ParentName : type `"$($member.TypeName)`" inconnu pour `"$($member.Name)`", ignore") | Out-Null
            }
        }
    }

    return @($items)
}

# =================== DDT SIZE ===================

# Taille d'un DDT en OCTETS, packing memoire Schneider :
#  - BOOL = 1 octet (deux BOOL consecutifs tiennent dans un mot, bits X0/X8)
#  - types multi-octets alignes sur frontiere de mot (octet pair)
#  - la structure est completee (padding) jusqu'a une frontiere de mot
function Get-DDTSizeBytes {
    param(
        [hashtable]$DDTDef,
        [hashtable]$DDTMap
    )

    $byteOffset = 0
    foreach ($member in $DDTDef.Members) {
        if ($null -ne $member.ExtractBit) { continue }

        if ($member.TypeName -eq 'BOOL' -or $member.TypeName -eq 'EBOOL') {
            $byteOffset += 1
            continue
        }

        # Alignement sur frontiere de mot avant un type multi-octets
        if ($byteOffset % 2 -ne 0) { $byteOffset += 1 }

        $typeSize = $Script:TYPE_SIZE_REGISTERS[$member.TypeName]
        if ($null -ne $typeSize) {
            $byteOffset += $typeSize * 2
        } else {
            $nested = $DDTMap[$member.TypeName]
            if ($nested) {
                $byteOffset += (Get-DDTSizeBytes -DDTDef $nested -DDTMap $DDTMap)
            } elseif ($member.TypeName -match $Script:ARRAY_REGEX) {
                $arrCount = [int]$Matches[2] - [int]$Matches[1] + 1
                $elemType = $Matches[3]
                if ($elemType -eq 'BOOL' -or $elemType -eq 'EBOOL') {
                    $byteOffset += [int][Math]::Ceiling($arrCount / 16) * 2
                } else {
                    $eSize = $Script:TYPE_SIZE_REGISTERS[$elemType]
                    if (-not $eSize) { $eSize = 1 }
                    $byteOffset += ($arrCount * $eSize * 2)
                }
            }
        }
    }

    # Padding de fin de structure : completer jusqu'a une frontiere de mot
    if ($byteOffset % 2 -ne 0) { $byteOffset += 1 }
    return [int]$byteOffset
}

# =================== HELPERS ===================

function Extract-Comment {
    param([System.Xml.XmlElement]$Node)

    $comment = $Node.SelectSingleNode('comment')
    if (-not $comment) { return '' }
    $text = $comment.InnerText
    if ($text) { return $text }
    return ''
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
