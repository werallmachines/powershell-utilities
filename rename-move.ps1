####################################################
# Tool to move inside 1-level of folders, rename   #
# contents with naming scheme of 'n_', then move   #
# files to given directory.                        #
#                                                  #
# Authour: Web Team (Matt Sanderson)               #
# Date: 2019-05-24                                 #
####################################################

$move_to = Read-Host "Absolute path to move files to"
$folders_loc = Read-Host "Absolute path to folders location"

[System.Collections.ArrayList]$prefix = 1..99

cd $folders_loc
$folders = Get-ChildItem -Directory

foreach ($folder in $folders) {
    Write-Output "Renaming and moving files inside: $folder"
    $prefix_value = $prefix[0]
    cd $folders_loc
    cd $folder
    $files = Get-ChildItem -File
    foreach ($file in $files) {
        Rename-Item -Path $file -NewName "$($prefix[0])_$file"
    }
    Get-ChildItem | Move-Item -Destination $move_to
    $prefix.Remove($prefix_value)
    Start-Sleep -s 1
}