# UI.ps1 - XAML definition, window initialization, event wiring

$Script:MainXaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="XSY Converter"
        Width="900" Height="650"
        WindowStartupLocation="CenterScreen"
        ResizeMode="CanResize"
        MinWidth="700" MinHeight="500"
        UseLayoutRounding="True"
        SnapsToDevicePixels="True"
        Background="#FAFAFA">
  <Window.Resources>
    <Style x:Key="SectionTitle" TargetType="TextBlock">
      <Setter Property="FontSize" Value="13"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Foreground" Value="#1A5276"/>
      <Setter Property="Margin" Value="0,16,0,6"/>
    </Style>
    <Style x:Key="SubText" TargetType="TextBlock">
      <Setter Property="Foreground" Value="#666"/>
      <Setter Property="FontSize" Value="11"/>
    </Style>
    <Style x:Key="LangBtn" TargetType="Button">
      <Setter Property="Width" Value="52"/>
      <Setter Property="Height" Value="30"/>
      <Setter Property="Margin" Value="3,0"/>
      <Setter Property="Padding" Value="0"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="BorderThickness" Value="2"/>
      <Setter Property="BorderBrush" Value="Transparent"/>
      <Setter Property="Background" Value="Transparent"/>
      <Setter Property="HorizontalContentAlignment" Value="Stretch"/>
      <Setter Property="VerticalContentAlignment" Value="Stretch"/>
    </Style>
    <Style x:Key="PrimaryBtn" TargetType="Button">
      <Setter Property="Background" Value="#1A5276"/>
      <Setter Property="Foreground" Value="White"/>
      <Setter Property="FontSize" Value="14"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Padding" Value="24,10"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="BorderThickness" Value="0"/>
    </Style>
    <Style x:Key="BrowseBtn" TargetType="Button">
      <Setter Property="Background" Value="#E2E8F0"/>
      <Setter Property="Foreground" Value="#333"/>
      <Setter Property="FontSize" Value="12"/>
      <Setter Property="Padding" Value="12,6"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Margin" Value="8,0,0,0"/>
    </Style>
  </Window.Resources>

  <DockPanel>
    <!-- =================== TOP BAR =================== -->
    <Border DockPanel.Dock="Top" Background="#1A5276" Padding="18,10">
      <DockPanel>
        <!-- Left: App title -->
        <StackPanel DockPanel.Dock="Left" Orientation="Horizontal" VerticalAlignment="Center">
          <Border Width="34" Height="34" Background="White" CornerRadius="4" Margin="0,0,12,0">
            <TextBlock Text="XSY" FontSize="11" FontWeight="Bold" Foreground="#1A5276"
                       HorizontalAlignment="Center" VerticalAlignment="Center"/>
          </Border>
          <StackPanel VerticalAlignment="Center">
            <TextBlock x:Name="txtAppTitle" Text="XSY Converter" FontSize="16"
                       FontWeight="Bold" Foreground="White"/>
            <TextBlock x:Name="txtAppSubtitle" Text="Conversion variables Schneider Unity Pro" FontSize="10"
                       Foreground="#A0C4E0"/>
          </StackPanel>
        </StackPanel>

        <!-- Right: Language flag buttons -->
        <StackPanel DockPanel.Dock="Right" Orientation="Horizontal" VerticalAlignment="Center">
          <TextBlock x:Name="txtLangLabel" Text="Langue :" VerticalAlignment="Center"
                     Foreground="#A0C4E0" FontSize="11" Margin="0,0,8,0"/>
          <!-- French flag -->
          <Button x:Name="btnLangFR" Style="{StaticResource LangBtn}" Tag="FR" ToolTip="Francais"
                  BorderBrush="#FFD700">
            <Grid>
              <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/><ColumnDefinition Width="*"/><ColumnDefinition Width="*"/>
              </Grid.ColumnDefinitions>
              <Rectangle Grid.Column="0" Fill="#002395"/>
              <Rectangle Grid.Column="1" Fill="White"/>
              <Rectangle Grid.Column="2" Fill="#ED2939"/>
            </Grid>
          </Button>
          <!-- English flag -->
          <Button x:Name="btnLangEN" Style="{StaticResource LangBtn}" Tag="EN" ToolTip="English">
            <Grid Background="#012169">
              <Rectangle Fill="White" Width="10" HorizontalAlignment="Center"/>
              <Rectangle Fill="White" Height="8" VerticalAlignment="Center"/>
              <Rectangle Fill="#CF142B" Width="5" HorizontalAlignment="Center"/>
              <Rectangle Fill="#CF142B" Height="4" VerticalAlignment="Center"/>
            </Grid>
          </Button>
          <!-- Spanish flag -->
          <Button x:Name="btnLangES" Style="{StaticResource LangBtn}" Tag="ES" ToolTip="Espanol">
            <Grid>
              <Grid.RowDefinitions>
                <RowDefinition Height="*"/><RowDefinition Height="2*"/><RowDefinition Height="*"/>
              </Grid.RowDefinitions>
              <Rectangle Grid.Row="0" Fill="#AA151B"/>
              <Rectangle Grid.Row="1" Fill="#F1BF00"/>
              <Rectangle Grid.Row="2" Fill="#AA151B"/>
            </Grid>
          </Button>
          <!-- Italian flag -->
          <Button x:Name="btnLangIT" Style="{StaticResource LangBtn}" Tag="IT" ToolTip="Italiano">
            <Grid>
              <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/><ColumnDefinition Width="*"/><ColumnDefinition Width="*"/>
              </Grid.ColumnDefinitions>
              <Rectangle Grid.Column="0" Fill="#009246"/>
              <Rectangle Grid.Column="1" Fill="White"/>
              <Rectangle Grid.Column="2" Fill="#CE2B37"/>
            </Grid>
          </Button>
        </StackPanel>

        <!-- Center spacer -->
        <Border/>
      </DockPanel>
    </Border>

    <!-- =================== MAIN CONTENT =================== -->
    <ScrollViewer VerticalScrollBarVisibility="Auto" Padding="0">
      <StackPanel Margin="32,8,32,24">

        <!-- Input file -->
        <TextBlock x:Name="lblInputFile" Text="Fichier XSY :" Style="{StaticResource SectionTitle}"/>
        <Grid>
          <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="Auto"/>
          </Grid.ColumnDefinitions>
          <TextBox x:Name="txtInputFile" Grid.Column="0" IsReadOnly="True"
                   FontSize="12" Padding="8,6" Background="White"
                   BorderBrush="#CBD5E1" BorderThickness="1"/>
          <Button x:Name="btnBrowseInput" Grid.Column="1" Content="Parcourir..."
                  Style="{StaticResource BrowseBtn}"/>
        </Grid>

        <!-- Output folder -->
        <TextBlock x:Name="lblOutputFolder" Text="Dossier de sortie :" Style="{StaticResource SectionTitle}"/>
        <Grid>
          <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="Auto"/>
          </Grid.ColumnDefinitions>
          <TextBox x:Name="txtOutputFolder" Grid.Column="0"
                   FontSize="12" Padding="8,6" Background="White"
                   BorderBrush="#CBD5E1" BorderThickness="1"/>
          <Button x:Name="btnBrowseOutput" Grid.Column="1" Content="Parcourir..."
                  Style="{StaticResource BrowseBtn}"/>
        </Grid>

        <!-- Export format (single selection ComboBox) -->
        <TextBlock x:Name="lblExportFormat" Text="Format d'export :" Style="{StaticResource SectionTitle}"/>
        <ComboBox x:Name="cbExportFormat" Width="250" Height="28" FontSize="12"
                  HorizontalAlignment="Left"/>

        <!-- PLC config section (always visible) -->
        <Border Background="#F8FAFC" BorderBrush="#E2E8F0" BorderThickness="1"
                CornerRadius="4" Padding="16,12" Margin="0,12,0,0">
          <StackPanel>
            <TextBlock x:Name="lblPlcConfig" Text="Configuration automate"
                       FontSize="12" FontWeight="SemiBold" Foreground="#1A5276" Margin="0,0,0,8"/>
            <Grid>
              <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="12"/>
                <ColumnDefinition Width="200"/>
                <ColumnDefinition Width="12"/>
                <ColumnDefinition Width="80"/>
              </Grid.ColumnDefinitions>

              <StackPanel Grid.Column="0">
                <TextBlock x:Name="lblPlcName" Text="Nom automate :" FontSize="11" Margin="0,0,0,3"/>
                <TextBox x:Name="txtPlcName" FontSize="12" Padding="6,4"/>
              </StackPanel>
              <StackPanel Grid.Column="2">
                <TextBlock x:Name="lblPlcIp" Text="Adresse IP :" FontSize="11" Margin="0,0,0,3"/>
                <TextBox x:Name="txtPlcIp" FontSize="12" Padding="6,4" Text="192.168.1.100"/>
              </StackPanel>
              <StackPanel Grid.Column="4">
                <TextBlock x:Name="lblPlcUnitId" Text="Unit ID :" FontSize="11" Margin="0,0,0,3"/>
                <TextBox x:Name="txtPlcUnitId" FontSize="12" Padding="6,4" Text="1"/>
              </StackPanel>
            </Grid>
          </StackPanel>
        </Border>

        <!-- Ewon config section -->
        <Border x:Name="pnlEwonConfig" Visibility="Collapsed"
                Background="#F8FAFC" BorderBrush="#E2E8F0" BorderThickness="1"
                CornerRadius="4" Padding="16,12" Margin="0,8,0,0">
          <StackPanel>
            <TextBlock x:Name="lblEwonConfig" Text="Configuration Ewon"
                       FontSize="12" FontWeight="SemiBold" Foreground="#1A5276" Margin="0,0,0,8"/>
            <Grid>
              <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="12"/>
                <ColumnDefinition Width="80"/>
                <ColumnDefinition Width="12"/>
                <ColumnDefinition Width="80"/>
              </Grid.ColumnDefinitions>

              <StackPanel Grid.Column="0">
                <TextBlock x:Name="lblEwonRepere" Text="Prefixe tag (opt.) :" FontSize="11" Margin="0,0,0,3"/>
                <TextBox x:Name="txtEwonRepere" FontSize="12" Padding="6,4"/>
              </StackPanel>
              <StackPanel Grid.Column="2">
                <TextBlock x:Name="lblEwonTopic" Text="Topic :" FontSize="11" Margin="0,0,0,3"/>
                <ComboBox x:Name="cmbEwonTopic" FontSize="12" Padding="6,4" SelectedIndex="0">
                  <ComboBoxItem Content="A"/>
                  <ComboBoxItem Content="B"/>
                  <ComboBoxItem Content="C"/>
                </ComboBox>
              </StackPanel>
              <StackPanel Grid.Column="4">
                <TextBlock x:Name="lblEwonPage" Text="Page :" FontSize="11" Margin="0,0,0,3"/>
                <ComboBox x:Name="cmbEwonPage" FontSize="12" Padding="6,4" SelectedIndex="0">
                  <ComboBoxItem Content="1"/>
                  <ComboBoxItem Content="2"/>
                  <ComboBoxItem Content="3"/>
                  <ComboBoxItem Content="4"/>
                  <ComboBoxItem Content="5"/>
                  <ComboBoxItem Content="6"/>
                  <ComboBoxItem Content="7"/>
                  <ComboBoxItem Content="8"/>
                  <ComboBoxItem Content="9"/>
                  <ComboBoxItem Content="10"/>
                  <ComboBoxItem Content="11"/>
                </ComboBox>
              </StackPanel>
            </Grid>
          </StackPanel>
        </Border>

        <!-- Separator -->
        <Border Margin="0,20,0,0" BorderBrush="#E2E8F0" BorderThickness="0,1,0,0"/>

        <!-- Export button -->
        <Button x:Name="btnExport" Content="Exporter" Style="{StaticResource PrimaryBtn}"
                Margin="0,16,0,0" HorizontalAlignment="Left"/>

        <!-- Status banner -->
        <Border x:Name="brdStatus" Visibility="Collapsed" CornerRadius="4"
                Padding="12,10" Margin="0,16,0,0">
          <TextBlock x:Name="txtStatus" TextWrapping="Wrap" FontSize="12"/>
        </Border>

        <!-- Detail text -->
        <TextBlock x:Name="txtDetail" Visibility="Collapsed"
                   TextWrapping="Wrap" FontSize="11" Foreground="#666"
                   Margin="0,8,0,0"/>

      </StackPanel>
    </ScrollViewer>
  </DockPanel>
