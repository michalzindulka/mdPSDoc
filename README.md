# mdPSDoc

##  About
mdPSDoc is a customisable generator of a PowerShell documentation in a [Markdown][1] format from a [PowerShell Comment Based Help][2]. The default format of generated documentation is similar to the style which Microsoft uses on their online help for PowerShell, but it can be simply customised for your needs. Markdown format is supported by variety of platforms such as GitHub or Azure DevOps. mdPSDoc is shipped in a PowerShell module.

## Why to use mdPSDoc ?

 - Easy generation of online help from PowerShell scripts.
 - The style is customizable.
 - Can be easily integrated with automation.

## Installation
- Clone the repo & Import the module to PowerShell.

## Usage
For Examples & More details check PowerShell comment based help of mdPSDoc or the [New-mdPSDoc][3] example, which was generated using mdPSDoc.

## Modification of style
Output style can be modified with little bit of PowerShell knowledge, go and check the 'New-mdPSDoc.ps1' script in public folder. The Markdown file generator itself is on lines 114 - 142. You can modify the order, comment or add more lines as you need. The 'mdHelpAdd' function accepts many arguments, check the functions itself for more details.

[1]: http://en.wikipedia.org/wiki/Markdown
[2]: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-6
[3]:https://github.com/michalzindulka/mdPSDoc/blob/master/Examples/New-mdPSDoc.md
