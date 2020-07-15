# Fixes names of movie folders in the target directory.
#
# The project can be found here: https://github.com/PixelBBQ/Movie-Name-Fixer
# By Kiweezi: https://github.com/kiweezi
#


# -- Global Variables --

# The directory that contains the movie folders.
$moviesDir = $PSScriptRoot

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
                    Write-Host "API key provided passed with movie title: $($apiResult.Title)."

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
            # If the numbers do NOT mean the resolution of the movie, continue.
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
    # Extract a movie name from the folder name.

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
    # Separates movie details from the folder name.

    param (
        # The target folder string.
        $dirString
    )
    
    # Create a hashtable to extract the movie details to.
    $dirDetails = @{
        Name = "";
        Date = "";
    }

    # Remove unnecessary characters.
    $cleanStr = $dirString.replace(".", " ")

    # Get the date of the movie to query from folder name.
    $dirDetails.Date = Get-FolderDate $cleanStr
    # Get the name of the movie to query from the folder string.
    $dirDetails.Name = Get-FolderName $cleanStr $dirDetails.Date
    
    # Return the hashtable of directory details to be queried.
    $dirDetails
}


function Find-MovieDetails {
    # Uses the details from the string to query OMDb api to fill in the gaps.

    param (
        # The movie details that will be used to query the OMDb's API.
        $query,
        # The key to use the API.
        $apikey
    )

    # Split the movie title into each word.
    $titleSubStrs = $query.Title -split' '

    # Find a list of movies to compare to.
    # Loop through each of the title parts.
    foreach ($titlePart in $titleSubStrs) {
        # Search for the first word of the movie title and the date to match through OMDb's API.
        $searchResult = Invoke-RestMethod "$($apiURL)?apikey=$($testKey)&s=$($titlePart)&y=$($query.Date)"

        # If the response from the query is true, break the loop.
        if ($searchResult.response -eq $true) {
            # Select the search results.
            $selectedResult = $searchResult
            # Break the for loop.
            break
        }
    }

    # Stores all the titles from the search results.
    $apiTitles = $selectedResult.search.title
    # Create an empty list to contain scores to compare to later.
    $scores = @{}

    # Score each title found in the search.
    foreach ($title in $apiTitles) {
        
    }

}


function Format-MovieDetails {
    # Arrange the movie name details into the correct format.

    param (
        OptionalParameters
    )
    
    

}


function Set-FolderString {
    param (
        OptionalParameters
    )


}



# -- Main --

function Start-Main {
    # Calls the rest of the commands in the script.
    
    # Loop through each movie directory 
    foreach ($dirString in (Get-ChildItem $moviesDir).Name) {
        # If the directory has not been fixed before, run the program to fix it.
        if (-not (Test-Path "$($moviesDir)$($dirString)fixed.txt")) {

            # Get's the key for the OMDb api.
            $apikey = Get-APIkey
            # Separates movie details from the folder name.
            $query = Get-FolderString $dirString
            # Uses the details from the string to query OMDb api to fill in the gaps.
            $rawDetails = Find-MovieDetails $query $apikey
            # Arrange the movie name detail into the correct format.
            Format-MovieDetails
            # Set the folder name to match the movie name and details found.
            Set-FolderString
        }
    }
}


Start-Main

# -- End --



# Terminates the script.
exit