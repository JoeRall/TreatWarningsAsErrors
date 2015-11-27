# Treat Warnings As Errors

[![Build status](https://ci.appveyor.com/api/projects/status/xi6w5hiocoo86c7c?svg=true)](https://ci.appveyor.com/project/JoeRall/treatwarningsaserrors) 

#### The build is failed because this project currently has warnings :smile:

AppVeyor will treat warnings as errors and fail the build with the help of this PowerShell [script](https://github.com/JoeRall/TreatWarningsAsErrors/blob/master/BuildScripts/TreatWarningsAsErrors.ps1): 

```powershell
Get-ChildItem -Recurse -Filter "*.*csproj" | % {

    $filename = $_.Fullname
    
    $proj = [xml]( Get-Content $_.Fullname )

    $xmlNameSpace = new-object System.Xml.XmlNamespaceManager($proj.NameTable)

    $xmlNameSpace.AddNamespace("p", "http://schemas.microsoft.com/developer/msbuild/2003")
    
    $nodes = $proj.SelectNodes("/p:Project/p:PropertyGroup[@Condition and not (p:TreatWarningsAsErrors)]", $xmlNameSpace)

    $touched = $false

    $nodes | ForEach-Object -Process { 
        $e = $proj.CreateElement("TreatWarningsAsErrors", "http://schemas.microsoft.com/developer/msbuild/2003")
        $e.set_InnerText("true")
        $_.AppendChild($e) | Out-Null
        $touched = $true
    }
    
    if ($touched) {
        $proj.Save("$($filename)") | Out-Null
        Write-Host $_.Name " - Warnings are now Errors"
    }
}

```

You can wire the script up inside the install build step like so: 

```yml
install:
- ps: .\BuildScripts\TreatWarningsAsErrors.ps1
```

Special thanks to [David](https://github.com/flcdrg) and [Josh](https://github.com/jquintus) for the code and inspiration.

### References
* http://david.gardiner.net.au/2011/05/turn-on-as-errors-for-all-projects-in.html
* http://blog.masterdevs.com/treat-warnings-as-errors-in-teamcity/
