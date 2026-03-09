# ExportEwon.ps1 - Export as Ewon Flexy var_lst.csv (Modbus TCP)
# Address format from edgeMap: +{base+register}{formatSuffix}{bit},{unitId},{IP}

# Ewon display type: 0=BOOL, 1=Float, 2=Int(8/16bit), 3=DWord(32/64bit)
$Script:EWON_TYPE_MAP = @{
    BOOL=0
    BYTE=2; INT=2; UINT=2
    REAL=1; LREAL=1
    DINT=3; UDINT=3
    LINT=3; ULINT=3
    STRING=2
}

# Modbus format suffix (without wordswipe)
$Script:MODBUS_FORMAT = @{
    BOOL='#'
    BYTE='I'
    INT='I'
    UINT='W'
    DINT='L'
    UDINT='D'
    REAL='F'
    LREAL='F'
    LINT='L'
    ULINT='D'
    STRING='W'
}

# 62-column var_lst header (Ewon Flexy format)
$Script:VAR_LST_COLUMNS = @(
    @{N="Id";T="num"};@{N="Name";T="str"};@{N="Description";T="str"};@{N="ServerName";T="str"}
    @{N="TopicName";T="str"};@{N="Address";T="str"};@{N="Coef";T="num"};@{N="Offset";T="num"}
    @{N="LogEnabled";T="num"};@{N="AlEnabled";T="num"};@{N="AlBool";T="num"};@{N="MemTag";T="num"}
    @{N="MbsTcpEnabled";T="num"};@{N="MbsTcpFloat";T="num"};@{N="SnmpEnabled";T="num"}
    @{N="RTLogEnabled";T="num"};@{N="AlAutoAck";T="num"};@{N="ForceRO";T="num"}
    @{N="SnmpOID";T="num"};@{N="AutoType";T="num"};@{N="AlHint";T="str"};@{N="AlHigh";T="num"}
    @{N="AlLow";T="num"};@{N="AlTimeDB";T="num"};@{N="AlLevelDB";T="num"}
    @{N="IVGroupA";T="num"};@{N="IVGroupB";T="num"};@{N="IVGroupC";T="num"};@{N="IVGroupD";T="num"}
    @{N="PageId";T="num"};@{N="RTLogWindow";T="num"};@{N="RTLogTimer";T="num"}
    @{N="LogDB";T="num"};@{N="LogTimer";T="num"};@{N="AlLoLo";T="num"};@{N="AlHiHi";T="num"}
    @{N="MbsTcpRegister";T="num"};@{N="MbsTcpCoef";T="num"};@{N="MbsTcpOffset";T="num"}
    @{N="EEN";T="num"};@{N="ETO";T="str"};@{N="ECC";T="str"};@{N="ESU";T="str"};@{N="EAT";T="str"}
    @{N="ESH";T="num"};@{N="SEN";T="num"};@{N="STO";T="str"};@{N="SSU";T="str"}
    @{N="TEN";T="num"};@{N="TSU";T="str"};@{N="FEN";T="num"};@{N="FFN";T="str"};@{N="FCO";T="str"}
    @{N="KPI";T="num"};@{N="UseCustomUnit";T="num"};@{N="Type";T="num"};@{N="Unit";T="str"}
    @{N="AlStat";T="num"};@{N="ChangeTime";T="str"};@{N="TagValue";T="num"}
    @{N="TagQuality";T="num"};@{N="AlType";T="num"}
)

# =================== HELPERS ===================

