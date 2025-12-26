# Scripts

This directory contains utility scripts for the AppFlowy Editor project.

## verify.sh

Runs code quality checks including formatting, analysis, and linting.

### Usage

```bash
./scripts/verify.sh
```

Or from the project root:

```bash
bash scripts/verify.sh
```

### What it does

The script runs three checks in sequence:

1. **Code Formatting** (`fvm dart format .`)
   - Checks if code is properly formatted
   - Automatically applies formatting if needed
   - Ensures consistent code style across the project

2. **Dart Analysis** (`fvm dart analyze .`)
   - Runs static analysis on the code
   - Checks for errors, warnings, and lints
   - Attempts to apply automatic fixes if issues are found

3. **Custom Lint** (`fvm dart run custom_lint`)
   - Runs custom linting rules specific to the project
   - Applies fixes for fixable issues using `--fix` flag
   - Ensures code follows project-specific guidelines

### Requirements

- FVM (Flutter Version Management) must be installed
- Run `fvm flutter pub get` first to install dependencies

### Exit Codes

- `0`: All checks passed successfully
- `1`: One or more checks failed

### Tips

- Run this script before committing code
- The script will attempt to fix issues automatically
- Review the output to understand what was changed
- If issues persist after fixes, manual intervention may be required

### CI/CD Integration

This script can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions step
- name: Run verification
  run: ./scripts/verify.sh
```

## Adding New Scripts

When adding new scripts to this directory:

1. Make them executable: `chmod +x scripts/your-script.sh`
2. Add shebang at the top: `#!/bin/bash`
3. Document the script in this README
4. Use `set -e` to exit on errors
5. Add clear echo statements for progress
