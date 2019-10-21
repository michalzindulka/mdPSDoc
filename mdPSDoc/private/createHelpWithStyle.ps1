function createHelpWithStyle {
    [CmdletBinding()]
    param (
        # Style name:
        [Parameter(Mandatory)]
        [string]
        $Style
    )

    switch ($Style) {
        'new' {
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
        }
        'microsoft' {
            mdHelpAdd -String "# $($helpObject.Name)"
            mdHelpAdd -String "Module: [$($helpObject.ModuleName)]()"
            mdHelpAdd -EmptyLine
            mdHelpAdd -String "$($helpObject.Synopsis)"
            mdHelpAdd -EmptyLine
            mdHelpAdd -Syntax $($HelpObject.syntax) -Style microsoft
            mdHelpAdd -EmptyLine
            mdHelpAdd -String  "## DESCRIPTION"
            mdHelpAdd -String  "$($helpObject.description.Text)"
            mdHelpAdd -EmptyLine
            mdHelpAdd -String  "## EXAMPLES"
            mdHelpAdd -Examples $($helpObject.examples)
            mdHelpAdd -EmptyLine
            mdHelpAdd -String  "## PARAMETERS"
            mdHelpAdd -Parameters $($helpObject.parameters) -Style microsoft
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

        }
    }
}