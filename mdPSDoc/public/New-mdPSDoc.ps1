<#
.SYNOPSIS
    Generates a Markdown help file.
.DESCRIPTION
    This function generates help file in Markdown format, which can be then posted on Website supporting Markdown language e.g. GitHub.
.PARAMETER HelpObject
    Use to generate markdown help from a help object created using Get-Help -Full cmdlet.
.PARAMETER OutputLocation
    Defines the output location. If not specified, output is generated to current folder.
.PARAMETER OutputToHost
    Output to host only.
.PARAMETER CommandName
    Use to generate markdown help from a cmdlet.
.PARAMETER Module
    Use to generate markdown help from an entire module.
.PARAMETER File
    Use to generate markdown help from a PowerShell script file.
.EXAMPLE
    New-mdPSDoc -CommandName Get-Service
    Generate Markdown help from a cmdle 'Get-Service' and save to current location.
.EXAMPLE
    New-mdPSDoc -File /Users/mike/Documents/Scripts/PowerShell/Azure/Get-AzVmNetwork/Get-AzVmNetwork.ps1 -OutputLocation /Users/mike/Documents/Scripts/HelpFiles/
    Generate Markdown help from a PowerShell script file and store to defined output location.
.EXAMPLE
    New-mdPSDoc -Module mzToolkit.General
    Generate Markdown help from each cmdlet of module and store to current location.
.NOTES
    Use with joy.
.LINK
    https://github.com/michalzindulka/mdPSDoc
#>
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

        # PowerShell file name:
        [Parameter(ParameterSetName='file')]
        [string]
        $File,

        # Module:
        [Parameter(ParameterSetName='module')]
        [string]
        $Module
    )

    # Set my prefferences:
    if ([string]::IsNullOrEmpty($PSCmdlet.MyInvocation.BoundParameters["InformationAction"])) {
        $InformationPreference = 'Continue'
    }
    $ErrorActionPreference = 'Stop'

    # Defines the path separator based on running OS:
    if ($IsWindows) {
        $pathSeparator = '\'
    } else {
        $pathSeparator = '/'
    }

    # Precreate an object to store output Markdown help:
    [System.Collections.ArrayList]$mdHelp = @()
    
    # Get the help object based on user input:
    switch ($PSCmdlet.ParameterSetName) {
        # Generate help object from a command:
        'command' {
            try {
                $helpObjects = Get-Command -Name $CommandName | Get-Help -Full
            }
            catch {
                throw
            }
        }
        # Generate help object from help object:
        'helpobject' {
            $helpObjects = $HelpObject
        }
        # Generate help object from a PowerShell script:
        'file' {
            if (Test-Path -Path $File) {
                $HelpObjects = Get-Help $File -Full
            } else {
                Throw 'Specified file does not exist.'
            }
        }
        # Generate help objects from a module:
        'module' {
            if ($Null -eq (Get-Module -Name $Module)) {
                Throw 'Spcecified module not found.'
            } else {
                $helpObjects = Get-Command -Module $Module | Get-Help -Full
            }
        }
    }

    # Generate markdown help for each helo object:
    foreach ($helpObject in $helpObjects) {
        mdHelpAdd -Name $helpObject.Name
        mdHelpAdd -String "Module: [$($helpObject.ModuleName)]()"
        mdHelpAdd -EmptyLine
        mdHelpAdd -String "$($helpObject.Synopsis)"
        mdHelpAdd -EmptyLine
        mdHelpAdd -Syntax $($HelpObject.syntax)
        mdHelpAdd -EmptyLine
        mdHelpAdd -String  "## DESCRIPTION"
        mdHelpAdd -String  "$($helpObject.description.Text)"
        mdHelpAdd -EmptyLine
        mdHelpAdd -String  "## EXAMPLES"
        mdHelpAdd -Examples $($helpObject.examples)
        mdHelpAdd -EmptyLine
        mdHelpAdd -String  "## PARAMETERS"
        mdHelpAdd -Parameters $($helpObject.parameters)
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
        mdHelpAdd -Links $($helpObject.relatedLinks)

        # Generate the output:
        if ($OutputToHost.IsPresent) {
            return $mdHelp   
        } elseif ($OutputLocation) {
            $helpName = ($helpObject.Name.Split("$pathSeparator")[-1]).Replace('.ps1','')
            $outputFile = "$OutputLocation$pathSeparator$helpName.md"
            $mdHelp | Out-File "$outputFile" -Force -Encoding utf8
            Write-Information "$outputFile"
        } else {
            $helpName = ($helpObject.Name.Split("$pathSeparator")[-1]).Replace('.ps1','')
            $outputFile = ".$pathSeparator$helpName.md"
            $mdHelp | Out-File "$outputFile" -Force -Encoding utf8
            Write-Information "$outputFile"
        }

        $mdHelp.Clear()
    }
}