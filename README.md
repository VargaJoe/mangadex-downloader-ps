# mangadex-downloader-ps

This project is inspired by [UnicodingUnicorn's mangadex-downloader](https://github.com/UnicodingUnicorn/mangadex-downloader), which was originally written in the Go programming language. However, due to changes in the MangaDex API, the tool became non-functional. After reviewing the updated API, I created this PowerShell script, which functions similarly to the previous tool.

Note: Since then, UnicodingUnicorn has also released a new version of the tool, [mangadex-downloader-2](https://github.com/UnicodingUnicorn/mangadex-downloader-2), now written in Rust.

## Mangadex-Downloader in PowerShell

This is a command-line tool designed to download entire manga series from [MangaDex](https://mangadex.org/), allowing you to read them locally using any image viewer. To use it, invoke the `get-manga.ps1` script in a PowerShell terminal and provide the manga's full URL using the `MangadexUrl` parameter.

```powershell
.\get-manga.ps1 -MangadexUrl https://mangadex.org/title/{mangaid}/{manganame}}
```

You can also specify a preferred language using the `Language` parameter if needed. 

```powershell
.\get-manga.ps1 -Language es -MangadexUrl https://mangadex.org/title/{mangaid}/{manganame}}
```

Further filtering mechanism is missing at this point...

## MangaDex API

This tool uses the MangaDex API. MangaDex is an ad-free manga reader that offers high-quality images. For more details about the API, visit [MangaDex API Documentation](https://api.mangadex.org/docs/).
