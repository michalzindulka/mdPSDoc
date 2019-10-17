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
    mdHelpAdd "# $($helpObject.Name)"
    mdHelpAdd -EmptyLine
    mdHelpAdd "## SYNOPSIS"
    mdHelpAdd "$($helpObject.Synopsis)"
    mdHelpAdd -EmptyLine
    mdHelpAdd "## SYNTAX"
    mdHelpAdd -Code default
    mdHelpAdd -Syntax $HelpObject.syntax
    mdHelpAdd -Code default
    mdHelpAdd -EmptyLine
    mdHelpAdd "## DESCRIPTION"
    mdHelpAdd "$($helpObject.description.Text)"
    mdHelpAdd -EmptyLine
    mdHelpAdd "## EXAMPLES"
    mdHelpAdd -EmptyLine
    mdHelpAdd -Examples $helpObject.examples.example
    mdHelpAdd -EmptyLine
    mdHelpAdd "## PARAMETERS"
    mdHelpAdd -EmptyLine
    mdHelpAdd $(EscapeMarkDownChars $($HelpObject.parameters.parameter | Out-String))
    mdHelpAdd -CommonParameters $($HelpObject.parameters | Out-String)
    mdHelpAdd -EmptyLine
    mdHelpAdd "## INPUTS"
    mdHelpAdd "$($helpObject.inputTypes.inputType.type.name)"
    mdHelpAdd -EmptyLine
    mdHelpAdd "## OUTPUTS"
    mdHelpAdd "$($helpObject.returnValues.returnValue.type.name)"
    mdHelpAdd -EmptyLine
    mdHelpAdd "## NOTES"
    mdHelpAdd "$($helpObject.alertSet.alert.Text)"
    mdHelpAdd -EmptyLine
    mdHelpAdd "## RELATED LINKS"
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