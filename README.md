# mangadex-downloader-ps

A PowerShell-based command-line tool for downloading manga from [MangaDex](https://mangadex.org/).

This project is inspired by [UnicodingUnicorn's mangadex-downloader](https://github.com/UnicodingUnicorn/mangadex-downloader), which was originally written in Go. Due to changes in the MangaDex API, the original tool became non-functional. After reviewing the updated API, this PowerShell script was created to provide similar functionality.

**Note:** UnicodingUnicorn has since released [mangadex-downloader-2](https://github.com/UnicodingUnicorn/mangadex-downloader-2), now written in Rust.

## Features

- Download entire manga series, individual chapters, or cover images
- Language selection for multi-language manga
- Volume and chapter range filtering
- Custom output directory specification
- Dry run mode for testing without downloading
- Organized file structure with automatic folder creation
- Support for both URL and direct ID input

## Prerequisites

- **PowerShell 5.1** or higher (PowerShell Core/7+ recommended)
- **Windows** operating system (tested on Windows 10/11)
- Internet connection for API access

## Quick Start

Navigate to the `scripts` folder and run:

```powershell
.\get-manga.ps1 -MangadexUrl "https://mangadex.org/title/{manga-id}/{manga-name}"
```

## Usage

### Main Script: get-manga.ps1

Download an entire manga series with various options:

#### Basic Usage
```powershell
# Download using manga URL
.\get-manga.ps1 -MangadexUrl "https://mangadex.org/title/e95a7130-933a-4d31-b812-5ff476c1c5a7/sherlock"

# Download using manga ID and name
.\get-manga.ps1 -MangaId "e95a7130-933a-4d31-b812-5ff476c1c5a7" -MangaName "sherlock"
```

#### Language Selection
```powershell
# Download Spanish version
.\get-manga.ps1 -Language "es" -MangadexUrl "https://mangadex.org/title/{manga-id}/{manga-name}"

# Download Japanese version
.\get-manga.ps1 -Language "ja" -MangadexUrl "https://mangadex.org/title/{manga-id}/{manga-name}"
```

#### Volume and Chapter Filtering
```powershell
# Download specific volume range
.\get-manga.ps1 -VolFrom 1 -VolTo 3 -MangadexUrl "https://mangadex.org/title/{manga-id}/{manga-name}"

# Download specific chapter range
.\get-manga.ps1 -ChapFrom 10 -ChapTo 25 -MangadexUrl "https://mangadex.org/title/{manga-id}/{manga-name}"

# Download from specific volume and chapter
.\get-manga.ps1 -VolFrom 2 -ChapFrom 15 -MangadexUrl "https://mangadex.org/title/{manga-id}/{manga-name}"
```

#### Advanced Options
```powershell
# Custom output directory
.\get-manga.ps1 -TargetFolder "D:\Manga" -MangadexUrl "https://mangadex.org/title/{manga-id}/{manga-name}"

# Dry run (test without downloading)
.\get-manga.ps1 -DryRun -MangadexUrl "https://mangadex.org/title/{manga-id}/{manga-name}"

# Custom formatting for volume/chapter numbers
.\get-manga.ps1 -VolFormat "d3" -ChapFormat "d3" -MangadexUrl "https://mangadex.org/title/{manga-id}/{manga-name}"
```

### Individual Scripts

#### get-cover.ps1
Download only the cover image:
```powershell
.\get-cover.ps1 -MangadexUrl "https://mangadex.org/title/{manga-id}/{manga-name}"
.\get-cover.ps1 -MangaId "{manga-id}" -MangaName "{manga-name}"
```

#### get-chapter.ps1
Download a specific chapter:
```powershell
.\get-chapter.ps1 -ChapterId "{chapter-id}" -ChapterName "Chapter Title"
```

## Parameters Reference

### get-manga.ps1 Parameters

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `MangadexUrl` | String | Full URL of the manga on MangaDex | - |
| `MangaId` | String | Direct manga ID | - |
| `MangaName` | String | Manga title for folder naming | Same as MangaId |
| `Language` | String | Language code (en, es, ja, etc.) | "en" |
| `VolFrom` | Integer | Starting volume number | - |
| `ChapFrom` | Integer | Starting chapter number | - |
| `VolTo` | Integer | Ending volume number | - |
| `ChapTo` | Integer | Ending chapter number | - |
| `VolFormat` | String | Volume number formatting | "d2" |
| `ChapFormat` | String | Chapter number formatting | "d2" |
| `TargetFolder` | String | Output directory path | "./Output" |
| `DryRun` | Switch | Test mode without downloading | False |

## Output Structure

Downloaded content is organized as follows:

```
Output/
└── {Manga Name}/
    ├── {Manga Name} (cover).jpg
    ├── manga-feed-{manga-id}-(en)-(1).json
    ├── {Manga Name} v01c01 (Group Name)/
    │   ├── manga-{chapter-id}.json
    │   ├── 001.jpg
    │   ├── 002.jpg
    │   └── ...
    └── {Manga Name} v01c02 (Group Name)/
        └── ...
```

## Roadmap

This project follows a story-based development approach. See the [Implementation Tasks](docs/implementation-tasks.md) for detailed progress tracking and planned features.

### Upcoming Features
- **Pagination Support** - Handle large manga series with API pagination
- **Advanced Filtering** - Group, status, and tag-based filtering
- **Improved Error Handling** - Better logging and error recovery
- **GUI Interface** - User-friendly graphical interface
- **Progress Indicators** - Download progress bars and ETA
- **Export Formats** - CBZ/PDF export options
- **Incremental Updates** - Download only new chapters

For detailed user stories and implementation progress, see the [stories documentation](docs/stories/).

## MangaDex API

This tool uses the official MangaDex API. MangaDex is an ad-free manga reader that offers high-quality images. 

- **API Documentation:** [https://api.mangadex.org/docs/](https://api.mangadex.org/docs/)
- **Rate Limits:** Please be respectful of API rate limits
- **Terms of Service:** Ensure compliance with MangaDex's terms of service

## Contributing

1. Check the [Implementation Tasks](docs/implementation-tasks.md) for planned features
2. Review existing [story documentation](docs/stories/) for detailed requirements
3. Create feature branches using the pattern: `feature/feature-name`
4. Follow PowerShell best practices and maintain code consistency

## License

This project is available under the terms specified in the [LICENSE](LICENSE) file.

## Troubleshooting

### Common Issues

1. **PowerShell Execution Policy**: If you get execution policy errors, run:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **Network Errors**: Check your internet connection and ensure MangaDex is accessible

3. **API Rate Limiting**: If you encounter rate limits, add delays between requests

4. **File Path Issues**: Ensure the target folder path exists and is writable

For more detailed troubleshooting, enable verbose output or use the `-DryRun` parameter to test configurations.
