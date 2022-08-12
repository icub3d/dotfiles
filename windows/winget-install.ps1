foreach($line in Get-Content .\winget-install.txt) {
	$count = winget list | Select-String -Pattern GIMP.GIMP | measure -Line
	$count = $count.Count -as [int]
	if ($count -eq 0 ) {
		winget install $line
	}
}
