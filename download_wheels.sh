#!/bin/bash
#
# Download SQLMesh wheels for offline/air-gapped environments
# Usage: ./download_wheels.sh [python_version]
# Example: ./download_wheels.sh 3.11
#

set -e

# Default Python version (common in Fabric environments)
DEFAULT_PYTHON_VERSION="3.11"

# Get Python version from argument or use default
PYTHON_VERSION="${1:-$DEFAULT_PYTHON_VERSION}"

# Validate Python version format
if ! [[ "$PYTHON_VERSION" =~ ^3\.[0-9]+$ ]]; then
    echo "Error: Invalid Python version format. Use format like: 3.11, 3.10, 3.12"
    exit 1
fi

echo "============================================================"
echo "SQLMesh Wheel Downloader for Offline Environments"
echo "============================================================"
echo
echo "Target Python version: $PYTHON_VERSION"
echo "Platform: Linux x86_64 (manylinux)"
echo

# Create output directory
OUTPUT_DIR="wheels_py${PYTHON_VERSION//./}"
mkdir -p "$OUTPUT_DIR"

echo "Output directory: $OUTPUT_DIR"
echo

# Check if pip is available
if ! command -v pip &> /dev/null; then
    echo "Error: pip not found. Please install pip first."
    exit 1
fi

echo "Downloading SQLMesh and all dependencies..."
echo

# Download wheels
pip download \
    --python-version "$PYTHON_VERSION" \
    --platform manylinux2014_x86_64 \
    --only-binary=:all: \
    sqlmesh[fabric] \
    -d "$OUTPUT_DIR/"

DOWNLOAD_EXIT_CODE=$?

echo
echo "============================================================"

if [ $DOWNLOAD_EXIT_CODE -eq 0 ]; then
    echo "Download Complete!"
    echo "============================================================"
    echo

    # Count files and get size
    FILE_COUNT=$(ls -1 "$OUTPUT_DIR"/*.whl 2>/dev/null | wc -l)
    DIR_SIZE=$(du -sh "$OUTPUT_DIR" | cut -f1)

    echo "Summary:"
    echo "  - Wheel files: $FILE_COUNT"
    echo "  - Total size: $DIR_SIZE"
    echo "  - Location: $(pwd)/$OUTPUT_DIR"
    echo
    echo "Next steps:"
    echo "  1. Transfer the '$OUTPUT_DIR' directory to your secure environment"
    echo "  2. Install with: pip install --no-index --find-links=$OUTPUT_DIR/ sqlmesh"
    echo

    # Create installation instructions file
    cat > "$OUTPUT_DIR/INSTALL.txt" << EOF
SQLMesh Offline Installation - Python $PYTHON_VERSION
====================================================

Installation Command:
--------------------
pip install --no-index --find-links=. sqlmesh

Or install all wheels:
---------------------
pip install --no-index --find-links=. *.whl

Verify Installation:
-------------------
python -c "import sqlmesh; print(f'SQLMesh {sqlmesh.__version__}')"

System Requirements:
-------------------
- Python $PYTHON_VERSION
- Linux x86_64
- Microsoft ODBC Driver 18 for SQL Server (for Fabric connectivity)

Files Downloaded: $FILE_COUNT wheels (~$DIR_SIZE)
Downloaded: $(date)

For detailed instructions, see TESTING_GUIDE.md in the main project directory.
EOF

    echo "Installation instructions saved to: $OUTPUT_DIR/INSTALL.txt"

else
    echo "Download Failed!"
    echo "============================================================"
    echo
    echo "Common issues:"
    echo "  - Check internet connection"
    echo "  - Verify Python version is valid (e.g., 3.11, 3.10, 3.12)"
    echo "  - Some packages may not have binary wheels for this version"
    echo
    exit 1
fi

echo "============================================================"
