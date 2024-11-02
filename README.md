# NOTE: WIP #

** This is a WORK IN PROGRESS.  The "MovePhotosByDate" does not yet work!**

# Duplicate Photo Management and Lightroom Collection Creation

This project provides three utilities: 

1. **`find_duplicates.sh`** - A
Bash script that identifies duplicate photos in a specified directory
structure, outputs `rm` commands to remove duplicates, and generates
lists of files for further use. 

2. **Lightroom Plugin PhotoCollectionCreator** - A Lua
plugin for Adobe Lightroom Classic that creates a collection from a list
of photo file paths.

3. **Lightroom Plugin MovePhotosByDate** - A plugin for 
Lightroom that moves folders into date folders YYYY/YYYY-MM-DD, 
the same pattern that Lightroom can apply when importing photos.  If you
forget to organize them this way when you import them, you can use
this plugin to do it later.  ***DOES NOT WORK YET*** look at
`move_commands_to_date_folder.sh` for a shell-based alternative.

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

`bash find_duplicates.sh [photo_directory] [date_sorted_directory] [mv_to_directory]`

photo_directory: The directory where your original photos are stored.
This argument is optional; by default, it uses the current directory.

date_sorted_directory: The directory containing subfolders organized by
date (YYYY/YYY-MM-DD). This argument is also optional, defaulting to the
current directory.

mv_to_directory: The folder you might like to move the files in the photo_directory
to.  If this is not specified, the script will build rm commands to remove the
photos, rather than mv commands to move the photos. 

Example:

`bash find_duplicates.sh /path/to/photos /path/to/date-sorted-photos`

After running, the script generates four output files:

`link_root_photos_to_date_sorted.sh`: Contains commands to hardlink
the duplicate files, saving disk space.  So, the photo in the root
directory and the photo in the date sorted directory will share 
the same diskspace and physically be the same file.  You may want to link the files first,
before moving them, or link them with the idea that you might remove them
later.  

`handle_duplicates.sh`: Contains commands to move or remove duplicate
files and their .xmp sidecar files.  

`root_photos_duplicates.txt`: A list of all photo paths in the photo_directory.

`date_sorted_photos_duplicates.txt`: A list of all photo paths in the
date_sorted_directory.


## Step 2: Import Files into Lightroom Using the Lua Plugin to make collections

Install the Lightroom Plugin:

Place the Lua plugin (PhotoCollectionCreator.lrplugin) in a location
accessible by Lightroom.

Open Adobe Lightroom Classic, go to File > Plug-in Manager, and add the
plugin folder.

Use the Plugin:

Go to Library > Plug-in Extras > Create Collection from File List.

Select the `root_photos_duplicates.txt` or `date_sorted_photos_duplicates.txt` file depending on
which list of photos you want in the collection.

The plugin will create a new Lightroom collection called "Photos from File List"
based on the file paths in the selected text file.

## Step 3

After you are happy with the set of photos, you can remove the photos from the Lightroom
catalog by selecting all the photos in the collection and then
using the Lightroom menu item 'Remove Photos From Catalog'.  

You can then also move them on your hard drive or remove them by executing the `duplicate_removal_commands.sh` script.
Note that you can also move the photos on your hard drive using Lightroom menu items or drag-and-drop sometimes.  

** Step 4

The other utilities are useful if you want to move or remove a bunch of duplicate
files when the other copy is in a date-sorted folder YYYY/YYYY-MM-DD.  But, 
if at the end of that, you still have a bunch of photos that 
*weren't* duplicates, you can use the Lightroom Plugin MovePhotosByDate 
to move the photos to the folder based on their EXIF date. 

s
