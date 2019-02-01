# Movie-Name-Fixer
Fixes names of Movies folders on my external movie drive. Works with most pirate bay name formats but is obviously not programmed to work on a gloriously stupid name format.

### First stable build 0.9 - beta ###

# Changelog:
- Formats pirate movie names.
- Changes the directory name.


# Future changes:
For 1.0 release:
- 1. Comment fully and clean code.
- 2. Make sure .txt file inside directory does not get overwritten.
- 2. Make sure that the quality section is in the correct order since there could be two strings in it.
- 3. Add file to save log to for debugging outside of terminal.

Other bits:
- 1. If there are parts in front of the name that are separated from the name, make sure they are processed and do not end
up in the movie name section.
- 2. If the automated process does not work, create a more manual, targetted option where the user enters as much info as
they would like about the directory they have selected. The program will then solve the rest of the information and
format it.
