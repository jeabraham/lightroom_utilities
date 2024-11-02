#!/bin/bash

# Set the root directory for photos, date-sorted directory, optional move-to directory, and optional hardlink flag
photo_dir="${1:-$PWD}"
date_sorted_dir="${2:-$PWD}"
mv_to_directory="${3}"
hardlink="${4}"

# Output files
link_commands="link_root_photos_to_date_sorted.sh"
handle_commands="handle_duplicates.sh"
root_duplicates="root_photos_duplicates.txt"
date_sorted_duplicates="date_sorted_photos_duplicates.txt"

# Initialize output files
echo "#!/bin/bash" > "$link_commands"
echo "# Commands to hardlink root duplicates to date-sorted duplicates" >> "$link_commands"
echo "#!/bin/bash" > "$handle_commands"
echo "# Commands to handle duplicate files and their sidecar files" >> "$handle_commands"
> "$root_duplicates"
> "$date_sorted_duplicates"

# Check if mv_to_directory is provided
if [[ -n "$mv_to_directory" ]]; then
  # Create the move-to directory if it doesn't exist
  mkdir -p "$mv_to_directory"
fi

# Iterate over each file in the photo directory
find "$photo_dir" -maxdepth 1 -type f | while read -r file; do
  # Get filename and file extension
  filename=$(basename "$file")
  file_basename="${filename%.*}"

  # Extract the date from the photo using exiftool (assumes DateTimeOriginal tag)
  photo_date=$(exiftool -d "%Y-%m-%d" -DateTimeOriginal "$file" | awk -F': ' '{print $2}')

  # Skip files without a valid date
  if [[ -z "$photo_date" ]]; then
    echo "No date found for $filename, skipping..."
    continue
  fi

  # Format date into year/month-day
  year=${photo_date:0:4}
  date_folder="${date_sorted_dir}/${year}/${photo_date}"

  # Check if the same filename exists in the target subdirectory
  if [[ -f "$date_folder/$filename" ]]; then
    # Compare the files to check if they are identical
    if cmp -s "$file" "$date_folder/$filename"; then
      # Add duplicate paths to respective lists
      echo "$file" >> "$root_duplicates"
      echo "$date_folder/$filename" >> "$date_sorted_duplicates"
      
      # Add a command to hardlink the root duplicate to the date-sorted copy in `link_root_photos_to_date_sorted.sh`
      echo "ln -f '$date_folder/$filename' '$file'" >> "$link_commands"
      
      # Add commands to `handle_duplicates.sh` based on options
      if [[ -n "$mv_to_directory" ]]; then
        # Move the file to the specified directory
        echo "mv '$file' '$mv_to_directory/'" >> "$handle_commands"
        # Handle sidecar files for move operation
        if [[ -f "${photo_dir}/${file_basename}.xmp" ]]; then
          echo "mv '${photo_dir}/${file_basename}.xmp' '$mv_to_directory/'" >> "$handle_commands"
        fi
      else
        # Delete the file if no move directory is specified
        echo "rm '$file' # identical file found in $date_folder/$filename" >> "$handle_commands"
        # Remove sidecar file if it exists
        if [[ -f "${photo_dir}/${file_basename}.xmp" ]]; then
          echo "rm '${photo_dir}/${file_basename}.xmp'" >> "$handle_commands"
        fi
      fi
    fi
  fi
done

# Make the output command files executable
chmod +x "$link_commands" "$handle_commands"

echo "Duplicate check complete."
echo "Output files generated:"
echo "- $link_commands: Commands to hardlink root duplicates to date-sorted duplicates."
echo "- $handle_commands: Commands to either delete or move duplicates in the root directory."
echo "- $root_duplicates: List of duplicate photo paths in the root directory."
echo "- $date_sorted_duplicates: List of duplicate photo paths in the date-sorted directory."
