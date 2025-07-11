#!/bin/bash

cd "$(dirname "$0")/.."
output_dir="generated"
mkdir -p "$output_dir"
output_file="$output_dir/modlist.txt"

echo "Starting modlist generation..."
echo "Output directory: $output_dir"
echo "Output file: $output_file"

>"$output_file"

for file in mods/*.toml; do
    echo "Processing file: $file"
    name=$(grep '^name = "' "$file" | sed -E 's/name = "(.*)"/\1/')
    modid=$(grep 'mod-id = "' "$file" | sed -E 's/mod-id = "(.*)"/\1/')
    if [ -n "$name" ] && [ -n "$modid" ]; then
        echo "Found mod: $name (mod-id: $modid)"
        echo "$name -> https://modrinth.com/mod/$modid" >>"$output_file"
    else
        echo "Skipping file: $file (missing name or mod-id)"
    fi
done

echo "Modlist generation completed."
echo "Generated modlist saved to $output_file"
