# Fixes names of Movies folders on my external movie drive. Works with most pirate bay name formats but is
# obviously not programmed to work on a gloriously stupid name format.
#
# 1. place old directory name as a txt file inside the directory.
# 2. separate all parts of string with either a space or a dot dividing them.
# 3. find quality through grouping a number 3-4 digits long followed by a 'p'.
# 4. find date by searching for a group of 4 digits, if two groups, choose the group closest to the end of the string.
# 5. find the version by first searching for the word 'cut' if no word exists, move to step 6. If cut exists, check
# each word before it with a list of known version descriptions. If they match, store them in order of what word came
# first in the entire string.
# 6. find the movie name by grouping any parts of the string that were not grouped by step 5 and come before the date.
# 7. place groups order in a string (with divider '-' between section 2 and 3) and check all formatting is correct.
# 8. rename the directory to the string.
#
# By Rhys Jones

# Imports
import os       # import os for file path and advanced editing.
import re       # import re for string literals.

# Global Arrays
versions = ['ultimate', 'directors', "director's", 'final', 'cut']     # stores version names to be used later.
brVer = ['bluray', 'brrip', 'brdvd']                            # stores BluRay version names to be used later.


# Global Variables
baseDir = "C:/Users/Rhys/Documents/Python/Projects/Movie-Name-Fixer-initial-build/names"


directories = os.listdir(baseDir)
for directory in directories:
    sections = ['', '', '', '']
    remove = []
    newDir = ''

    print(directory)
    f = open("./names/" + directory + "/" + directory + ".txt", 'w')   # create text file of old name in the directory.
    f.close()

    for i in ['[', ']']:
        name = directory.replace(i, '')      # delete square brackets in the name.
    name = re.split("[ .]", name)       # split the name into a list where spaces and dots were dividing it.
    print (name)


    # find date
    noDate = 0
    for currentSection in name:
        if len(currentSection) == 4 and all(char.isdigit() for char in currentSection):
            sections[1] = ('(' + currentSection + ') - ')
            remove.append(name.index(currentSection))



    # find version
    for currentSection in name:
        if currentSection.lower() == 'cut':
            for sect in range(0, name.index(currentSection) + 1):
                for version in versions:
                    if name[name.index(currentSection) - sect].lower() == version:
                        sections[3] = (name[name.index(currentSection) - sect] + " " + sections[3])
                        remove.append(name.index(currentSection) - sect)

            sections[3] = sections[3][:-1]


    # find quality
    for currentSection in name:
        if len(currentSection) == 5 or len(currentSection) == 4:
            if all(char.isdigit() for char in currentSection[:-1]) and currentSection[-1:].lower() == 'p':
                sections[2] += ('[' + currentSection + ' ')
                remove.append(name.index(currentSection))


    # find bluray
    for currentSection in name:
        if currentSection.lower() in brVer:
            sections[2] += (currentSection + '] ')
            remove.append(name.index(currentSection))



    # remove used list elements to find name
    for currentSection in name:
        if name.index(currentSection) <= all(part for part in remove):
            if name.index(currentSection) not in remove:
                sections[0] += (currentSection + ' ')


    # format
    for section in sections:
        newDir += section


    print(sections)
    print newDir


    # Apply the new name
    os.rename(os.path.join(baseDir, directory),
              os.path.join(baseDir, newDir))

# 1. place old directory name as a txt file inside the directory.
# 2. separate all parts of string with either a space or a dot dividing them.
# 3. find quality through grouping a number 3-4 digits long followed by a 'p'.
# 4. find date by searching for a group of 4 digits, if two groups, choose the group closest to the end of the string.
# 5. find the version by first searching for the word 'cut' if no word exists, move to step 6. If cut exists, check
# each word before it with a list of known version descriptions. If they match, store them in order of what word came
# first in the entire string.
# 6. find the movie name by grouping any parts of the string that were not grouped by step 5 and come before the date.
# 7. place groups order in a string (with divider '-' between section 2 and 3) and check all formatting is correct.
# 8. rename the directory to the string.


