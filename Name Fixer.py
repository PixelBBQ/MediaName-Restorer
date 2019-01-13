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
# 7. place them in order in a string and rename the directory to that string.
#
# By Rhys Jones

import os

files = os.listdir("E:/Rhys/Documents/Python/Projects/Name Fixer/names")
for name in files:
    print(name)
    f = open("E:/Rhys/Documents/Python/Projects/Name Fixer/new names/" + name + ".txt", 'w')
    f.close()


# 1. place old directory name as a txt file inside the directory.
# 2. separate all parts of string with either a space or a dot dividing them.
# 3. find quality through grouping a number 3-4 digits long followed by a 'p'.
# 4. find date by searching for a group of 4 digits, if two groups, choose the group closest to the end of the string.
# 5. find the version by first searching for the word 'cut' if no word exists, move to step 6. If cut exists, check
# each word before it with a list of known version descriptions. If they match, store them in order of what word came
# first in the entire string.
# 6. find the movie name by grouping any parts of the string that were not grouped by step 5 and come before the date.
# 7. place them in order in a string and rename the directory to that string.


