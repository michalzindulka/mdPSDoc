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
        $CommandName,

        # Help style:
        [Parameter()]
        [ValidateSet('classic','microsoft','new')]
        [string]
        $Style = 'new'
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

    # Generate markdown help::
    mdHelpAdd -String "# $($helpObject.Name)"
    mdHelpAdd -String "Module: [$($helpObject.ModuleName)]()"
    mdHelpAdd -EmptyLine
    mdHelpAdd -String "$($helpObject.Synopsis)"
    mdHelpAdd -EmptyLine
    mdHelpAdd -Syntax "$($HelpObject.syntax)"
    mdHelpAdd -EmptyLine
    mdHelpAdd -String  "## DESCRIPTION"
    mdHelpAdd -String  "$($helpObject.description.Text)"
    mdHelpAdd -EmptyLine
    mdHelpAdd -String  "## EXAMPLES"
    mdHelpAdd -Examples "$($helpObject.examples)"
    mdHelpAdd -EmptyLine
    mdHelpAdd -String  "## PARAMETERS"
    mdHelpAdd -Parameters "$($helpObject.parameters)"
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
    mdHelpAdd -Links "$($helpObject.relatedLinks)"

    # Generate the output:
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