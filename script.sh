#!/usr/bin/env bash

# Default values
START_PATH="."
MIN_SIZE_MB=500
MAX_DEPTH=4
# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--path)
            START_PATH="$2"
            shift 2
            ;;
        -s|--size)
            MIN_SIZE_MB="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [-p path] [-s size_mb] [-d depth]"
            echo ""
            echo "Options:"
            echo "  -p, --path PATH     Starting path (default: current directory '.')"
            echo "  -s, --size SIZE     Minimum size in MB (default: 500)"

            echo "  -h, --help          Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 -p /home/user -s 100 -d 3"
            echo "  $0 -s 50"
            echo "  $0 -p . -s 200 -d 5"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

MIN_SIZE_KB=$((MIN_SIZE_MB * 1024))

# Convert to absolute path if current directory
if [ "$START_PATH" = "." ]; then
    START_PATH="$(pwd)"
fi

if [ ! -d "$START_PATH" ]; then
    echo "❌ Path '$START_PATH' does not exist."
    exit 1
fi

echo "📂 Folders & Files ≥ $MIN_SIZE_MB MB under '$START_PATH' (depth ≤ $MAX_DEPTH):"
echo ""

# Collect folders with their total sizes
find "$START_PATH" -maxdepth "$MAX_DEPTH" -type d ! -path "*/.*" | while read -r dir; do
    SIZE_KB=$(du -sk --exclude=".*" "$dir" 2>/dev/null | awk '{print $1}')
    if [ "$SIZE_KB" -ge "$MIN_SIZE_KB" ]; then
        echo "d|$dir|$SIZE_KB"
    fi
done > /tmp/folder_sizes_$$

# Collect large files
find "$START_PATH" -maxdepth "$MAX_DEPTH" -type f ! -path "*/.*" -size "+${MIN_SIZE_MB}M" 2>/dev/null | while read -r file; do
    SIZE_KB=$(du -sk "$file" 2>/dev/null | awk '{print $1}')
    echo "f|$file|$SIZE_KB"
done >> /tmp/folder_sizes_$$

# Sort by path
sort -t'|' -k2 /tmp/folder_sizes_$$ > /tmp/sorted_$$

# Read and display in tree structure
while IFS='|' read -r type path size_kb; do
    size_mb=$((size_kb/1024))
    
    # Calculate depth relative to START_PATH
    relative_path="${path#$START_PATH}"
    relative_path="${relative_path#/}"
    
    if [ -z "$relative_path" ]; then
        # Root folder
        echo "📁 $(basename "$path") - ${size_mb} MB"
    else
        # Count depth by number of slashes
        depth=$(echo "$relative_path" | tr -cd '/' | wc -c)
        
        # Create indentation
        indent=""
        for ((i=0; i<depth; i++)); do
            indent="${indent}│   "
        done
        
        # Use appropriate icon
        if [ "$type" = "d" ]; then
            icon="📁"
        else
            icon="📄"
        fi
        
        # Use tree characters
        echo "${indent}├── $icon $(basename "$path") - ${size_mb} MB"
    fi
done < /tmp/sorted_$$

# Cleanup
rm -f /tmp/folder_sizes_$$ /tmp/sorted_$$