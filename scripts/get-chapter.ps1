Param (
    [Parameter(Mandatory=$False)]
	[string]$ChapterId="6b2f92fa-7869-4f83-9353-a8c867f851dc",
	[Parameter(Mandatory=$False)]
	[bool]$DryRun=$False,
	[Parameter(Mandatory=$False)]
	[string]$ChapterName="$($ChapterId)",
	[Parameter(Mandatory=$False)]
	[string]$TargetFolder="./Output"
)

$CombinedTargetFolder="$($TargetFolder)/$($ChapterName)"
$CombinedTargetFolder = $CombinedTargetFolder.Replace("[", "(")
$CombinedTargetFolder = $CombinedTargetFolder.Replace("]", ")")
$CombinedTargetFolder = $CombinedTargetFolder.Replace("?", "")
$CombinedTargetFolder = $CombinedTargetFolder.Replace(":", "")
$CombinedTargetFolder = $CombinedTargetFolder -replace '\s+', ' '
if (-not(Test-Path $CombinedTargetFolder)) {
	New-Item -Path $CombinedTargetFolder -ItemType Directory
}

# $CurrentDateTime = "" #Get-Date -format "-yyyy-MM-dd-HH-mm-ss"
# $ChapterLogName = "./manga-$($ChapterId)$($CurrentDateTime).log"
$ChapterJsonName = "$($CombinedTargetFolder)/manga-$($ChapterId).json"

write-host $ChapterJsonName

if (Test-Path $ChapterJsonName) {
	write-host "chapter json file already exists, we will use that"
	$response = Get-Content $ChapterJsonName | ConvertFrom-Json
} else {
	write-host "chapter json file does not exists, we will get from site"
	$urlPath="at-home/server/$($ChapterId)?forcePort443=false"
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
	$response | ConvertTo-Json -depth 100 | Out-File $ChapterJsonName
}

$hash = $response.chapter.hash
$skip = $true

write-host "foreach on data"
foreach($item in $response.chapter.data) {
	$dataPath = "data/$($hash)/$($item)"
	$downloadUrl = "https://uploads.mangadex.org/$($dataPath)"
	$index = $response.chapter.data.IndexOf($item)
	$extension = ($item).Split(".")[-1]
	$targetPath = "$($CombinedTargetFolder)/$(($index + 1).toString('00')).$($extension)"

	# if download file already exists, do not download it again (maybe except with force settings)
	# download file name with double digit 
	# e.g. "a9-10f64165762e13e157afa483b98d334895d1df3e49d6485c9ac4c0f084f01ffd.jpg" -> a09
	
	if ($DryRun) {
		write-host "Test OK - $($downloadUrl)"
	} elseif (Test-Path -Path $targetPath) {
		write-host "File already exists $($targetPath)"
		# here should be a force logic if turned on
	} else {
		$skip = $false
		write-host "Download $($downloadUrl) to $($targetPath)"
		Invoke-WebRequest -UseBasicParsing -Uri $($downloadUrl) `
			-OutFile $targetPath `
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

return $skip
