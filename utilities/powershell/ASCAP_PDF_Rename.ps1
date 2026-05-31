# ==============================================================
# Script:      ASCAP PDF Filename Rename
# Type:        PowerShell One-Liner
# Description: Renames all PDF files in a target folder by removing
#              the first 10 characters from each file's base name,
#              preserving the .pdf extension.
# Use Case:    ASCAP PDF statements are often delivered with a
#              10-character numeric or date prefix (e.g., a statement
#              ID or timestamp) prepended to the meaningful filename.
#              This script batch-strips that prefix so the remaining
#              name is clean for filing or import matching.
# Usage:       Replace "C:\YourFolder" with the actual folder path
#              before running. Paste the full line into a PowerShell
#              terminal and press Enter.
# Example:     "0123456789ASCAP_Statement_Q1.pdf"
#               → skip first 10 chars → "ASCAP_Statement_Q1.pdf"
# Warning:     This operation is not reversible. Verify the target
#              folder path and test on a copy of the files first.
#              All .pdf files in the folder will be renamed — scope
#              the folder accordingly to avoid unintended renames.
# ==============================================================

Get-ChildItem -Path "C:\YourFolder" -Filter "*.pdf" -File | ForEach-Object {

    $ext     = $_.Extension            # Capture original extension ('.pdf')
    $name    = $_.BaseName             # Capture filename without extension
    $newName = $name.Substring(10)     # Skip the first 10 characters of the base name
              + $ext                   # Re-attach the .pdf extension

    Rename-Item -Path $_.FullName -NewName $newName
}
