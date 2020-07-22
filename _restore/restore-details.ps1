# Fixes names of media folders in the target directory.
#
# The project can be found here: https://github.com/PixelBBQ/MediaName-Restorer
# By Kiweezi: https://github.com/kiweezi
#


# -- Global Variables --

# The directory that contains the media folders.
$mediaDir = "$($PSScriptRoot)..\"

# The details for OMDb's API.
$apiURL = "http://www.omdbapi.com/"

# -- End --



function Get-APIkey {
    # Gets the APIkey to use in order to query OMDb's API.

    # Store path to Json file containing APIkey.
    $jsonPath = "$($PSScriptRoot)\apikey.json"
    # Create a variable to hold the state of the key test.
    $keyCorrect = $false

    # If the json file exists, get the key from it, otherwise set variable to blank.
    if (Test-Path -Path $jsonPath) {
        # Get the possible APIkey from the json file.
        $jsonKey = (Get-Content $jsonPath | ConvertFrom-Json).apikey
    } else {
        $jsonKey = ""
    }
    # Set a temporary key variable that will change.
    $testKey = $jsonKey

    # Loop until the API key successfully passes.
    while ($keyCorrect -eq $false) {

        # If the API key matches the length of 8 then it can be tested.
        if ($testKey.length -eq 8) {
            # Try the apikey provided.
            try {
                # Test the api key, if it passes, it will continue.
                $apiResult = Invoke-RestMethod "$($apiURL)?apikey=$($testKey)&i=tt0083658"

                # The API key is correct, store it to be used later and exit the loop.
                $keyCorrect = $true
                $apikey = $testKey

                # If the response returns true then the API is ready to use.
                if ($apiResult.Response -eq $true) {
                    Write-Host "API key provided passed with media title: $($apiResult.Title)."

                    # If the json file has not been updated, update it.
                    if ($jsonKey -ne $apikey) {
                        @{ apikey = $apikey } | ConvertTo-Json | Out-File $jsonPath
                    }
                }
                # If the API Key is correct but the response is a fail, display the error but pass the key.
                elseif ($apiResult.Response -eq $false) {
                    # Display the error.
                    @(  "The API Key passed, however the request failed with the error: $($apiResult.Error). `n"
                        "This may indicate something has changed with the API that the code is unaware of. `n"
                        "The program will now continue."
                    ) -join '' | Write-Host
                }
            }
            # If the request fails, check why.
            catch {
                # Store the exeption details.
                $apiErrorCode = $_.Exception.Response.StatusCode.value__
                $apiErrorDesc = $_.Exception.Response.StatusDescription

                # If the api error is because it was an incorrect key, display this.
                if ($apiErrorCode -eq "401") {
                    Write-Host "API key provided failed with error code 401: invalid API key."
                } 
                # If the error was not due to an invalid API key, then display this and quit.
                else {
                    # Display the error.
                    @(  "The API request failed due to an unforseen error. `n"
                        "Error code: $($apiErrorCode). `n"
                        "Error description: $($apiErrorDesc). `n"
                        "The program will now exit..."
                    ) -join '' | Write-Host
                    # Exit the program.
                    exit
                }

                # Set the key state to be incorrect.
                $keyCorrect = $false
            }
        }
        # If the key length is not 8 then the key is incorrect.
        else {
            Write-Host "API key failed as it does not match the API key format."
            $keyCorrect = $false
        }

        # If the key is correct then return it.
        if ($keyCorrect -eq $true) {
            Write-Host "Found API key.`n"
            return $apikey
        }
        # If the key is incorrect then create a new one.
        elseif ($keyCorrect -eq $false) {
            # Ask the user to generate or provide a valid API key.
            @(  "Please provide a valid API key. `n"
                "You can generate a new key here: http://www.omdbapi.com/apikey.aspx"
            ) -join '' | Write-Host
            # Take the user's API key
            $testKey = Read-Host -Prompt "Enter your new API key here"
            # Format output.
            Write-Host ""
        }
    }
    
    # Return the API key.
    return $apikey
}


