function mdHelpAdd {
    [CmdletBinding(DefaultParameterSetName='string')]
    param (
        # Input object for MarkDown help:
        [Parameter(Mandatory,Position=0,ParameterSetName='string')]
        $String,

        # Empty Line Add:
        [Parameter(ParameterSetName='emptyline')]
        [switch]
        $EmptyLine,

        # Code block:
        [Parameter(ParameterSetName='code')]
        [ValidateSet('default','yaml','powershell')]
        [string]
        $Code,

        # Add Examples:
        [Parameter(ParameterSetName='examples')]
        $Examples,

        # Add parameters:
        [Parameter(ParameterSetName='parameters')]
        $Parameters,

        # Add common parameters:
        [Parameter(ParameterSetName='commonparameters')]
        $CommonParameters,

        # Add links:
        [Parameter(ParameterSetName='links')]
        $Links,

        # Add syntax:
        [Parameter(ParameterSetName='syntax')]
        $Syntax,

        # Display result only, used for testing:
        [Parameter()]
        [switch]
        $Display = $False,

        # Don't trim the string:
        [Parameter(ParameterSetName='string')]
        [switch]
        $NoTrim,

        # Don't trim the string:
        [Parameter(ParameterSetName='line')]
        [switch]
        $Line,

        # Name:
        [Parameter(ParameterSetName='name')]
        [string]
        $Name
    )

    # Set my prefferences:
    if ([string]::IsNullOrEmpty($PSCmdlet.MyInvocation.BoundParameters["InformationAction"])) { $InformationPreference = 'Continue' }
    $ErrorActionPreference = 'Stop'

    # Perform action based on parameter set name:
    switch ($PSCmdlet.ParameterSetName) {
        # Write a simple string:
        'string' {
            if ($NoTrim.IsPresent) {
                $returnMe = $String
            } else {
                $returnMe = $String.Trim()
            }
            [void]$mdHelp.Add($returnMe)
            if ($Display.IsPresent) { $mdHelp }
            return
        }

        # Write a horizontal line:
        'line' {
            mdHelpAdd -EmptyLine
            $returnMe = '---'
            [void]$mdHelp.Add($returnMe)
            if ($Display.IsPresent) { $mdHelp }
            return
        }
       
        # Write an empty line:
        'emptyline' {
            $returnMe = "`r`n"
            [void]$mdHelp.Add("$returnMe")
            if ($Display.IsPresent) { $mdHelp }
            return
        }
        
        # Write the code block:
        'code' {
            switch ($Code) {
                'default' {
                    $returnMe = '```'
                    [void]$mdHelp.Add("$returnMe")
                }
                'yaml' {
                    $returnMe = '```yaml'
                    [void]$mdHelp.Add("$returnMe")
                }
                'powershell' {
                    $returnMe = '```powershell'
                    [void]$mdHelp.Add("$returnMe")
                }
            }
            if ($Display.IsPresent) { $mdHelp }
            return
        }
        
        # Write the examples:
        'examples' {
            for ($i = 0; $i -lt $Examples.example.Count; $i++) {
                mdHelpAdd -String "### $($Examples.example[$i].title.Replace('-',''))"
                mdHelpAdd -Code powershell
                mdHelpAdd -String "$($Examples.example[$i].code)"
                mdHelpAdd -Code default
                mdHelpAdd -String $(dellEmptyLines $($Examples.example[$i].remarks.text))
                mdHelpAdd -EmptyLine
            }
            if ($Display.IsPresent) { $mdHelp }
            return
        }

        # Write the parameters:
        'parameters' {
            for ($i = 0; $i -lt $Parameters.parameter.Count; $i++) {    
                mdHelpAdd -String "#### -$($Parameters.parameter[$i].name)"
                mdHelpAdd -String "$($Parameters.parameter[$i].Description.Text)"
                mdHelpAdd -Code default
                mdHelpAdd -String "Type:                        $($($helpObject.parameters.parameter[$i].type.name).Replace('System.Nullable`1',''))"
                mdHelpAdd -String "Position:                    $($Parameters.parameter[$i].position)"
                mdHelpAdd -String "Required:                    $($Parameters.parameter[$i].required)"
                mdHelpAdd -String "Default value:               $($Parameters.parameter[$i].defaultvalue)"
                mdHelpAdd -String "Accept pipeline input:       $($Parameters.parameter[$i].pipelineInput)"
                mdHelpAdd -String "Accept wildcard characters:  $($Parameters.parameter[$i].globbing)"
                mdHelpAdd -Code default
                mdHelpAdd -EmptyLine
            }
            if ($Display.IsPresent) { $mdHelp }
            return
        }

        # Write the common parameters:
        'commonparameters' {
            if ($CommonParameters -match 'This cmdlet supports the common parameters') {
                $commonParamString = 'This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).'
                mdHelpAdd -EmptyLine
                mdHelpAdd "CommonParameters"
                mdHelpAdd $commonParamString
                
            }
            if ($Display.IsPresent) { $mdHelp }
            return
        }

        # Write the links:
        'links' {
            if ($Links.navigationLink.Uri.Count -eq 0) {
                return
            } else {
                $regex = [regex] "www.*|https.*|http.*"
                $myLinks = @()
                $Links.navigationLink.Uri.ForEach({$myLinks = $myLinks+$_})
                for ($i = 0; $i -lt $myLinks.Count; $i++) {
                    $regexMatch = $regex.Match($myLinks[$i])
                    $mdLink = "{0} [{1}]()" -f $myLinks[$i].Substring(0,$regexMatch.Index),$regexMatch.Value
                    mdHelpAdd $mdLink
                }  
            }
            if ($Display.IsPresent) { $mdHelp }
            return
        }

        # Write the syntax:
        'syntax' {
            # Loop through available syntaxes:
            for ($i = 0; $i -lt $Syntax.syntaxItem.Count; $i++) {
                $syntaxArrTmp = @()
                $syntaxArrTmp += "$($Syntax.syntaxItem[0].name.Split("$pathSeparator")[-1])"

                # Loop over each parameter in syntax:
                for ($j = 0; $j -lt $Syntax.syntaxItem[$i].Parameter.Count; $j++) {
                    if ($j -eq '0') {
                            $syntaxArrTmp += "`t[[-$($Syntax.syntaxItem[$i].Parameter[$j].name)] <$($Syntax.syntaxItem[$i].Parameter[$j].parameterValue)>]"
                    } else {
                        if ($Syntax.syntaxItem[$i].Parameter[$j].parameterValue -match 'System.Nullable`1') {
                            $paramValue = ($Syntax.syntaxItem[$i].Parameter[$j].parameterValue).Replace('System.Nullable`1','')
                            if ($null -ne $paramValue) { $paramValue = $paramValue.Split('.')[-1] }
                        } else {
                            $paramValue = $($Syntax.syntaxItem[$i].Parameter[$j].parameterValue)
                            if ($null -ne $paramValue) { $paramValue = $paramValue.Split('.')[-1] }
                        }
                        $syntaxArrTmp += "`t[-$($Syntax.syntaxItem[$i].Parameter[$j].name)] <$paramValue>]"
                    }
                }

                if (($Syntax | Out-String) -match '[<CommonParameters>]') {
                    $syntaxArrTmp += "`t[<CommonParameters>]"
                }

                # Output syntax to markdown help:
                mdHelpAdd -Code powershell
                mdHelpAdd -String $syntaxArrTmp -NoTrim
                mdHelpAdd -Code default
                mdHelpAdd -EmptyLine
            }

            if ($Display.IsPresent) { $mdHelp }
            return
        }
        # Fill the command / script name:
        'name' {
            $returnMe = "# $($Name.Split("$pathSeparator")[-1].Replace('.ps1',''))"
            [void]$mdHelp.Add($returnMe)
            if ($Display.IsPresent) { $mdHelp }
            return
        }
    }
}