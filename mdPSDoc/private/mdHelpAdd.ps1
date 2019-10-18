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
        [ValidateSet('default','yaml')]
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
        $Display=$false
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
            $returnMe = $String.Trim()
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
            }
            if ($Display.IsPresent) { $mdHelp }
            return
        }
        
        # Write the examples:
        'examples' {
            for ($i = 0; $i -lt $Examples.Count; $i++) {
                $example = $Examples[$i]
                [void]$mdHelp.Add("### $($Example.Title)")
                mdHelpAdd -Code default
                [void]$mdHelp.Add($example.Code)
                mdHelpAdd -Code default
                mdHelpAdd -EmptyLine
                mdHelpAdd $(Remove-EmptyLines -String $helpObject.examples.example[$i].remarks.Text)
                mdHelpAdd -EmptyLine
            }
            if ($Display.IsPresent) { $mdHelp }
            return
        }

        # Write the parameters:
        'parameters' {
            for ($i = 0; $i -lt $Parameters.Count; $i++) {
                $parameter = $Parameters[$i]
                [void]$mdHelp.Add("### -$($parameter.parameters.parameter.Name)")
                [void]$mdHelp.Add("$($parameter.parameters.parameter.Description.Text)")
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
            $syntaxArr = @()
            for ($i = 0; $i -lt $Syntax.syntaxItem.Count; $i++) {
                $syntaxArrTmp = @()
                $syntaxArrTmp += "$($Syntax.syntaxItem[$i].name) ["
                
                # Loop over each parameter in syntax:
                for ($j = 0; $j -lt $Syntax.syntaxItem[$i].Parameter.Count; $j++) {
                    $syntaxArrTmp += "[-$($Syntax.syntaxItem[$i].Parameter[$j].name)] <$($Syntax.syntaxItem[$i].Parameter[$j].parameterValue)>]"
                    if (($Syntax | Out-String) -match '[<CommonParameters>]') {
                        $syntaxArrTmp += "[<CommonParameters>]"
                    }
                }

                # Put everything in array & put into markdown help:
                $syntaxArr += $($syntaxArrTmp -join "")
                foreach ($syntaxLine in $syntaxArr) {
                    mdHelpAdd -Code default
                    mdHelpAdd -String $($syntaxArrTmp -join "")
                    mdHelpAdd -Code default
                    mdHelpAdd -EmptyLine
                }
            }
            if ($Display.IsPresent) { $mdHelp }
            return
        }
    }
}