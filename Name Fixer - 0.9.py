# Fixes names of Movies folders on my external movie drive. Works with most pirate bay name formats but is
# obviously not programmed to work on a gloriously stupid name format.
#
# Edit for 1.0:
# 1. Comment fully and clean code.
# 2. Make sure .txt file inside directory does not get overwritten.
# 2. Make sure that the quality section is in the correct order since there could be two strings in it.
# 3. Add file to save log to for debugging outside of terminal.
#
# By Rhys Jones

# Imports
import os       # import os for file path and advanced editing.
import re       # import re for string literals.

# Global Arrays
versions = ['ultimate', 'directors', "director's", 'final', 'cut']      # stores version names to be used later.
brVer = ['bluray', 'brrip', 'brdvd']                                    # stores BluRay version names to be used later.


# Global Variables
baseDir = "C:/Users/Rhys/Documents/Python/Projects/Movie-Name-Fixer-initial-build/names"  # root directory path string.


directories = os.listdir(baseDir)           # lists the directories inside of the root directory path.
for directory in directories:               # loops for each directory inside of the list of directories.

    # Per directory arrays
    sections = ['', '', '', '']             # holds structure fof the 4 sections of the new name.
    remove = []                             # will contain indexes that have been placed into the sections list.

    # Per directory variables
    newDir = ''                             # holds a string of the final directory name.

    # debugging
    print(directory)                        # prints directory variable for debugging.

    # creates a text file of the original name of the directory, before the program ran.
    if not os.path.exists(os.path.join(baseDir, directory, '/MNF')):
        os.makedirs(os.path.join(baseDir, directory, '/MNF'))
        f = open(baseDir + '/' + directory + '/' + directory + ".txt", 'w')   # create text file of old name in the directory.
        f.close()

    for i in ['[', ']']:
        name = directory.replace(i, '')      # delete square brackets in the name.
    name = re.split("[ .]", name)       # split the name into a list where spaces and dots were dividing it.
    print (name)


    # find date
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

# Edit for 1.0:
# 1. Comment fully and clean code.
# 2. Make sure .txt file inside directory does not get overwritten.
# 2. Make sure that the quality section is in the correct order since there could be two strings in it.
# 3. Add file to save log to for debugging outside of terminal.