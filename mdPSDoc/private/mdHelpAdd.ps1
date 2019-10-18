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
        $Display=$false,

        # Don't trim the string:
        [Parameter(ParameterSetName='string')]
        [switch]
        $NoTrim,

        # Don't trim the string:
        [Parameter(ParameterSetName='line')]
        [switch]
        $Line
    )

    # Set my prefferences:
    if ([string]::IsNullOrEmpty($PSCmdlet.MyInvocation.BoundParameters["InformationAction"])) {
        $InformationPreference = 'Continue'
    }
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
                mdHelpAdd -String $(Remove-EmptyLines $($Examples.example[$i].remarks.text))
                mdHelpAdd -EmptyLine
            }
            return
        }

        # Write the parameters:
        'parameters' {
            for ($i = 0; $i -lt $Parameters.parameter.Count; $i++) {    
                mdHelpAdd -String "#### -$($Parameters.parameter[$i].name)"
                mdHelpAdd -String "$($Parameters.parameter[$i].Description.Text)"
                mdHelpAdd -Code default
                mdHelpAdd -String "Type:                        $($Parameters.parameter[$i].type.name)"
                mdHelpAdd -String "Position:                    $($Parameters.parameter[$i].position)"
                mdHelpAdd -String "Default value:               $($Parameters.parameter[$i].defaultvalue)"
                mdHelpAdd -String "Accept pipeline inpit:       $($Parameters.parameter[$i].position)"
                mdHelpAdd -String "Accept wildcard characters:  $($Parameters.parameter[$i].position)"
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
                $syntaxArrTmp += "$($Syntax.syntaxItem[$i].name)"

                # Loop over each parameter in syntax:
                for ($j = 0; $j -lt $Syntax.syntaxItem[$i].Parameter.Count; $j++) {
                    if ($j -eq '0') {
                            $syntaxArrTmp += "`t[[-$($Syntax.syntaxItem[$i].Parameter[$j].name)] <$($Syntax.syntaxItem[$i].Parameter[$j].parameterValue)>]"
                    } else {
                            $syntaxArrTmp += "`t[-$($Syntax.syntaxItem[$i].Parameter[$j].name)] <$($Syntax.syntaxItem[$i].Parameter[$j].parameterValue)>]"
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
    }
}