#!/bin/bash

# Configuration
PROJECT_ROOT=~/yocto_13_12
OUTPUT_FILE=~/yocto_project_map.txt

# Start fresh
echo "Generating Project Map for: $PROJECT_ROOT"
echo "==========================================" > "$OUTPUT_FILE"
echo " PROJECT SNAPSHOT: $(date)" >> "$OUTPUT_FILE"
echo "==========================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# ---------------------------------------------------------
# 1. CAPTURE LOCAL.CONF
# ---------------------------------------------------------
echo "Processing: build/conf/local.conf..."
cd "$PROJECT_ROOT" || exit

echo "### FILE: build/conf/local.conf ###" >> "$OUTPUT_FILE"
cat build/conf/local.conf >> "$OUTPUT_FILE"
echo -e "\n\n" >> "$OUTPUT_FILE"

# ---------------------------------------------------------
# 2. CAPTURE META-CUSTOM-MINIMAL (Structure + Content)
# ---------------------------------------------------------
echo "Processing: meta-custom-minimal (Structure & Content)..."

# Find all files in meta-custom-minimal, excluding git and hidden files
# We utilize a loop to format the output nicely
find meta-custom-minimal -type f -not -path '*/.*' | sort | while read -r file; do
    echo "--------------------------------------------------" >> "$OUTPUT_FILE"
    echo "FILE: $file" >> "$OUTPUT_FILE"
    echo "--------------------------------------------------" >> "$OUTPUT_FILE"
    cat "$file" >> "$OUTPUT_FILE"
    echo -e "\n" >> "$OUTPUT_FILE"
done

# ---------------------------------------------------------
# 3. CAPTURE SOURCES (Structure Only)
# ---------------------------------------------------------
echo "Processing: sources (Directory Structure Only)..."

echo "==========================================" >> "$OUTPUT_FILE"
echo " FOLDER STRUCTURE: sources" >> "$OUTPUT_FILE"
echo " (Content omitted for external layers)" >> "$OUTPUT_FILE"
echo "==========================================" >> "$OUTPUT_FILE"

# List the immediate layers inside sources
ls -F sources/ >> "$OUTPUT_FILE"

# List the contents of meta-openembedded (common dependency) to show sub-layers
if [ -d "sources/meta-openembedded" ]; then
    echo -e "\n--- Inside meta-openembedded ---" >> "$OUTPUT_FILE"
    ls -F sources/meta-openembedded/ >> "$OUTPUT_FILE"
fi

echo ""
echo "Done! The map has been saved to: $OUTPUT_FILE"
echo "You can view it with: cat $OUTPUT_FILE"