function Get-FolderDate {
    # Extract a date from the folder name.
    
    param (
        # The string of the folder name.
        $folderStr
    )
    
    # Find possible dates from the string.
    # Set a variable for breaking the loop.
    $continue = $false
    # Create an array of possible dates.
    $possibleDates = @()

    # Find most likely date(s).
    While ($continue -eq $false) {
        # Find 4 digits in a row and check them.
        if ($folderStr -match "([0-9]{4}).*") {
            # If the numbers do NOT mean the resolution of the media, continue.
            if (-not ($folderStr -match "$($matches[1])p")) {
                # Store the possible date.
                $possibleDates += $matches[1]
            }
            # Refine string to new query substring.
            $folderStr = $matches[0][1..($matches[0].length)] -join('')
        }

        else {
            # No possible date has been found, break the loop.
            $continue = $true
        }
    }
    # Select the leftmost date from the directory string.
    $selectedDate = $possibleDates[0]

    # Return the date detail.
    return $selectedDate
}

function Get-FolderName {
    # Extract a media name from the folder name.

    param (
        # The string of the folder name.
        $folderStr,
        # The date extracted from the folder name.
        $stringDate
    )
    
    # Get the index of the date substring from the folder string.
    $dateIndex = $folderStr.IndexOf($stringDate)
    # Get substring of anything before the date.
    $selectedName = $folderStr[0..($dateIndex - 1)] -join('')

    # Return the name found.
    return $selectedName
}

function Get-FolderString {
    # Separates media details from the folder name.

    param (
        # The target folder string.
        $dirString
    )

    # Remove unnecessary characters.
    $cleanStr = $dirString.replace(".", " ")

    # Create a hashtable to extract the media details to.
    $dirDetails = @{}
    # Get the date of the media to query from folder name.
    $dirDetails["Date"] = Get-FolderDate $cleanStr
    # Get the name of the media to query from the folder string.
    $dirDetails["Title"] = Get-FolderName $cleanStr $dirDetails.Date
    
    # Log the findings.
    Write-Host "Original folder name: $($dirString)"
    Write-Host "Extracted title: $($dirDetails.Title)"
    Write-Host "Extracted date: $($dirDetails.Date)`n"

    # Return the hashtable of directory details to be queried.
    $dirDetails
}


function Find-MediaDetails {
    # Uses the details from the string to query OMDb api to fill in the gaps.

    param (
        # The media details that will be used to query the OMDb's API.
        $query,
        # The key to use the API.
        $apikey
    )

    # Split the media title into each word.
    $titleSubStrs = $query.Title -split' '

    # Find a list of medias to compare to.
    # Loop through each of the title parts.
    foreach ($titlePart in $titleSubStrs) {
        # Search for the first word of the media title and the date to match through OMDb's API.
        $searchResult = Invoke-RestMethod "$($apiURL)?apikey=$($apikey)&s=$($titlePart)&y=$($query.Date)"

        # If the response from the query is true, break the loop.
        if ($searchResult.response -eq $true) {
            # Select the search results.
            $selectedResult = $searchResult
            # Break the for loop.
            break
        }
    }

    # Log the selected api result.
    Write-Output "The selected api result to search through is as follows:"
    Write-Output "$($selectedResult.search)`n"

    # If the selected result only contains one result then return the details of this.
    if ($selectedResult.totalResults -le 1) {
        $allDetails = $selectedResult.search
    }
    # If there is more than one result, find the most accurate media title.
    elseif ($selectedResult.totalResults -gt 1) {

        # Remove unwanted special characters from the title.
        $queryTitle = $query.Title -replace "[^a-zA-Z\d]"
        # Split the media title into each word.
        $titleSubStrs = $queryTitle -split' '

        # Stores all the titles from the search results.
        $apiTitles = $selectedResult.search.title
        # Create an empty hashtable to contain scores to compare to later.
        $scores = @{}

        # Score each title found in the search.
        foreach ($apiTitle in $apiTitles) {
            # Remove unwanted special characters from the title.
            $cleanAPItitle = $apiTitle -replace "[^a-zA-Z\d]"
            # Split the title into it's substring words.
            $apiWords = $cleanAPItitle -split ' '

            # Try matching each word against the provided media title.
            foreach ($apiWord in $apiWords) {
                # If the word from the api title matches the title on the folder, score a point.
                if ($titleSubStrs -contains $apiWord) {

                    # Get the imdb ID of the selected omdb media.
                    $testID = ($selectedResult.search | Where-Object { $_.Title -eq $apiTitle }).imdbID

                    # If the score property already exists then add to it.
                    if ($scores[$testID]) { $scores[$testID] = $scores[$testID] + 1 }
                    # Otherwise, initiate the score under the imdbID.
                    else { $scores.Add($testID, 1) }
                }
            }
        }

        # Find the highest scoring title's imdb ID.
        $imdbID = ($scores.GetEnumerator() | Sort-Object Value | Select-Object -Last 1).Name
        # Select the correct media details by using the imdb ID found.
        $allDetails = $selectedResult.search | Where-Object { $_.imdbID -eq $imdbID }
    }

    # Log the findings.
    Write-Output "Selected most accurate movie details:" 
    Write-Output "$($allDetails)`n"

    # Create an empty hashtable to store the raw media details.
    $rawDetails = @{}
    # Store the media title and date of release.
    $rawDetails.Add("Title", $allDetails.Title)
    $rawDetails.Add("Year", $allDetails.Year)

    # Return the media details that omdb has found.
    return $rawDetails
}


