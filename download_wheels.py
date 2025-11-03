#!/usr/bin/env python3
"""
Download SQLMesh wheels for offline/air-gapped environments
Works on Windows, Linux, and macOS

Usage:
    python download_wheels.py              # Downloads for Python 3.11 (default)
    python download_wheels.py 3.10         # Downloads for Python 3.10
    python download_wheels.py 3.12         # Downloads for Python 3.12
"""

import sys
import subprocess
import os
from pathlib import Path
from datetime import datetime

def download_wheels(python_version="3.11"):
    """Download SQLMesh wheels for specified Python version"""

    # Validate Python version
    try:
        major, minor = python_version.split('.')
        if major != '3' or not minor.isdigit():
            raise ValueError()
    except (ValueError, AttributeError):
        print(f"Error: Invalid Python version '{python_version}'")
        print("Use format: 3.11, 3.10, 3.12, etc.")
        return False

    print("=" * 70)
    print("SQLMesh Wheel Downloader for Offline Environments")
    print("=" * 70)
    print()
    print(f"Target Python version: {python_version}")
    print(f"Platform: Linux x86_64 (manylinux)")
    print()

    # Create output directory
    output_dir = f"wheels_py{python_version.replace('.', '')}"
    Path(output_dir).mkdir(exist_ok=True)

    print(f"Output directory: {output_dir}")
    print()
    print("Downloading SQLMesh and all dependencies...")
    print()

    # Build pip download command
    cmd = [
        sys.executable, "-m", "pip", "download",
        "--python-version", python_version,
        "--platform", "manylinux2014_x86_64",
        "--only-binary=:all:",
        "sqlmesh[fabric]",
        "-d", f"{output_dir}/"
    ]

    # Run download
    try:
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        print(result.stdout)
    except subprocess.CalledProcessError as e:
        print("=" * 70)
        print("Download Failed!")
        print("=" * 70)
        print()
        print(f"Error: {e}")
        print(f"Output: {e.stdout}")
        print(f"Error output: {e.stderr}")
        print()
        print("Common issues:")
        print("  - Check internet connection")
        print("  - Verify Python version is valid")
        print("  - Some packages may not have binary wheels for this version")
        return False

    print()
    print("=" * 70)
    print("Download Complete!")
    print("=" * 70)
    print()

    # Get file count and size
    wheel_files = list(Path(output_dir).glob("*.whl"))
    file_count = len(wheel_files)

    # Calculate directory size
    total_size = sum(f.stat().st_size for f in wheel_files)
    size_mb = total_size / (1024 * 1024)

    print("Summary:")
    print(f"  - Wheel files: {file_count}")
    print(f"  - Total size: {size_mb:.1f} MB")
    print(f"  - Location: {Path(output_dir).absolute()}")
    print()
    print("Next steps:")
    print(f"  1. Transfer the '{output_dir}' directory to your secure environment")
    print(f"  2. Install with: pip install --no-index --find-links={output_dir}/ sqlmesh")
    print()

    # Create installation instructions
    install_txt = Path(output_dir) / "INSTALL.txt"
    with open(install_txt, 'w') as f:
        f.write(f"""SQLMesh Offline Installation - Python {python_version}
{'=' * 70}

Installation Command:
{'-' * 70}
pip install --no-index --find-links=. sqlmesh

Or install all wheels:
{'-' * 70}
pip install --no-index --find-links=. *.whl

Verify Installation:
{'-' * 70}
python -c "import sqlmesh; print(f'SQLMesh {{sqlmesh.__version__}}')"

System Requirements:
{'-' * 70}
- Python {python_version}
- Linux x86_64
- Microsoft ODBC Driver 18 for SQL Server (for Fabric connectivity)

Files Downloaded: {file_count} wheels (~{size_mb:.1f} MB)
Downloaded: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

For detailed instructions, see TESTING_GUIDE.md in the main project directory.
""")

    print(f"Installation instructions saved to: {install_txt}")
    print()
    print("=" * 70)

    return True


if __name__ == "__main__":
    # Get Python version from command line or use default
    python_version = sys.argv[1] if len(sys.argv) > 1 else "3.11"

    # Download wheels
    success = download_wheels(python_version)

    # Exit with appropriate code
    sys.exit(0 if success else 1)
