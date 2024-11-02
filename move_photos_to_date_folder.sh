#!/bin/bash

# Check if directory argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/photo_directory"
    exit 1
fi

# Set the directory containing the photos from the argument
photo_dir="$1"

# Output files
file_list="file_list.txt"
move_commands="move_commands.sh"
new_paths="new_paths.txt"
processed_temp="processed_files.tmp"

# Initialize output files
> "$file_list"
> "$move_commands"
> "$new_paths"
> "$processed_temp"

# Function to get the capture date in YYYY-MM-DD format
get_capture_date() {
    exiftool -d "%Y-%m-%d" -DateTimeOriginal "$1" | awk -F': ' '{print $2}'
}

# Step 1: Process non-JPEG primary files (e.g., RAW, TIFF, etc.)
find "$photo_dir" -maxdepth 1 -type f \( -iname "*.cr2" -o -iname "*.cr3" -o -iname "*.nef" -o -iname "*.nrw" -o -iname "*.arw" -o -iname "*.orf" -o -iname "*.rw2" -o -iname "*.dng" -o -iname "*.raf" -o -iname "*.sr2" -o -iname "*.pef" -o -iname "*.tiff" -o -iname "*.bmp" \) | while read -r file; do

    # Get the file basename without extension
    basename=$(basename "$file")
    name="${basename%.*}"

    # Skip if this file has already been processed
    if grep -Fxq "$name" "$processed_temp"; then
        continue
    fi

    # Mark as processed
    echo "$name" >> "$processed_temp"

    # Find sidecar .jpg and .xmp files
    primary_file="$file"
    sidecar_jpg=""
    sidecar_xmp=""
    [[ -f "$photo_dir/$name.jpg" ]] && sidecar_jpg="$photo_dir/$name.jpg" && echo "$name.jpg" >> "$processed_temp"
    [[ -f "$photo_dir/$name.jpeg" ]] && sidecar_jpg="$photo_dir/$name.jpeg" && echo "$name.jpeg" >> "$processed_temp"
    [[ -f "$photo_dir/$name.xmp" ]] && sidecar_xmp="$photo_dir/$name.xmp" && echo "$name.xmp" >> "$processed_temp"

    # Get capture date for primary file
    capture_date=$(get_capture_date "$primary_file")
    if [[ -z "$capture_date" ]]; then
        echo "Skipping $primary_file as no capture date is found."
        continue
    fi

    # Construct the destination directory based on the capture date
    year=${capture_date:0:4}
    date_folder="$photo_dir/$year/$capture_date"

    # Record the primary file and sidecars in file_list
    echo "$primary_file" >> "$file_list"
    #[[ -n "$sidecar_jpg" ]] && echo "$sidecar_jpg" >> "$file_list"
    #[[ -n "$sidecar_xmp" ]] && echo "$sidecar_xmp" >> "$file_list"
    # Add mkdir and move commands for primary file and sidecars
    echo "mkdir -p '$date_folder'" >> "$move_commands"
    primary_dest="$date_folder/$(basename "$primary_file")"
    echo "mv '$primary_file' '$primary_dest'" >> "$move_commands"
    [[ -n "$sidecar_jpg" ]] && echo "mv '$sidecar_jpg' '$date_folder/$(basename "$sidecar_jpg")'" >> "$move_commands"
    [[ -n "$sidecar_xmp" ]] && echo "mv '$sidecar_xmp' '$date_folder/$(basename "$sidecar_xmp")'" >> "$move_commands"

    # Record the new path for primary file only
    echo "$primary_dest" >> "$new_paths"
done

# Step 2: Process standalone JPEG files (those without matching RAW files)
find "$photo_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) | while read -r file; do

    # Get the file basename without extension
    basename=$(basename "$file")
    name="${basename%.*}"

    # Skip if this file has already been processed as a sidecar
    if grep -Fxq "$name" "$processed_temp"; then
        continue
    fi

    # Mark as processed
    echo "$name" >> "$processed_temp"

    # This is a standalone JPEG, so treat it as a primary file
    primary_file="$file"
    sidecar_xmp=""
    [[ -f "$photo_dir/$name.xmp" ]] && sidecar_xmp="$photo_dir/$name.xmp" && echo "$name.xmp" >> "$processed_temp"

    # Get capture date for the standalone JPEG
    capture_date=$(get_capture_date "$primary_file")
    if [[ -z "$capture_date" ]]; then
        echo "Skipping $primary_file as no capture date is found."
        continue
    fi

    # Construct the destination directory based on the capture date
    year=${capture_date:0:4}
    date_folder="$photo_dir/$year/$capture_date"

    # Record the primary file and sidecar in file_list
    echo "$primary_file" >> "$file_list"
    [[ -n "$sidecar_xmp" ]] && echo "$sidecar_xmp" >> "$file_list"

    # Add mkdir and move commands for primary file and sidecar
    echo "mkdir -p '$date_folder'" >> "$move_commands"
    primary_dest="$date_folder/$(basename "$primary_file")"
    echo "mv '$primary_file' '$primary_dest'" >> "$move_commands"
    [[ -n "$sidecar_xmp" ]] && echo "mv '$sidecar_xmp' '$date_folder/$(basename "$sidecar_xmp")'" >> "$move_commands"

    # Record the new path for primary file only
    echo "$primary_dest" >> "$new_paths"
done

# Clean up the temporary processed file
rm "$processed_temp"

echo "File list saved to $file_list"
echo "Move commands saved to $move_commands"
echo "New paths saved to $new_paths"
