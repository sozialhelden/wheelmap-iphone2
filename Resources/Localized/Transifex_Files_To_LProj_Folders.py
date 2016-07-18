import glob
import shutil
import os
import errno

# Constants
PREFIX_TO_IGNORE = "app_strings_"
DESTINATION_DIRECTORY_SUFFIX = "lproj"
DESTINATION_FILENAME = "Localizable.strings"
FILES_PATCH = "*.strings"

# Check if a folder exists and create it if it doesn't exist yet
def make_sure_path_exists(path):
    try:
        os.makedirs(path)
    except OSError as exception:
        if exception.errno != errno.EEXIST:
            raise

for filename in glob.glob(FILES_PATCH):
	# Get the identifier which represents the language like "pt_BR" from "app_strings_pt_BR.strings"
    languageIdentifier = ((filename.split('.strings'), 1)[0][0].split(PREFIX_TO_IGNORE, 1)[1])
    
    # Create the directory for the current language
    newDirectoryPath = languageIdentifier + "." + DESTINATION_DIRECTORY_SUFFIX + "/"
    make_sure_path_exists(newDirectoryPath)
    
    # Move the strings file to the desired language directory
    shutil.move(filename, newDirectoryPath + DESTINATION_FILENAME)

    # Print out the success of the operation
    print("moved " + filename + " to " + newDirectoryPath + DESTINATION_FILENAME)

