# ddysk

A bash script to visualize large directories and files in a tree-like structure. `ddysk` helps you quickly identify what's taking up space on your disk by scanning directories and displaying folders and files above a specified size threshold.

## Features

- 🔍 Find large folders and files recursively
- 📊 Display results in a tree-like structure
- ⚙️ Configurable minimum size threshold
- 🎯 Configurable maximum search depth
- 🚫 Automatically excludes hidden files and directories
- 📁 Shows both folder sizes and individual large files

## Requirements

- Bash shell
- Standard Unix utilities: `find`, `du`, `sort`, `awk`

## Installation

1. Clone or download this repository
2. Make the script executable:
   ```bash
   chmod +x script.sh
   ```

## Usage

```bash
./script.sh [OPTIONS]
```

### Options

- `-p, --path PATH` - Starting path to search (default: current directory `.`)
- `-s, --size SIZE` - Minimum size in MB (default: 500)
- `-h, --help` - Show help message

### Examples

Scan current directory for items ≥ 500MB:
```bash
./script.sh
```

Scan a specific directory for items ≥ 100MB:
```bash
./script.sh -p /home/user -s 100
```

Scan current directory for items ≥ 50MB:
```bash
./script.sh -s 50
```

## Output Format

The script displays results in a tree structure:
- 📁 Folders are marked with a folder icon
- 📄 Files are marked with a file icon
- Each entry shows the name and size in MB
- Tree characters (`│`, `├──`) indicate the directory hierarchy

## Notes

- Hidden files and directories (starting with `.`) are excluded from the search
- The script uses temporary files in `/tmp` for sorting
- Folder sizes represent the total size including all contents
