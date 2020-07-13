# Fixes names of movie folders in the target directory.
#
# The project can be found here: https://github.com/PixelBBQ/Movie-Name-Fixer
# By Kiweezi: https://github.com/kiweezi
#


# -- Global Variables --

# The directory that contains the movie folders.
$moviesDir = $PSScriptRoot

# The details for OMDb's API.
$api = "http://www.omdbapi.com/"

# -- End --



function Get-APIkey {
    # Finds the existing API token for OMDb or asks the user to provide one.
    
    # Set the path to the json file for the api token.
    $jsonPath = "$PSScriptRoot\key.json"
    # Get the api key from the json file.
    $testKey = (Get-Content $jsonPath | ConvertFrom-Json).apikey

    # If the key is not empty, test it.
    if ($null -ne $testKey) {
        # 
        if (Invoke-RestMethod -Method "http://www.omdbapi.com/?apikey=$($testKey)&i=tt1856101") {

        }
    }
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
                # Refine string to new query substring.
                $folderStr = $matches[0][1..($matches[0].length)] -join('')
            }
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

function Get-FolderDetails {
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
        OptionalParameters
    )

}


function Format-MovieDetails {
    # Arrange the movie name detail into the correct format.

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

            # Get's the token for the OMDb api.
            $token = Get-APIkey
            # Separates movie details from the folder name.
            $query = Get-FolderString $dirString
            # Uses the details from the string to query OMDb api to fill in the gaps.
            Find-MovieDetails $query $api
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