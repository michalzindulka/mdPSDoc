function Set-NewLine {
    [CmdletBinding()]
    param (
        # Input string:
        [Parameter(Mandatory)]
        $String
    )

    [System.Collections.ArrayList]$returnColl = @()
    $String | ForEach-Object {
        if ($_ -eq '') {
            [void]$returnColl.Add('<br>')
        } else {
            [void]$returnColl.Add($_)
        }
    }

    return $returnColl
}