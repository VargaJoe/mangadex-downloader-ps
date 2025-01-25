Param (
	# Full URL of the manga on Mangadex
	[Parameter(Mandatory=$False)]
	[string]$MangadexUrl,

	# ID and Title of the manga on Mangadex
	[Parameter(Mandatory=$False)]
	[string]$MangaId,
	[Parameter(Mandatory=$False)]
	[string]$MangaName="$($MangaId)",

	# Crawler parameters
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

	# Technical parameters
	[Parameter(Mandatory=$False)]
	[string]$TargetFolder="./Output",
	[Parameter(Mandatory=$False)]
	[switch]$DryRun
)


# pagination is missing

# Get cover image
if ($true -or $getCover) {
	$scriptParams = @{
		MangadexUrl = $MangadexUrl
		MangaId = $MangaId
		MangaName = $MangaName
		TargetFolder = $TargetFolder
		DryRun = $DryRun
	}

	$returnedValues = .\get-cover.ps1 @scriptParams

	$MangaName = $returnedValues.MangaName
	$MangaId = $returnedValues.MangaId
	$CombinedTargetFolder = $returnedValues.CombinedTargetFolder
}

if ($MangadexUrl -and -not $MangaName) {
	# mangainfo should be used instead of this
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

if (-not $CombinedTargetFolder) {
	$MangaName = $MangaName.Replace("/", "-")
	$MangaName = $MangaName.Replace(":", "")
	$MangaName = $MangaName.Replace("?", "")
	$MangaName = $MangaName.Replace("[", "(")
	$MangaName = $MangaName.Replace("]", ")")
	$MangaName = $MangaName -replace '\s+', ' '
	$CombinedTargetFolder="$($TargetFolder)/$($MangaName)"
}

if (-not(Test-Path $CombinedTargetFolder)) {
	New-Item -Path $CombinedTargetFolder -ItemType Directory
}

$page = 1
$limit = 100
$total = $limit # just to start the loop
$offset = 0

do {
	$MangaFeedJsonName = "$($CombinedTargetFolder)/manga-feed-$($MangaId)-($($Language))-($($page)).json"
	write-host "$MangaName feed json: $MangaFeedJsonName"

	if (Test-Path $MangaFeedJsonName) {
		write-host "manga feed json file already exists, we will use that"
		$response = Get-Content $MangaFeedJsonName | ConvertFrom-Json
	} else {
		write-host "manga feed json file does not exists, we will get from site"
		$urlPath="manga/$($MangaId)/feed?limit=$($limit)&translatedLanguage[]=$($Language)&includes[]=scanlation_group&includes[]=user&order[volume]=asc&order[chapter]=asc&offset=$($offset)&contentRating[]=safe&contentRating[]=suggestive&contentRating[]=erotica&contentRating[]=pornographic"
		$RequestUrl="https://api.mangadex.org/$($urlPath)"

		try
		{
			$response = Invoke-RestMethod -UseBasicParsing -Uri $($RequestUrl) 
			write-host "OK"
		}
		catch
		{
			$StatusCode = $_.Exception.Response.StatusCode.value__
			write-host "Error"
		}

		write-host $StatusCode

		$response | ConvertTo-Json -depth 100 | Out-File $MangaFeedJsonName
	}
	$total= $response.total

	write-host "foreach on data"
	foreach($item in $response.data) {
		if ($Language -eq "" -or $Language -eq $item.attributes.translatedLanguage) {
			$chapterid = $item.id
			$chapterTitle = $item.attributes.title
			$group = $item.relationships[0]
			$groupName = "unknown"
			if ($group.type -eq "scanlation_group") {
				$groupName = $group.attributes.name
			}
					
			$volNum = [int]$item.attributes.volume
			$volStr = "{0:$VolFormat}" -f $volNum
			
			$chapNum = [int]$item.attributes.chapter
			$chapStr = "{0:$ChapFormat}" -f $chapNum
			
			# hagyd ki ha
			# ha volfrom meg van adva chapfromot leszarom és a volnum kisebb, mint a volfrom
			# ha a volfrom nincs megadva, chapfrom megvan adva volnum vagy null vagy 0 vagy 1 (de a három közül csak az elsőre kellene működnie) és chapnum kisebb, mint a chapfrom 
				# (első találatkor be kellene állítani, melyik opció a három közül?)
				# (VAGY ez csak az első kötetre érvényes és ha van korábbi null vagy 0 kötet, akkor abból mindent leszedek VAGY ugyanez de ezekből semmit nem szedek le)
				# # (utóbbi lehet az alap és egy plusz kapcsoló, hogy kellenek-e az extra kötetek 0/null vagy sem)
			# ha a volfrom meg van adva és a chapfrom is meg van adva, a volnum megegyezik a volfrommal és chapnum kisebb, mint a chapfrom
			# if (
				# (
					# $VolFrom 
					# -and 
					# (
						# $volNum -lt $VolFrom 
						# -or 
						# (
							# $ChapFrom 
							# -and 
							# ($VolNum -eq $VolFrom -and $chapNum -lt $ChapFrom)
							# -and 
						# )
					# )
				# ) 
				# -or
				# (
					# $VolTo 
					# -and 
					# (
						# $VolTo -gt $volNum
						# -or 
						# (
							# $ChapTo
							# -and 
							# $ChapTo -gt $chapNum
						# )
					# )
				# )
			# ) {
				# continue
			# }
			
			$chapterTitlePart = if ($chapterTitle) { " - $chapterTitle" } else { "" }
			$chapterTargetName = "$($MangaName) v$($volStr)c$($chapStr)$($chapterTitlePart) ($($groupName))"
			$chapterTargetName = $chapterTargetName.Replace("/", "-")
			$chapterTargetName = $chapterTargetName.Replace(":", "")
			$chapterTargetName = $chapterTargetName.Replace("?", "")
			$chapterTargetName = $chapterTargetName.Replace("[", "(")
			$chapterTargetName = $chapterTargetName.Replace("]", ")")
			$chapterTargetName = $chapterTargetName -replace '\s+', ' '
			
			write-host ""
			write-host "-------------------------------------------------------------------------------------"
			write-host "$($item.type) `t $($item.attributes.translatedLanguage) `t $($item.attributes.volume)/$($item.attributes.chapter) `t $($item.attributes.title)"
			write-host "-------------------------------------------------------------------------------------"
			# write-host "$item.attributes.pages"
			# write-host "$item.attributes.version"
			
			# write exception to file
			
			if ($item.type -eq "chapter") {
				write-host "call chapter downloader"
				# TODO: add manga name + target folder OR chaptername ????
				$npcReaderTime = Get-Random -Minimum 10 -Maximum 20
				$skip = (./get-chapter.ps1 -ChapterId $($chapterid) -DryRun $DryRun -ChapterName $chapterTargetName -TargetFolder $CombinedTargetFolder)
				
				if ($skip -eq $true) {
					write-output "no download happened, no wait time needed"
					$npcReaderTime = 1
				}
				
				# if no download has been made sleep time should be lower or zero
				write-host "Wait for it! ($npcReaderTime)"
				Start-Sleep -Seconds $npcReaderTime
			}
		}
	}

	$page++	
	$offset += $limit
	write-host "page: $page - offset: $offset - total: $total"
} until ($page * $offset -ge $total)
