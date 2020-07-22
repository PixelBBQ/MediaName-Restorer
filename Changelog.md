# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]
- Add ability to search without a date provided.
- Add negative scores for movie names to improve accuracy.
- Add extensive logging.
- Add extra parameters.

## 0.2.0 - 2020-07-22
**Powershell Re-write**
Create entirely new Powershell script which uses OMDb's API for searches.

### Changes:
- Replaced Python script for Powershell script.
- Added OMDb API queries to find more accurate results.
- Now ignores folders that have been fixed and contain 'details.txt' files.

### Fixed:
- Prevents Windows folder naming restriction errors.