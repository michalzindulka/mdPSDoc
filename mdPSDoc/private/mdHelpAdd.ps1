function mdHelpAdd {
    [CmdletBinding(DefaultParameterSetName='string')]
    param (
        # Input object for MarkDown help:
        [Parameter(Mandatory,Position=0,ParameterSetName='string')]
        $InputObject,

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
        $Syntax
    )

    # Set my prefferences:
    if ([string]::IsNullOrEmpty($PSCmdlet.MyInvocation.BoundParameters["InformationAction"])) {
        $InformationPreference = 'Continue'
    }
    $ErrorActionPreference = 'Stop'

    # Perform action based on parameter set name:
    switch ($PSCmdlet.ParameterSetName) {
        'string' {
            [void]$mdHelp.Add($InputObject)
            return
        }
        'emptyline' {
            [void]$mdHelp.Add("")
        }
        'code' {
            switch ($Code) {
                'default' {
                    [void]$mdHelp.Add('```')
                }
                'yaml' {
                    [void]$mdHelp.Add('```yaml')
                }
            }
            return
        }
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
            return
        }
        'parameters' {
            for ($i = 0; $i -lt $Parameters.Count; $i++) {
                $parameter = $Parameters[$i]
                [void]$mdHelp.Add("### -$($parameter.parameters.parameter.Name)")
                [void]$mdHelp.Add("$($parameter.parameters.parameter.Description.Text)")
                mdHelpAdd -EmptyLine
            }
            return
        }
        'commonparameters' {
            if ($CommonParameters -match 'This cmdlet supports the common parameters') {
                $commonParamString = 'This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).'
                mdHelpAdd -EmptyLine
                mdHelpAdd "CommonParameters"
                mdHelpAdd $commonParamString
            }
        }
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
        }
        'syntax' {
            $tmpSyntax = $Syntax | Out-String
            $tmpSyntax = $tmpSyntax.Split("`n").Where({$_ -ne ""}).Split("$($Syntax.syntaxItem.Name[0])")
            for ($i = 0; $i -lt $tmpSyntax.Count; $i++) {
                if ($tmpSyntax[$i] -eq "") {
                    # Empty string.
                } else {
                    $syntaxOut = "{0} {1}" -f $($Syntax.syntaxItem.Name[0]),$tmpSyntax[$i]
                    mdHelpAdd $syntaxOut
                    mdHelpAdd -EmptyLine
                }
            }
        }
    }
}