# Duplicate Photo Management and Lightroom Collection Creation

This project provides two utilities: 

1. **`find_duplicates.sh`** - A
Bash script that identifies duplicate photos in a specified directory
structure, outputs `rm` commands to remove duplicates, and generates
lists of files for further use. 

2. **Lightroom Lua Plugin** - A Lua
plugin for Adobe Lightroom Classic that creates a collection from a list
of photo file paths.

# Requirements

1. **Bash** (for `find_duplicates.sh`).

2. **ExifTool** - Install via:
  
  ```
  bash sudo apt-get install exiftool  # On Ubuntu/Debian
  brew install exiftool                  # On macOS
  ```
  
3. Adobe Lightroom Classic for using the Lua plugin.

# Usage Guide

## Step 1: Run the Duplicate Finder Script

Navigate to the directory where `find_duplicates.sh` is located.

Run the script using the following command:

`bash find_duplicates.sh [photo_directory] [date_sorted_directory]`

photo_directory: The directory where your original photos are stored.
This argument is optional; by default, it uses the current directory.

date_sorted_directory: The directory containing subfolders organized by
date (YYYY/YYY-MM-DD). This argument is also optional, defaulting to the
current directory.

Example:

`bash find_duplicates.sh /path/to/photos /path/to/date-sorted-photos`

After running, the script generates three output files:

`duplicate_removal_commands.sh`: Contains commands to remove duplicate
files.

`root_photos.txt`: A list of all photo paths in the photo_directory.

`date_sorted_photos.txt`: A list of all photo paths in the
date_sorted_directory.


## Step 2: Import Files into Lightroom Using the Lua Plugin

Install the Lightroom Plugin:

Place the Lua plugin (LightroomRemoveFlagged.lrplugin) in a location
accessible by Lightroom.

Open Adobe Lightroom Classic, go to File > Plug-in Manager, and add the
plugin folder.

Use the Plugin:

Go to Library > Plug-in Extras > Create Collection from File List.

Select the `root_photos.txt` or `date_sorted_photos.txt` file depending on
which list of photos you want in the collection.

The plugin will create a new Lightroom collection based on the file
paths in the selected text file.

## Step 3

After you are happy with the set of photos, you can remove the photos from the Lightroom
catalog by selecting all the photos in the collection and then
using the Lightroom menu item 'Remove Photos From Catalog'.

You can then also remove them from your hard drive by executing the `duplicate_removal_commands.sh` script.  You could also 
change the script easily enough (e.g. in a text editor) to move the photos somehwere else, rather than deleting them. 

