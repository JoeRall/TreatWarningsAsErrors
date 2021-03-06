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
