# Media Name Restorer

## Description
Corrects titles for folders containing entertainment media like movies and shows.
Queries OMDb's API for details on the media based on what information the incorrect title currently displays.

The program must be used on folders. The directory names must hold some data to search movies or shows contained in OMDb.
Functions best when provided a similar title and date of release for the media.

You must have an OMDb API key, which you can get from [OMDb API](https://www.omdbapi.com/apikey.aspx).

---

## Index

<!--toc-start-->
* [Setup](#setup)
* [Usage](#usage)
* [Latest Version](#latest-version)
<!--toc-end-->

---

## Setup
- Get an API key from [OMDb API](https://www.omdbapi.com/apikey.aspx).
- Download and extract the Zip file from GitHub.
- Move the extracted child folder ```\_restore\``` into the directory containing the incorrect media names.
- Make sure you have an unrestricted execution policy set in powershell:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```

## Usage
- Right click the script file ```restore-details.ps1```, select ```Run with PowerShell```.
- The program will ask for an OMDb API Key on first run, after which it will remember it.

## Latest Version

### 0.2.0 - 2020-07-22
**Powershell Re-write**
Create entirely new Powershell script which uses OMDb's API for searches.

### Changes:
- Replaced Python script for Powershell script.
- Added OMDb API queries to find more accurate results.
- Now ignores folders that have been fixed and contain 'details.txt' files.

### Fixes:
- Prevents Windows folder naming restriction errors.