</Window>
'@

# =================== APP ICON ===================

function New-AppIcon {
    # Generate a 32x32 XSY icon programmatically using WPF drawing
    $size = 32
    $dv = New-Object System.Windows.Media.DrawingVisual
    $dc = $dv.RenderOpen()

    # Background: rounded rectangle (Schneider green)
    $bgRect = New-Object System.Windows.Rect(1, 1, 30, 30)
    $bgBrush = New-Object System.Windows.Media.LinearGradientBrush(
        [System.Windows.Media.Color]::FromRgb(61, 145, 64),
        [System.Windows.Media.Color]::FromRgb(40, 110, 45),
        45)
    $bgPen = New-Object System.Windows.Media.Pen(
        (New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromRgb(30, 90, 35))), 0.5)
    $dc.DrawRoundedRectangle($bgBrush, $bgPen, $bgRect, 4, 4)

    # "XSY" text (bold, white, centered)
    $typeface = New-Object System.Windows.Media.Typeface(
        (New-Object System.Windows.Media.FontFamily("Segoe UI")),
        [System.Windows.FontStyles]::Normal,
        [System.Windows.FontWeights]::Bold,
        [System.Windows.FontStretches]::Normal)
    $formattedText = New-Object System.Windows.Media.FormattedText(
        "XSY", [System.Globalization.CultureInfo]::InvariantCulture,
        [System.Windows.FlowDirection]::LeftToRight,
        $typeface, 11, [System.Windows.Media.Brushes]::White)
    $textX = (32 - $formattedText.Width) / 2
    $textY = (32 - $formattedText.Height) / 2 - 1
    $dc.DrawText($formattedText, (New-Object System.Windows.Point($textX, $textY)))

    # Small arrow/export indicator (bottom-right corner)
    $arrowGeo = New-Object System.Windows.Media.StreamGeometry
    $ctx = $arrowGeo.Open()
    $ctx.BeginFigure((New-Object System.Windows.Point(22, 23)), $true, $true)
    $ctx.LineTo((New-Object System.Windows.Point(28, 23)), $true, $false)
    $ctx.LineTo((New-Object System.Windows.Point(25, 28)), $true, $false)
    $ctx.Close()
    $arrowBrush = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromRgb(255, 200, 0))
    $dc.DrawGeometry($arrowBrush, $null, $arrowGeo)

    $dc.Close()

    # Render to bitmap
    $rtb = New-Object System.Windows.Media.Imaging.RenderTargetBitmap($size, $size, 96, 96,
        [System.Windows.Media.PixelFormats]::Pbgra32)
    $rtb.Render($dv)
    $rtb.Freeze()
    return $rtb
}

