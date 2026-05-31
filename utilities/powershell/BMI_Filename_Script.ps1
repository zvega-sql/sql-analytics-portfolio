# ==============================================================
# Script:      BMI Filename Rename
# Type:        PowerShell One-Liner
# Description: Renames all files in a target folder by stripping
#              the last 7 characters from each file's base name,
#              preserving the original file extension.
# Use Case:    BMI export filenames often include a trailing date
#              stamp or processing suffix (e.g., '_202401') that
#              needs to be removed before import. This script
#              batch-removes that 7-character tail from every file
#              in the folder.
# Usage:       Replace "C:\YourFolder" with the actual folder path
#              before running. Paste the full line into a PowerShell
#              terminal and press Enter.
# Example:     "BMI_Earnings_2024Q1_202401.csv"
#               → strip 7 chars from base → "BMI_Earnings_2024Q1.csv"
# Warning:     This operation is not reversible. Verify the target
#              folder path and test on a copy of the files first.
# ==============================================================

Get-ChildItem -Path "C:\YourFolder" -File | ForEach-Object {

    $ext     = $_.Extension                          # Capture original extension (e.g., '.csv')
    $name    = $_.BaseName                           # Capture filename without extension
    $newName = $name.Substring(0, $name.Length - 7) # Drop the last 7 characters from the base name
              + $ext                                 # Re-attach the original extension

    Rename-Item -Path $_.FullName -NewName $newName
}
