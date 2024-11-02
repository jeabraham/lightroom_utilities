#!/bin/bash

# Set the root directory for photos and the date-sorted directory
photo_dir="${1:-$PWD}"
date_sorted_dir="${2:-$PWD}"

# Output files
rm_commands="duplicate_removal_commands.sh"
root_photos="root_photos.txt"
date_sorted_photos="date_sorted_photos.txt"

# Initialize output files
echo "#!/bin/bash" > "$rm_commands"
echo "# Identical file removal commands" >> "$rm_commands"
> "$root_photos"
> "$date_sorted_photos"

# Generate list of files in the photo directory
find "$photo_dir" -maxdepth 1 -type f > "$root_photos"

# Generate list of files in the date-sorted directory
find "$date_sorted_dir" -type f > "$date_sorted_photos"

# Iterate over each file in the photo directory
while read -r file; do
  # Get filename
  filename=$(basename "$file")

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
      echo "rm '$file' # identical file found in $date_folder/$filename" >> "$rm_commands"
    fi
  fi
done < "$root_photos"

# Make the rm commands file executable
chmod +x "$rm_commands"

echo "Duplicate check complete."
echo "Output files generated:"
echo "- $rm_commands: Commands to remove duplicate files."
echo "- $root_photos: List of photo paths in the root directory."
echo "- $date_sorted_photos: List of photo paths in the date-sorted directory."