# =================== INITIALIZATION ===================

function Initialize-MainWindow {
    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore
    Add-Type -AssemblyName WindowsBase

    # Set AppUserModelID for proper taskbar icon grouping
    Add-Type -Name Shell32AppId -Namespace Native -ErrorAction SilentlyContinue -MemberDefinition @'
        [DllImport("shell32.dll", SetLastError = true)]
        public static extern void SetCurrentProcessExplicitAppUserModelID(
            [MarshalAs(UnmanagedType.LPWStr)] string AppID);
'@
    [Native.Shell32AppId]::SetCurrentProcessExplicitAppUserModelID("XSY.Converter.1")

    # Parse XAML
    $xmlDoc = [System.Xml.XmlDocument]::new()
    $xmlDoc.LoadXml($Script:MainXaml)
    $reader = [System.Xml.XmlNodeReader]::new($xmlDoc)
    $window = [System.Windows.Markup.XamlReader]::Load($reader)

    # Set window icon
    $window.Icon = New-AppIcon

    # Affiche la version de l'app dans la barre de titre
    try { $window.Title = "XSY Converter - v$(Get-AppVersion)" } catch {}

    # Find named elements
    $ui = @{}
    $namedElements = @(
        'txtAppTitle', 'txtAppSubtitle', 'txtLangLabel',
        'btnLangFR', 'btnLangEN', 'btnLangES', 'btnLangIT',
        'lblInputFile', 'txtInputFile', 'btnBrowseInput',
        'lblOutputFolder', 'txtOutputFolder', 'btnBrowseOutput',
        'lblExportFormat', 'cbExportFormat',
        'lblPlcConfig', 'lblPlcName', 'txtPlcName',
        'lblPlcIp', 'txtPlcIp', 'lblPlcUnitId', 'txtPlcUnitId',
        'pnlEwonConfig', 'lblEwonConfig',
        'lblEwonRepere', 'txtEwonRepere',
        'lblEwonTopic', 'cmbEwonTopic',
        'lblEwonPage', 'cmbEwonPage',
        'btnExport',
        'brdStatus', 'txtStatus', 'txtDetail'
    )
    foreach ($name in $namedElements) {
        $ui[$name] = $window.FindName($name)
    }

    # Default output folder = Desktop
    $ui['txtOutputFolder'].Text = [Environment]::GetFolderPath('Desktop')

    # Populate export format ComboBox
    $ui['cbExportFormat'].Items.Clear()
    $ui['cbExportFormat'].Items.Add((T "OptCsvExchange")) | Out-Null
    $ui['cbExportFormat'].Items.Add((T "OptVarLstEwon")) | Out-Null
    $ui['cbExportFormat'].Items.Add((T "OptPcVue")) | Out-Null
    $ui['cbExportFormat'].SelectedIndex = 0

    # =================== EVENT WIRING ===================

    # Browse input file
    $ui['btnBrowseInput'].Add_Click({
        $dlg = New-Object Microsoft.Win32.OpenFileDialog
        $dlg.Filter = "Fichiers XSY (*.xsy)|*.xsy|Tous les fichiers (*.*)|*.*"
        $dlg.Title = "Selectionner un fichier XSY"
        if ($dlg.ShowDialog() -eq $true) {
            $ui['txtInputFile'].Text = $dlg.FileName
            $state = Get-AppState
            $state.InputFilePath = $dlg.FileName

            # Hide previous status
            $ui['brdStatus'].Visibility = [System.Windows.Visibility]::Collapsed
            $ui['txtDetail'].Visibility = [System.Windows.Visibility]::Collapsed
        }
    }.GetNewClosure())

    # Browse output folder
    $ui['btnBrowseOutput'].Add_Click({
        $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
        $dlg.Description = T "LblOutputFolder"
        $dlg.SelectedPath = $ui['txtOutputFolder'].Text
        if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $ui['txtOutputFolder'].Text = $dlg.SelectedPath
        }
    }.GetNewClosure())

    # Export format ComboBox selection changed -> toggle Ewon config + update AppState
    $ui['cbExportFormat'].Add_SelectionChanged({
        $idx = $ui['cbExportFormat'].SelectedIndex
        switch ($idx) {
            0 {
                Set-AppStateValue -Key "ExportFormat" -Value "CSV"
                Set-ElementVisibility -Element $ui['pnlEwonConfig'] -Visible $false
            }
            1 {
                Set-AppStateValue -Key "ExportFormat" -Value "EWON"
                Set-ElementVisibility -Element $ui['pnlEwonConfig'] -Visible $true
            }
            2 {
                Set-AppStateValue -Key "ExportFormat" -Value "PCVUE"
                Set-ElementVisibility -Element $ui['pnlEwonConfig'] -Visible $false
            }
        }
    }.GetNewClosure())

    # Language buttons (FR, EN, ES, IT)
    foreach ($langCode in @("FR", "EN", "ES", "IT")) {
        $btn = $ui["btnLang$langCode"]
        $lang = $langCode
        $btn.Add_Click({
            Set-Language $lang
            Update-UITexts -UI $ui
            Update-LanguageButtonHighlight -UI $ui -Lang $lang
        }.GetNewClosure())
    }

    # Export button
    $ui['btnExport'].Add_Click({
        Invoke-Export -UI $ui
    }.GetNewClosure())

    return $window
}