function Format-EwonStr {
    param([string]$Value)
    if (-not $Value) { return '""' }
    $escaped = $Value.Replace('"', '""')
    return "`"$escaped`""
}

function Format-EwonFloat {
    param($Value)
    if ($null -eq $Value) { return "" }
    return ([double]$Value).ToString("F6")
}

function Get-EwonModbusAddress {
    param(
        [int]$Register,
        $Bit,
        [string]$DataType,
        [string]$IpAddress,
        [string]$UnitId
    )

    # Modbus holding register base (%MW -> 400001)
    $modbusAddr = 400001 + $Register

    # Format suffix from type
    $suffix = $Script:MODBUS_FORMAT[$DataType]
    if (-not $suffix) { $suffix = 'W' }

    # Build address: +{addr}{suffix}{bit}
    if ($DataType -eq 'BOOL') {
        # BOOL: +400100#0  (# suffix + bit number, default bit 0)
        $bitNum = if ($null -ne $Bit) { $Bit } else { 0 }
        $address = "+${modbusAddr}${suffix}${bitNum}"
    } else {
        # Other: +400100F
        $address = "+${modbusAddr}${suffix}"
    }

    # Append unitId and IP: ,unitId,IP
    if ($UnitId) {
        $address += ",${UnitId}"
    }
    if ($IpAddress) {
        $address += ",${IpAddress}"
    }

    return $address
}

# =================== EXPORT ===================

function Export-EwonVarLst {
    param(
        [array]$Variables,
        [string]$OutputFolder,
        [hashtable]$EwonConfig
    )

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $fileName = "var_lst_${timestamp}.csv"
    $filePath = Join-Path $OutputFolder $fileName

    # Latin-1 encoding (ISO-8859-1)
    $encoding = [System.Text.Encoding]::GetEncoding('iso-8859-1')
    $writer = New-Object System.IO.StreamWriter($filePath, $false, $encoding)

    try {
        # Header
        $header = ($Script:VAR_LST_COLUMNS | ForEach-Object { "`"$($_.N)`"" }) -join ";"
        $writer.Write("$header`r`n")

        # Sort by register
        $sorted = $Variables | Sort-Object { $_.Register }, { if ($_.Bit) { $_.Bit } else { -1 } }

        foreach ($v in $sorted) {
            $dt = $v.Type
            $ewonType = $Script:EWON_TYPE_MAP[$dt]
            if ($null -eq $ewonType) { $ewonType = 0 }

            # Name: {repere}.{name} or just {name}
            $tagName = if ($EwonConfig.Repere) { "$($EwonConfig.Repere).$($v.Name)" } else { $v.Name }

            # Address with format suffix, unitId and IP
            $address = Get-EwonModbusAddress -Register $v.Register -Bit $v.Bit `
                -DataType $dt -IpAddress $EwonConfig.IpAddress -UnitId $EwonConfig.UnitId

            # Build 62-column values array
            $vals = @(
                ""                                          #  0 Id (auto)
                (Format-EwonStr $tagName)                   #  1 Name
                (Format-EwonStr $v.Description)             #  2 Description
                (Format-EwonStr "MODBUS")                   #  3 ServerName
                (Format-EwonStr $EwonConfig.Topic)          #  4 TopicName
                (Format-EwonStr $address)                   #  5 Address
                (Format-EwonFloat 1)                        #  6 Coef
                (Format-EwonFloat 0)                        #  7 Offset (scaling)
                "1"                                         #  8 LogEnabled
                "0"                                         #  9 AlEnabled
                "0"                                         # 10 AlBool
                "0"                                         # 11 MemTag
                "0"                                         # 12 MbsTcpEnabled
                "0"                                         # 13 MbsTcpFloat
                "0"                                         # 14 SnmpEnabled
                "0"                                         # 15 RTLogEnabled
                "0"                                         # 16 AlAutoAck
                "0"                                         # 17 ForceRO
                "1"                                         # 18 SnmpOID
                "0"                                         # 19 AutoType
                '""'                                        # 20 AlHint
                (Format-EwonFloat 0)                        # 21 AlHigh
                (Format-EwonFloat 0)                        # 22 AlLow
                "0"                                         # 23 AlTimeDB
                (Format-EwonFloat 0)                        # 24 AlLevelDB
                "0"                                         # 25 IVGroupA
                "0"                                         # 26 IVGroupB
                "0"                                         # 27 IVGroupC
                "0"                                         # 28 IVGroupD
                "$($EwonConfig.PageId)"                     # 29 PageId
                "600"                                       # 30 RTLogWindow
                "10"                                        # 31 RTLogTimer
                (Format-EwonFloat (-1))                     # 32 LogDB
                "60"                                        # 33 LogTimer
                ""                                          # 34 AlLoLo
                ""                                          # 35 AlHiHi
                "1"                                         # 36 MbsTcpRegister
                (Format-EwonFloat 1)                        # 37 MbsTcpCoef
                (Format-EwonFloat 0)                        # 38 MbsTcpOffset
                ""                                          # 39 EEN
                '""'                                        # 40 ETO
                '""'                                        # 41 ECC
                '""'                                        # 42 ESU
                '""'                                        # 43 EAT
                ""                                          # 44 ESH
                ""                                          # 45 SEN
                '""'                                        # 46 STO
                '""'                                        # 47 SSU
                ""                                          # 48 TEN
                '""'                                        # 49 TSU
                ""                                          # 50 FEN
                '""'                                        # 51 FFN
                '""'                                        # 52 FCO
                "0"                                         # 53 KPI
                "0"                                         # 54 UseCustomUnit
                "$ewonType"                                 # 55 Type
                '""'                                        # 56 Unit
                "0"                                         # 57 AlStat
                '""'                                        # 58 ChangeTime
                "0"                                         # 59 TagValue
                "65472"                                     # 60 TagQuality
                "0"                                         # 61 AlType
            )

            $writer.Write(($vals -join ";") + "`r`n")
        }
    } finally {
        $writer.Flush()
        $writer.Close()
    }

    return $filePath
}
