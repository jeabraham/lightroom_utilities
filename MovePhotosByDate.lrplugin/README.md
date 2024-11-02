Explanation
Directory Selection:
The script prompts the user to select a base directory where date folders will be created.
Capture Date and Folder Structure:
Each photo’s capture date is retrieved and formatted as YYYY/YYYY-MM-DD.
The script checks for an existing folder structure under the base directory and creates it if needed.
Photo Movement:
The script moves each photo to its respective date-based folder.
After moving, it updates the Lightroom catalog with the photo’s new location.
Error Handling:
If a photo lacks a capture date, the script skips it.
If the move operation fails, it displays an error message with details.
Installation and Use
Install the Plugin:
Place the MovePhotosByDate.lrplugin folder in an accessible location.
Open Lightroom, go to File > Plug-in Manager, and add the plugin.
Run the Plugin:
Select the photos you want to move.
Go to Library > Plug-in Extras > Move Selected Photos to Date Folders.
Choose the base directory for your date folders when prompted.
Confirm Completion:
After the script runs, it will display a success message.
This plugin will move the selected photos to date-based folders and update Lightroom’s catalog with the new file locations. Let me know if you need any additional customization!