# =================== LANGUAGE HIGHLIGHT ===================

function Update-LanguageButtonHighlight {
    param(
        [hashtable]$UI,
        [string]$Lang
    )

    $brush = [System.Windows.Media.BrushConverter]::new()
    $goldBrush = $brush.ConvertFrom("#FFD700")
    $transparentBrush = [System.Windows.Media.Brushes]::Transparent

    foreach ($langCode in @("FR", "EN", "ES", "IT")) {
        $btn = $UI["btnLang$langCode"]
        if ($langCode -eq $Lang) {
            $btn.BorderBrush = $goldBrush
        } else {
            $btn.BorderBrush = $transparentBrush
        }
    }
}

# =================== UI TEXT UPDATE ===================

function Update-UITexts {
    param([hashtable]$UI)

    $UI['txtAppTitle'].Text = T "AppTitle"
    $UI['txtAppSubtitle'].Text = T "AppSubtitle"
    $UI['txtLangLabel'].Text = T "LangLabel"
    $UI['lblInputFile'].Text = T "LblInputFile"
    $UI['btnBrowseInput'].Content = T "BtnBrowseInput"
    $UI['lblOutputFolder'].Text = T "LblOutputFolder"
    $UI['btnBrowseOutput'].Content = T "BtnBrowseOutput"
    $UI['lblExportFormat'].Text = T "LblExportFormat"
    $UI['lblPlcConfig'].Text = T "LblPlcConfig"
    $UI['lblPlcName'].Text = T "LblPlcName"
    $UI['lblPlcIp'].Text = T "LblPlcIp"
    $UI['lblPlcUnitId'].Text = T "LblPlcUnitId"
    $UI['lblEwonConfig'].Text = T "LblEwonConfig"
    $UI['lblEwonRepere'].Text = T "LblEwonRepere"
    $UI['lblEwonTopic'].Text = T "LblEwonTopic"
    $UI['lblEwonPage'].Text = T "LblEwonPage"
    $UI['btnExport'].Content = T "BtnExport"

    # Update ComboBox items while preserving selection
    $fmtIdx = $UI['cbExportFormat'].SelectedIndex
    $UI['cbExportFormat'].Items.Clear()
    $UI['cbExportFormat'].Items.Add((T "OptCsvExchange")) | Out-Null
    $UI['cbExportFormat'].Items.Add((T "OptVarLstEwon")) | Out-Null
    $UI['cbExportFormat'].Items.Add((T "OptPcVue")) | Out-Null
    $UI['cbExportFormat'].SelectedIndex = $fmtIdx
}

