# mangadex-downloader-ps

This project is inspired by [UnicodingUnicorn
mangadex-downloader](https://github.com/UnicodingUnicorn/mangadex-downloader), which was written in Go language. But at one point mangadex api has changed and it was no longer functional. I've looked up the new api and összedobtam ezt a kis powershell scriptet, ami a korábbi tool-hoz hasonlóan működik. 
Note: Időközben UnicodingUnicorn is felkerült egy új verzió [mangadex-downloader-2](https://github.com/UnicodingUnicorn/mangadex-downloader-2), ezúttal Rust nyelvben programozva.

## Mangadex-Downloader in PowerShell

Ez egy command line tool, amivel teljes mangákat lehet letölteni a [MangaDex](https://mangadex.org/) oldaláról, így saját gépen szimpla képnézegető programmal olvashatjuk azokat. Használatához meg kell hívni powershell ablakban a `get-manga.ps1` scriptet és `MangadexUrl` paraméterben át kell adni a teljes url-t. 

```powershell
.\get-manga.ps1 -MangadexUrl https://mangadex.org/title/{mangaid}/{manganame}}
```

Ebben az esetben a teljes manga letöltésre kerül angol nyelven. Más nyelv választása a `Language` paraméterrel lehetséges. Például spanyol nyelv választásához:

```powershell
.\get-manga.ps1 -Language es -MangadexUrl https://mangadex.org/title/{mangaid}/{manganame}}
```

## MangaDex API

This tool uses MangaDex API. MangaDex is an ad-free manga reader offering high-quality images.
https://api.mangadex.org/docs/