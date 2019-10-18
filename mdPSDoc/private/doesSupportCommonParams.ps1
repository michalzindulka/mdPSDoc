function doesSupportCommonParams {
    [CmdletBinding()]
    param (
        
    )

    $CommonParameters -match 'This cmdlet supports the common parameters'
    $($HelpObject.parameters | Out-String)
}