function Format-MediaDetails {
    # Arrange the media name details into the correct format.

    param (
        # Contains the media details found by the api.
        $rawDetails
    )
    
    # Make easier access variables.
    $title = $rawDetails."Title"
    $year = $rawDetails."Year"

    # Create the new folder name string from the media details.
    $newString = "$($title) ($($year))"
    # Format for Windows file naming convensions.
    # Take out any colons and replace with a hyphon
    $newString = $newString -replace (":", " -")

    # Log the findings.
    Write-Host "Created new folder name: $($newString)"

    # Return the new folder name.
    return $newString
}


function Set-FolderString {
    # Set the new name of the folder.

    param (
        # The name the folder currently has.
        $currentDir,
        # The new folder name.
        $newName
    )

    # If there is no newName then do not rename the folder.
    if ($newName -ne "") {
        # Rename the folder.
        Rename-Item -LiteralPath "$($mediaDir)\$($currentDir)\" -NewName $newName -PassThru
    }

    # Test if the process worked.
    if (Test-Path -Path "$($mediaDir)\$($newName)") {
        # Create a file to indicate the folder has been fixed.
        New-Item -Path "$($mediaDir)\$($newName)\" -Name "details.txt" -ItemType "file"
        # Log the success of the folder rename.
        Write-Host "Folder successfully renamed:`nOLD: $($currentDir)`nNEW: $($newName)`n"
    } else {
        Write-Host "Folder failed to be renamed.`n"
    }
}



# -- Main --

function Start-Main {
    # Calls the rest of the commands in the script.

    # Get's the key for the OMDb api.
    $apikey = Get-APIkey

    # Loop through each media directory 
    foreach ($dirString in (Get-ChildItem -Path $mediaDir -Directory).Name) {
        # If the directory has not been fixed before, run the program to fix it.
        if (-not (Test-Path "$($mediaDir)$($dirString)details.txt" -or Test-Path "$($mediaDir)$($dirString)restore-details.ps1")) {

            # Separates media details from the folder name.
            $query = Get-FolderString $dirString
            # Uses the details from the string to query OMDb api to fill in the gaps.
            $rawDetails = Find-MediaDetails $query $apikey
            # Arrange the media name detail into the correct format.
            $newString = Format-MediaDetails $rawDetails
            # Set the folder name to match the media name and details found.
            Set-FolderString $dirString $newString
        }
    }
}


Start-Main

# -- End --



# Terminates the script.
exit