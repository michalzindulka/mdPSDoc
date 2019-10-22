function escapeMarkDownChars {
    [CmdletBinding()]
    param (
        # Input string parameter:
        [Parameter(Mandatory,Position=0)]
        $String
    )

    # Set my prefferences:
    if ([string]::IsNullOrEmpty($PSCmdlet.MyInvocation.BoundParameters["InformationAction"])) {
        $InformationPreference = 'Continue'
    }
    $ErrorActionPreference = 'Stop'

    # Define hashtable to not replace characters over and over:
    [System.Collections.ArrayList]$blackListedChars = @()

    # Definition of markdown characters:
    $mdCharsReplacement = @{
        '`' = '\`'
        '*' = '\*'
        '{' = '\{'
        '}' = '\}'
        '[' = '\['
        ']' = '\]'
        '(' = '\('
        ')' = '\)'
        '#' = '\#'
        '+' = '\+'
        '!' = '\!'
        '<' = '\<'
        '>' = '\>'
      }

    # Replace backslash & underscore first as it was causing issues:
    $returnString = $String.Trim().TrimEnd()
    if (($returnString -match '\\') -and ('\' -notin $blackListedChars)) {
        $returnString = $returnString.Replace('\','\\')
    }
    if (($returnString -match '_') -and ('_' -notin $blackListedChars)) {
        $returnString = $returnString.Replace('_','\_')
    }
    [void]$blackListedChars.Add('_')

    # Replace the rest of characters:
    foreach ($char in $mdCharsReplacement.Keys) {
        if (($returnString -match "\$char") -and ($char -notin $blackListedChars)) {
            $returnString = $returnString.Replace($char,"$($mdCharsReplacement[$char])")
            [void]$blackListedChars.Add($char)
        }
    }

    return $returnString
}