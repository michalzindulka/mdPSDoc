function dellEmptyLines {
    [CmdletBinding()]
    param (
        # Input string:
        [Parameter(Mandatory)]
        $String
    )

    # Set my prefferences:
    if ([string]::IsNullOrEmpty($PSCmdlet.MyInvocation.BoundParameters["InformationAction"])) {
        $InformationPreference = 'Continue'
    }
    $ErrorActionPreference = 'Stop'

    # Remove empty lines from string:
    try {
        $returnString = [string]::new($($String.Split("\n").Where({$_ -ne ""})))
    }
    catch {
        $returnString = 'ERROR: UNABLE TO PARSE'
    }

    return $returnString
}