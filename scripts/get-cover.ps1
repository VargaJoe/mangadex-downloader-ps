Param (
	# Full URL of the manga on Mangadex
	[Parameter(Mandatory=$False)]
	[string]$MangadexUrl,

	# ID and Title of the manga on Mangadex
	[Parameter(Mandatory=$False)]
	[string]$MangaId,
	[Parameter(Mandatory=$False)]
	[string]$MangaName="$($MangaId)",

	# Technical parameters
	[Parameter(Mandatory=$False)]
	[string]$TargetFolder="./Output",
	[Parameter(Mandatory=$False)]
	[bool]$SaveInfo = $True,
	[Parameter(Mandatory=$False)]
	[switch]$DryRun
)

# pagination is missing

if ($MangadexUrl) {
	$elements = $MangadexUrl.Split("/")
	if ($elements[2] -eq "mangadex.org" -and $elements[3] -eq "title") {
		write-output "Splitting url. Seems OK!"
	}
	
	if ($elements[4]) {
		$MangaId = $elements[4]
		write-output "MangaId set to $MangaId"
	} else {
		write-output "MangaId missing"
	}
	
	if ($elements[5]) {
		$MangaName = $elements[5]
		write-output "MangaName set to $MangaName"
	}
}


$InfoFolder = "./info"
$MangaInfoJsonName = "$($InfoFolder)/manga-info-$($MangaId)-$($MangaName).json"

write-host "$MangaName base info json: $MangaInfoJsonName"

if (Test-Path $MangaInfoJsonName) {
	write-host "manga base json file already exists, we will use that"
	$response = Get-Content $MangaInfoJsonName | ConvertFrom-Json
} else {
	if (-not (Test-Path $InfoFolder)) {
		write-host "Creating $($InfoFolder) folder"
		New-Item -Path $InfoFolder -ItemType Directory
	}

	write-host "manga base json file does not exists, we will get from site"
	$urlPath="manga/$($MangaId)?includes[]=artist&includes[]=author&includes[]=cover_art"
	$RequestUrl="https://api.mangadex.org/$($urlPath)"

	$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
	$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.74 Safari/537.36"
	try
	{
		$response = Invoke-RestMethod -UseBasicParsing -Uri $($RequestUrl) `
			-WebSession $session `
			-Headers @{
				"method"="GET"
				"authority"="api.mangadex.org"
				"scheme"="https"
				"path"="/$($urlPath)"
				"sec-ch-ua"="`" Not A;Brand`";v=`"99`", `"Chromium`";v=`"99`", `"Google Chrome`";v=`"99`""
				"accept"="application/json, text/plain, */*"
				"sec-ch-ua-mobile"="?0"
				"sec-ch-ua-platform"="`"Windows`""
				"origin"="https://mangadex.org"
				"sec-fetch-site"="same-site"
				"sec-fetch-mode"="cors"
				"sec-fetch-dest"="empty"
				"referer"="https://mangadex.org/"
				"accept-encoding"="gzip, deflate, br"
				"accept-language"="en-US,en;q=0.9,hu-HU;q=0.8,hu;q=0.7"
			}
		write-host "OK"
	}
	catch
	{
		$StatusCode = $_.Exception.Response.StatusCode.value__
		write-host "Error"
	}

	write-host $StatusCode

	if ($SaveInfo) {
		$response | ConvertTo-Json -depth 100 | Out-File $MangaInfoJsonName
	}
} 

$mangaCover = ""
$MangaName = $response.data.attributes.title.en
$CombinedTargetFolder="$($TargetFolder)/$($MangaName)"
$CombinedTargetFolder = $CombinedTargetFolder.Replace("[", "(")
$CombinedTargetFolder = $CombinedTargetFolder.Replace("]", ")")
$CombinedTargetFolder = $CombinedTargetFolder.Replace("?", "")
$CombinedTargetFolder = $CombinedTargetFolder -replace '\s+', ' '

if (-not(Test-Path $CombinedTargetFolder)) {
	write-host "Creating $($CombinedTargetFolder) folder"
	New-Item -Path $CombinedTargetFolder -ItemType Directory
}

write-host "foreach on relationships to retrieve cover"
foreach($item in $response.data.relationships) {
	if ($item.type -eq "cover_art") {
		$mangaCover = $item.attributes.fileName
		$mangaCoverExt = ($mangaCover).Split(".")[-1]
		
		$coverUrl = "https://mangadex.org/covers/$($MangaId)/$($mangaCover)"
		write-output "cover url is $coverUrl"

		$coverTargetName = "$($MangaName) (cover).$($mangaCoverExt)"	
		$coverTargetName = $coverTargetName.Replace("/", "-")
		$coverTargetName = $coverTargetName.Replace("[", "(")
		$coverTargetName = $coverTargetName.Replace("]", ")")
		$coverTargetName = $coverTargetName.Replace(":", "")
		$coverTargetPath = "$($CombinedTargetFolder)/$($coverTargetName)"	
		
		if ($DryRun) {
			write-host "Test OK - $($coverUrl)"
		} elseif (Test-Path -Path $coverTargetPath) {
			write-host "File already exists $($coverTargetPath)"
			# here should be a force logic if turned on
		} else {	
			write-host "Download $($coverUrl) to $($coverTargetPath)"			
			Invoke-WebRequest -UseBasicParsing -Uri $($coverUrl) `
				-OutFile $coverTargetPath `
				-WebSession $session `
				-Headers @{
					"method"="GET"
					"authority"="api.mangadex.org"
					"scheme"="https"
					"path"="/$($dataPath)"
					"sec-ch-ua"="`" Not A;Brand`";v=`"99`", `"Chromium`";v=`"99`", `"Google Chrome`";v=`"99`""
					"accept"="application/json, text/plain, */*"
					"sec-ch-ua-mobile"="?0"
					"sec-ch-ua-platform"="`"Windows`""
					"origin"="https://mangadex.org"
					"sec-fetch-site"="same-site"
					"sec-fetch-mode"="cors"
					"sec-fetch-dest"="empty"
					"referer"="https://mangadex.org/"
					"accept-encoding"="gzip, deflate, br"
					"accept-language"="en-US,en;q=0.9,hu-HU;q=0.8,hu;q=0.7"
				}
		}		
	}
}

return @{
    MangaId = $MangaId
    MangaName = $MangaName
    CombinedTargetFolder = $CombinedTargetFolder
}