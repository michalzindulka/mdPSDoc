# New-mdPSDoc
Module: [mdPSDoc]()


Generates a Markdown help file.


```powershell
New-mdPSDoc
	[[-OutputLocation] <String>]
	[-OutputToHost] <>]
	[-CommandName] <String>]
	[<CommonParameters>]
```


```powershell
New-mdPSDoc
	[[-HelpObject] <Object>]
	[-OutputLocation] <String>]
	[-OutputToHost] <>]
	[<CommonParameters>]
```


```powershell
New-mdPSDoc
	[[-OutputLocation] <String>]
	[-OutputToHost] <>]
	[-File] <String>]
	[<CommonParameters>]
```


```powershell
New-mdPSDoc
	[[-OutputLocation] <String>]
	[-OutputToHost] <>]
	[-Module] <String>]
	[<CommonParameters>]
```




## DESCRIPTION
This function generates help file in Markdown format, which can be then posted on Website supporting Markdown language e.g. GitHub.


## EXAMPLES
###  EXAMPLE 1
```powershell
New-mdPSDoc -CommandName Get-Service
```
Generate Markdown help from a cmdle 'Get-Service' and save to current location.


###  EXAMPLE 2
```powershell
New-mdPSDoc -File /Users/mike/Documents/Scripts/PowerShell/Azure/Get-AzVmNetwork/Get-AzVmNetwork.ps1 -OutputLocation /Users/mike/Documents/Scripts/HelpFiles/
```
Generate Markdown help from a PowerShell script file and store to defined output location.


###  EXAMPLE 3
```powershell
New-mdPSDoc -Module mzToolkit.General
```
Generate Markdown help from each cmdlet of module and store to current location.




## PARAMETERS
#### -HelpObject
Use to generate markdown help from a help object created using Get-Help -Full cmdlet.
```
Type:                        Object
Position:                    named
Required:                    true
Default value:
Accept pipeline input:       false
Accept wildcard characters:  false
```


#### -OutputLocation
Defines the output location. If not specified, output is generated to current folder.
```
Type:                        String
Position:                    named
Required:                    false
Default value:
Accept pipeline input:       false
Accept wildcard characters:  false
```


#### -OutputToHost
Output to host only.
```
Type:                        SwitchParameter
Position:                    named
Required:                    false
Default value:               False
Accept pipeline input:       false
Accept wildcard characters:  false
```


#### -CommandName
Use to generate markdown help from a cmdlet.
```
Type:                        String
Position:                    named
Required:                    false
Default value:
Accept pipeline input:       false
Accept wildcard characters:  false
```


#### -File
Use to generate markdown help from a PowerShell script file.
```
Type:                        String
Position:                    named
Required:                    false
Default value:
Accept pipeline input:       false
Accept wildcard characters:  false
```


#### -Module
Use to generate markdown help from an entire module.
```
Type:                        String
Position:                    named
Required:                    false
Default value:
Accept pipeline input:       false
Accept wildcard characters:  false
```




## INPUTS



## OUTPUTS



## NOTES
Use with joy.


## RELATED LINKS
[https://github.com/michalzindulka/mdPSDoc]()
