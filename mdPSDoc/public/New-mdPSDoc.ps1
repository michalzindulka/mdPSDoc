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
            $helpName = ($helpObject.Name.Split('/')[-1]).Replace('.ps1','')
            $outputFile = "$OutputLocation/$helpName.md"
            $mdHelp | Out-File "$outputFile" -Force -Encoding utf8
            Write-Information "$outputFile"
        } else {
            $helpName = ($helpObject.Name.Split('/')[-1]).Replace('.ps1','')
            $outputFile = "./$helpName.md"
            $mdHelp | Out-File "$outputFile" -Force -Encoding utf8
            Write-Information "$outputFile"
        }

        $mdHelp.Clear()
    }
}