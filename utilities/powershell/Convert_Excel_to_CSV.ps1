# ==============================================================
# Script:      Convert Excel (.xls) Files to CSV
# Type:        PowerShell Script
# Description: Finds all .xls files in a specified folder and
#              converts each one to a .csv file in the same folder
#              using Excel COM automation. The original .xls files
#              are left untouched.
# Use Case:    Some royalty sources (e.g., older BMI, ASCAP, or
#              label statements) deliver data as legacy .xls files
#              that must be converted to .csv before database import.
# Prerequisites: Microsoft Excel must be installed on the machine
#               running this script. The account running the script
#               must have permission to launch Excel COM objects.
# Usage:       1. Set $FolderPath (line 21) to your target folder.
#              2. Paste the entire script into a PowerShell terminal
#                 and press Enter.
#              3. Watch the console for per-file status and any errors.
# Output:      One .csv file per .xls file, saved in the same folder.
#              Existing .csv files with the same name will be
#              overwritten without prompting.
# Warning:     Only the FIRST worksheet of each workbook is saved.
#              Multi-sheet workbooks will lose all sheets except
#              the active one. Verify source files before running.
# ==============================================================


# --------------------------------------------------------------
# STEP 1: Set your folder path here
# --------------------------------------------------------------
# Replace the placeholder with the full path to your folder.
# Example: $FolderPath = "C:\Royalties\Statements\BMI\2024"
$FolderPath = "C:\YOUR\FOLDER\PATH\HERE"


# --------------------------------------------------------------
# Everything below this line runs automatically
# --------------------------------------------------------------

Write-Host "Checking folder: $FolderPath" -ForegroundColor Cyan

# Validate that the folder path exists before proceeding
if (-not (Test-Path -Path $FolderPath)) {
    Write-Host "ERROR: The folder pathway you typed does not exist! Please check the spelling." -ForegroundColor Red
    return
}

# Locate all .xls files in the folder (non-recursive — current folder only)
$files = Get-ChildItem -Path $FolderPath -Filter "*.xls" -File

if ($files.Count -eq 0) {
    Write-Host "STOPPING: No files ending in '.xls' were found in that folder." -ForegroundColor Yellow
} else {
    Write-Host "Found $($files.Count) .xls file(s). Opening Excel..." -ForegroundColor Green

    try {
        # Launch Excel as a background COM object (invisible, no prompts)
        $excel = New-Object -ComObject Excel.Application
        $excel.Visible = $false         # Run Excel silently in the background
        $excel.DisplayAlerts = $false   # Suppress Excel save/overwrite dialogs

        foreach ($file in $files) {

            # Build the output .csv path in the same folder as the source .xls
            $csvPath = [System.IO.Path]::ChangeExtension($file.FullName, ".csv")

            Write-Host "Converting: $($file.Name) -> $($file.BaseName).csv ... " -NoNewline

            $workbook = $excel.Workbooks.Open($file.FullName)

            # SaveAs format code 62 = CSV (comma-separated values, .csv)
            # Only the active/first worksheet is saved; other sheets are dropped
            $workbook.SaveAs($csvPath, 62)

            $workbook.Close($false)     # Close without saving changes back to the .xls
            Write-Host "Done." -ForegroundColor Green
        }

    } catch {
        # Surface any Excel COM errors with context for debugging
        Write-Host "ERROR DURING CONVERSION: $_" -ForegroundColor Red

    } finally {
        # Always clean up the Excel COM object, even if an error occurred.
        # Skipping this leaves Excel running invisibly in the background.
        if ($null -ne $excel) {
            $excel.Quit()
            [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
        }

        # Force .NET garbage collection to release the COM reference from memory
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()

        Write-Host "Process complete." -ForegroundColor Cyan
    }
}
