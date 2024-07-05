Param (
	[Parameter(Mandatory=$False)]
	[string]$MangadexUrl,
    [Parameter(Mandatory=$False)]
	[string]$MangaId,
	
	[Parameter(Mandatory=$False)]
	[string]$MangaName="$($MangaId)",
	[Parameter(Mandatory=$False)]
	[string]$Language="en",	
	[Parameter(Mandatory=$False)]
	[int]$VolFrom,
	[Parameter(Mandatory=$False)]
	[int]$ChapFrom,
	[Parameter(Mandatory=$False)]
	[int]$VolTo,
	[Parameter(Mandatory=$False)]
	[int]$ChapTo,
	[Parameter(Mandatory=$False)]
	[string]$VolFormat="d2",
	[Parameter(Mandatory=$False)]
	[string]$ChapFormat="d2",
	[Parameter(Mandatory=$False)]
	[string]$TargetFolder="./Output",
	[Parameter(Mandatory=$False)]
	[bool]$DryRun=$False
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

if (-not(Test-Path $TargetFolder)) {
	New-Item -Path $TargetFolder -ItemType Directory
}

$MangaJsonName = "$($TargetFolder)/manga-$($MangaId)-($($Language))-base.json"

write-host $MangaJsonName

if (Test-Path $MangaJsonName) {
	write-host "manga base json file already exists, we will use that"
	$response = Get-Content $MangaJsonName | ConvertFrom-Json
} else {
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

	$response | ConvertTo-Json -depth 100 | Out-File $MangaJsonName
} 

$MangaName = $response.data.attributes.title.en
$CombinedTargetFolder="$($TargetFolder)/$($MangaName)"
$CombinedTargetFolder = $CombinedTargetFolder.Replace("[", "(")
$CombinedTargetFolder = $CombinedTargetFolder.Replace("]", ")")
$CombinedTargetFolder = $CombinedTargetFolder.Replace(":", "")
$mangaCover = ""

if (-not(Test-Path $CombinedTargetFolder)) {
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

.\get-manga.ps1 -MangaId $MangaId -MangaName $MangaName -Language $Language -VolFrom $VolFrom -ChapFrom $ChapFrom -VolTo $VolTo -ChapTo $ChapTo -VolFormat $VolFormat -ChapFormat $ChapFormat -TargetFolder $TargetFolder -DryRun $DryRun