# =================== EXPORT ORCHESTRATION ===================

function Invoke-Export {
    param([hashtable]$UI)

    $state = Get-AppState

    # Validate input
    $inputFile = $UI['txtInputFile'].Text
    if (-not $inputFile -or -not (Test-Path $inputFile)) {
        Set-StatusBanner -Banner $UI['brdStatus'] -TextBlock $UI['txtStatus'] `
            -Text (T "MsgNoFile") -Type "error"
        $UI['txtDetail'].Visibility = [System.Windows.Visibility]::Collapsed
        return
    }

    $outputFolder = $UI['txtOutputFolder'].Text
    if (-not $outputFolder) {
        $outputFolder = [Environment]::GetFolderPath('Desktop')
    }

    # Determine selected format from ComboBox index
    $formatIdx = $UI['cbExportFormat'].SelectedIndex
    $format = switch ($formatIdx) {
        0 { "CSV" }
        1 { "EWON" }
        2 { "PCVUE" }
        default { "CSV" }
    }

    # Parse XSY
    try {
        Set-StatusBanner -Banner $UI['brdStatus'] -TextBlock $UI['txtStatus'] `
            -Text "Parsing XSY..." -Type "info"
        $UI['txtDetail'].Visibility = [System.Windows.Visibility]::Collapsed

        $parseResult = Import-XsyFile -FilePath $inputFile

        $statusText = (T "MsgParseSuccess") -f $parseResult.VariableCount, $parseResult.ProjectName
        if ($parseResult.ErrorCount -gt 0) {
            $statusText += " | " + ((T "MsgParseErrors") -f $parseResult.ErrorCount)
        }
        Set-StatusBanner -Banner $UI['brdStatus'] -TextBlock $UI['txtStatus'] `
            -Text $statusText -Type "info"
    } catch {
        Set-StatusBanner -Banner $UI['brdStatus'] -TextBlock $UI['txtStatus'] `
            -Text "$((T 'MsgError')): $($_.Exception.Message)" -Type "error"
        $UI['txtDetail'].Visibility = [System.Windows.Visibility]::Collapsed
        return
    }

    # Export
    $state.IsExporting = $true
    $files = @()
    $errors = @()

    try {
        $variables = $state.ParsedVariables
        $projectName = $state.ProjectName

        switch ($format) {
            "CSV" {
                try {
                    $plcConfig = @{
                        Name      = $UI['txtPlcName'].Text
                        IpAddress = $UI['txtPlcIp'].Text
                        UnitId    = $UI['txtPlcUnitId'].Text
                    }
                    $csvFile = Export-CsvExchangeTable -Variables $variables -OutputFolder $outputFolder -ProjectName $projectName -PlcConfig $plcConfig
                    $files += $csvFile
                } catch {
                    $errors += "CSV: $($_.Exception.Message)"
                }
            }
            "EWON" {
                try {
                    $ewonConfig = @{
                        Repere    = $UI['txtEwonRepere'].Text
                        Topic     = $UI['cmbEwonTopic'].Text
                        PageId    = [int]$UI['cmbEwonPage'].Text
                        IpAddress = $UI['txtPlcIp'].Text
                        UnitId    = $UI['txtPlcUnitId'].Text
                    }
                    $ewonFile = Export-EwonVarLst -Variables $variables -OutputFolder $outputFolder -EwonConfig $ewonConfig
                    $files += $ewonFile
                } catch {
                    $errors += "Ewon: $($_.Exception.Message)"
                }
            }
            "PCVUE" {
                try {
                    $pcvueResult = Export-PcVueArchitect -Variables $variables -OutputFolder $outputFolder -ProjectName $projectName
                    $files += $pcvueResult.Files
                } catch {
                    $errors += "PcVue: $($_.Exception.Message)"
                }
            }
        }

        # Show result
        $doneMsg = switch ($format) {
            "CSV" { T "MsgExportCsvDone" }
            "EWON" { T "MsgExportEwonDone" }
            "PCVUE" { T "MsgExportPcVueDone" }
        }

        if ($errors.Count -eq 0) {
            $msg = $doneMsg + " " + ((T "MsgFileCount") -f $files.Count)
            Set-StatusBanner -Banner $UI['brdStatus'] -TextBlock $UI['txtStatus'] `
                -Text $msg -Type "success"

            $detailLines = @((T "MsgExportFolder") -f $outputFolder)
            if ($state.ParseErrors.Count -gt 0) {
                $detailLines += ""
                $detailLines += (T "MsgExportDetail")
                $detailLines += ($state.ParseErrors | Select-Object -First 20)
            }
            $UI['txtDetail'].Text = $detailLines -join "`n"
            $UI['txtDetail'].Visibility = [System.Windows.Visibility]::Visible
        } else {
            $msg = $doneMsg + " | " + ((T "MsgExportErrors") -f $errors.Count)
            Set-StatusBanner -Banner $UI['brdStatus'] -TextBlock $UI['txtStatus'] `
                -Text $msg -Type "warning"
            $UI['txtDetail'].Text = ($errors -join "`n")
            $UI['txtDetail'].Visibility = [System.Windows.Visibility]::Visible
        }

        # Open output folder
        Start-Process explorer.exe $outputFolder

    } finally {
        $state.IsExporting = $false
    }
}
