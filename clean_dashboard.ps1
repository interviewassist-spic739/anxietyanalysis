$filePath = "lib\screens\dashboard_screen.dart"
$lines = Get-Content $filePath
# Keep lines 0..84 (indices) and 621..end  (0-indexed = line numbers 1..85 and 622..end)
$kept = $lines[0..84] + $lines[621..($lines.Length - 1)]
Set-Content $filePath $kept -Encoding UTF8
Write-Host "Done. Total lines: $($kept.Length)"
