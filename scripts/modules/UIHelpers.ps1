# UIHelpers.ps1 - Reusable WPF helper functions

Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue

function Set-StatusBanner {
    param(
        [System.Windows.Controls.Border]$Banner,
        [System.Windows.Controls.TextBlock]$TextBlock,
        [string]$Text,
        [string]$Type  # "success" | "error" | "info" | "warning"
    )

    $brush = [System.Windows.Media.BrushConverter]::new()
    $TextBlock.Text = $Text

    switch ($Type) {
        "success" {
            $Banner.Background = $brush.ConvertFrom("#E8F8E8")
            $TextBlock.Foreground = $brush.ConvertFrom("#27AE60")
        }
        "error" {
            $Banner.Background = $brush.ConvertFrom("#FDE8E8")
            $TextBlock.Foreground = $brush.ConvertFrom("#E74C3C")
        }
        "warning" {
            $Banner.Background = $brush.ConvertFrom("#FEF3C7")
            $TextBlock.Foreground = $brush.ConvertFrom("#F59E0B")
        }
        default {  # info
            $Banner.Background = $brush.ConvertFrom("#E8F0FE")
            $TextBlock.Foreground = $brush.ConvertFrom("#1A5276")
        }
    }

    $Banner.Visibility = [System.Windows.Visibility]::Visible
}

function Set-ElementVisibility {
    param(
        [System.Windows.UIElement]$Element,
        [bool]$Visible
    )
    $Element.Visibility = if ($Visible) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }
}
