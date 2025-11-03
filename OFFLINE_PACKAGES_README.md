# SQLMesh Offline Package Download Guide

This guide explains how to download and update SQLMesh wheels for offline/air-gapped environments.

## Quick Start

### Download Wheels (Default: Python 3.11)

**Linux/macOS:**
```bash
./download_wheels.sh
```

**Windows or any platform:**
```bash
python download_wheels.py
```

### Download for Different Python Version

**Linux/macOS:**
```bash
./download_wheels.sh 3.10    # For Python 3.10
./download_wheels.sh 3.12    # For Python 3.12
```

**Windows or any platform:**
```bash
python download_wheels.py 3.10
python download_wheels.py 3.12
```

---

## Scripts Overview

### 1. `download_wheels.sh` (Bash Script)
- **Platform:** Linux, macOS, WSL
- **Usage:** `./download_wheels.sh [python_version]`
- **Default:** Python 3.11

### 2. `download_wheels.py` (Python Script)
- **Platform:** Windows, Linux, macOS (cross-platform)
- **Usage:** `python download_wheels.py [python_version]`
- **Default:** Python 3.11

Both scripts do the same thing - use whichever works best for your environment.

---

## What Gets Downloaded

The scripts download:
- ✓ SQLMesh core package
- ✓ All Python dependencies (~60 packages)
- ✓ Platform-specific binary wheels
- ✓ Fabric/ODBC connectivity packages
- ✓ Data processing libraries (pandas, numpy, duckdb)

**Total size:** ~65-70 MB

**Output directory:** `wheels_py<version>` (e.g., `wheels_py311` for Python 3.11)

---

## Determining Your Python Version

### In Fabric Environment:
```python
import sys
print(f"Python {sys.version_info.major}.{sys.version_info.minor}")
```

### Common Python Versions:
- **Microsoft Fabric:** Python 3.11 (most common)
- **Databricks:** Python 3.10 or 3.11
- **Local development:** Check with `python --version`

---

## Step-by-Step: Download and Transfer

### Step 1: Run Download Script (on machine WITH internet)

```bash
# For Python 3.11 (most common in Fabric)
python download_wheels.py 3.11

# Output will be in: wheels_py311/
```

### Step 2: Verify Download

```bash
ls wheels_py311/
# Should see ~60 .whl files and INSTALL.txt
```

### Step 3: Transfer to Secure Environment

**Option A: Upload to Fabric Lakehouse**
```
Upload wheels_py311/ to:
/lakehouse/default/Files/libraries/wheels_py311/
```

**Option B: Copy via USB/Network**
```bash
# Copy entire directory
cp -r wheels_py311/ /path/to/secure/environment/
```

### Step 4: Install in Secure Environment

```bash
pip install --no-index --find-links=wheels_py311/ sqlmesh
```

---

## When to Re-download Wheels

Re-run the download script when:

1. **SQLMesh updates** - New features or bug fixes
   ```bash
   python download_wheels.py 3.11
   ```

2. **Python version changes** - Environment upgraded
   ```bash
   python download_wheels.py 3.12
   ```

3. **Dependency updates** - Security patches or improvements
   ```bash
   # Just re-run the same command
   python download_wheels.py 3.11
   ```

4. **Platform changes** - Moving from dev to production environment
   ```bash
   # The script already targets Linux x86_64
   # For other platforms, modify the --platform flag
   ```

---

## Advanced Usage

### Download for Multiple Python Versions

```bash
# Download for all common versions
python download_wheels.py 3.10
python download_wheels.py 3.11
python download_wheels.py 3.12

# You'll have:
# - wheels_py310/
# - wheels_py311/
# - wheels_py312/
```

### Check What Would Be Downloaded (Dry Run)

```bash
pip download \
    --python-version 3.11 \
    --platform manylinux2014_x86_64 \
    --only-binary=:all: \
    sqlmesh[fabric] \
    --dry-run
```

### Download for Specific SQLMesh Version

Edit the script and change:
```bash
sqlmesh[fabric]
```
to:
```bash
sqlmesh[fabric]==0.227.1
```

---

## Troubleshooting

### Issue: "pip: command not found"
**Solution:**
```bash
# Install pip first
python -m ensurepip --upgrade
```

### Issue: "No matching distribution found"
**Solution:**
- Check Python version is valid (3.9, 3.10, 3.11, 3.12)
- Some very new/old versions may not have binary wheels
- Try a different Python version

### Issue: "Permission denied"
**Solution:**
```bash
# Make script executable
chmod +x download_wheels.sh
chmod +x download_wheels.py

# Or run with explicit interpreter
bash download_wheels.sh
python3 download_wheels.py
```

### Issue: Download is very slow
**Solution:**
- Check internet connection
- Downloads are ~65-70 MB total
- May take a few minutes on slow connections

---

## Script Customization

### Download for Different Platform

Edit `download_wheels.py` or `download_wheels.sh` and change:
```python
--platform manylinux2014_x86_64
```

**Common platforms:**
- `manylinux2014_x86_64` - Linux 64-bit (default)
- `win_amd64` - Windows 64-bit
- `macosx_11_0_arm64` - macOS Apple Silicon
- `macosx_10_9_x86_64` - macOS Intel

### Add Additional Packages

Edit the script and add to the download list:
```bash
pip download \
    sqlmesh[fabric] \
    some-other-package \
    another-package \
    -d wheels_py311/
```

---

## Files Created by Script

After running the script, you'll have:

```
wheels_py311/
├── INSTALL.txt                    # Installation instructions
├── sqlmesh-0.227.1-py3-none-any.whl
├── pyodbc-5.3.0-cp311-...whl
├── pandas-2.3.2-cp311-...whl
├── numpy-2.2.6-cp311-...whl
└── ... (57 more .whl files)
```

---

## Automation

### Scheduled Updates (Optional)

Create a cron job to auto-download weekly:

```bash
# Edit crontab
crontab -e

# Add line to run every Sunday at 2 AM
0 2 * * 0 cd /path/to/sql-mesh && python download_wheels.py 3.11
```

### CI/CD Integration

Add to your CI pipeline:

```yaml
# .github/workflows/download-wheels.yml
name: Download Offline Wheels
on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly
  workflow_dispatch:      # Manual trigger

jobs:
  download:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Download wheels
        run: python download_wheels.py 3.11
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: sqlmesh-wheels
          path: wheels_py311/
```

---

## Version History

Track what you've downloaded:

```bash
# Check SQLMesh version in downloaded wheels
unzip -p wheels_py311/sqlmesh-*.whl */METADATA | grep Version:

# Or check all packages
for wheel in wheels_py311/*.whl; do
    basename "$wheel"
done | sort
```

---

## Summary

✅ **Two scripts available:** Bash and Python (use either)
✅ **Easy to use:** Just specify Python version
✅ **Automatic:** Downloads all dependencies
✅ **Repeatable:** Re-run anytime for updates
✅ **Self-documented:** Creates INSTALL.txt in output

**Recommended workflow:**
1. Run monthly to get latest updates: `python download_wheels.py 3.11`
2. Transfer to secure environment
3. Install with: `pip install --no-index --find-links=wheels_py311/ sqlmesh`
4. Test with scripts in TESTING_GUIDE.md

---

## Additional Resources

- [TESTING_GUIDE.md](TESTING_GUIDE.md) - How to test installation
- [PYTHON_VERSION_FIX.md](PYTHON_VERSION_FIX.md) - Troubleshooting version issues
- [PACKAGE_SUMMARY.md](PACKAGE_SUMMARY.md) - What's included in the wheels
