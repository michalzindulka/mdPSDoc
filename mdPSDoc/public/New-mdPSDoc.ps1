
function gt {
    [CmdletBinding()]
    param (
        # InputObject
        [Parameter(Mandatory,ValueFromPipeline)]
        $InputObject
    )

    ($InputObject).GetType()
}

function New-mdPSDoc {
    [CmdletBinding(DefaultParameterSetName='command')]
    param (
        # Input Help Object:
        [Parameter(Mandatory,ParameterSetName='helpobject')]
        $HelpObject,

        # Output location of Markdown help:
        [Parameter()]
        [string]
        $OutputLocation,

        # Output the markdown help to host:
        [Parameter()]
        [switch]
        $OutputToHost,

        # Command Name from which to create markdown help:
        [Parameter(ParameterSetName='command')]
        [string]
        $CommandName
    )

    # Set my prefferences:
    if ([string]::IsNullOrEmpty($PSCmdlet.MyInvocation.BoundParameters["InformationAction"])) {
        $InformationPreference = 'Continue'
    }
    $ErrorActionPreference = 'Stop'

    # Precreate an object to store output Markdown help:
    [System.Collections.ArrayList]$mdHelp = @()
    
    # Get the help object based on user input:
    switch ($PSCmdlet.ParameterSetName) {
        'command' {
            try {
                $helpObject = Get-Command -Name $CommandName | Get-Help -Full
            }
            catch {
                throw
            }
        }
        'helpobject' {
            $helpObject = $HelpObject
        }
    }

    # Construct the Markdown help object:
    mdHelpAdd -String "# $($helpObject.Name)"
    mdHelpAdd -EmptyLine
    mdHelpAdd -String "## SYNOPSIS"
    mdHelpAdd "$($helpObject.Synopsis)"
    mdHelpAdd -EmptyLine
    mdHelpAdd -String  "## SYNTAX"
    mdHelpAdd -Syntax $($HelpObject.syntax)
    mdHelpAdd -EmptyLine
    mdHelpAdd -String  "## DESCRIPTION"
    mdHelpAdd -String  "$($helpObject.description.Text)"
    mdHelpAdd -EmptyLine
    mdHelpAdd -String  "## EXAMPLES"
    mdHelpAdd -EmptyLine
    mdHelpAdd -Examples $helpObject.examples.example
    mdHelpAdd -EmptyLine
    mdHelpAdd -String  "## PARAMETERS"
    mdHelpAdd -EmptyLine
    mdHelpAdd $(EscapeMarkDownChars $($HelpObject.parameters.parameter | Out-String))
    mdHelpAdd -CommonParameters $($HelpObject.parameters | Out-String)
    mdHelpAdd -EmptyLine
    mdHelpAdd -String  "## INPUTS"
    mdHelpAdd -String  "$($helpObject.inputTypes.inputType.type.name)"
    mdHelpAdd -EmptyLine
    mdHelpAdd -String  "## OUTPUTS"
    mdHelpAdd -String  "$($helpObject.returnValues.returnValue.type.name)"
    mdHelpAdd -EmptyLine
    mdHelpAdd -String  "## NOTES"
    mdHelpAdd -String  "$($helpObject.alertSet.alert.Text)"
    mdHelpAdd -EmptyLine
    mdHelpAdd -String  "## RELATED LINKS"
    mdHelpAdd -Links $helpObject.relatedLinks

    if ($OutputToHost.IsPresent) {
        return $mdHelp   
    } elseif ($OutputLocation) {
        $outputFile = "$OutputLocation/$($helpObject.Name).md"
        $mdHelp | Out-File "$outputFile" -Force -Encoding utf8
        Write-Information "$outputFile"
    } else {
        $outputFile = "./$($helpObject.Name).md"
        $mdHelp | Out-File "$outputFile" -Force -Encoding utf8
        Write-Information "$outputFile"
    }
}



$helpObject = Get-Command Get-AzStorageBlob | Get-Help -Full
New-mdPSDoc -HelpObject $helpObject -OutputToHost | pbcopy

#[System.Collections.ArrayList]$mdHelp = @()
#mdHelpAdd -Syntax $helpObject.syntax -Display