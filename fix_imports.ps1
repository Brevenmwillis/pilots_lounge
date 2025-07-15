   # Set your package name here
   $package = "pilots_lounge"

   Write-Host "Updating imports to package:$package style..."

   # Get all Dart files in lib/
   $dartFiles = Get-ChildItem -Path .\lib\ -Recurse -Filter *.dart

   foreach ($file in $dartFiles) {
       (Get-Content $file.FullName) | 
           # Models
           ForEach-Object { $_ -replace "import ['""](\.\.\/)*models\/(.*\.dart)['""]", "import 'package:$package/models/$2'" } |
           # Services
           ForEach-Object { $_ -replace "import ['""](\.\.\/)*services\/(.*\.dart)['""]", "import 'package:$package/services/$2'" } |
           # Core
           ForEach-Object { $_ -replace "import ['""](\.\.\/)*core\/(.*\.dart)['""]", "import 'package:$package/core/$2'" } |
           # Widgets
           ForEach-Object { $_ -replace "import ['""](\.\.\/)*widgets\/(.*\.dart)['""]", "import 'package:$package/widgets/$2'" } |
           # Features
           ForEach-Object { $_ -replace "import ['""](\.\.\/)*features\/(.*\.dart)['""]", "import 'package:$package/features/$2'" } |
           Set-Content $file.FullName
   }

   Write-Host "Import update complete!"