#!/bin/bash

# AppFlowy Editor - Verification Script
# This script runs code formatting, analysis, and linting checks

echo "🔍 Starting verification process..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if dependencies are installed
if [ ! -d ".dart_tool" ]; then
    echo -e "${YELLOW}⚠ Dependencies not found. Installing...${NC}"
    fvm flutter pub get
    echo ""
fi

set -e  # Exit on error after dependency check

# Step 1: Format code
echo "📝 Step 1/3: Formatting code..."
if fvm dart format . --set-exit-if-changed; then
    echo -e "${GREEN}✓ Code is properly formatted${NC}"
else
    echo -e "${YELLOW}⚠ Code formatting issues found. Applying fixes...${NC}"
    fvm dart format .
    echo -e "${GREEN}✓ Code formatted${NC}"
fi
echo ""

# Step 2: Run dart analyze
echo "🔬 Step 2/3: Running dart analyze..."
if fvm dart analyze .; then
    echo -e "${GREEN}✓ No analysis issues found${NC}"
else
    echo -e "${RED}✗ Analysis issues found${NC}"
    echo -e "${YELLOW}Attempting to apply fixes...${NC}"
    fvm dart fix --apply
    echo -e "${YELLOW}Re-running analysis after fixes...${NC}"
    fvm dart analyze .
fi
echo ""

# Step 3: Run custom_lint
echo "🧹 Step 3/3: Running custom_lint..."
if fvm dart run custom_lint; then
    echo -e "${GREEN}✓ No custom lint issues found${NC}"
else
    echo -e "${YELLOW}⚠ Custom lint issues found. Applying fixes...${NC}"
    fvm dart run custom_lint --fix
    echo -e "${GREEN}✓ Custom lint checks completed${NC}"
fi
echo ""

echo -e "${GREEN}✅ Verification complete!${NC}"
echo ""
echo "Summary:"
echo "  - Code formatting: ✓"
echo "  - Dart analyze: ✓"
echo "  - Custom lint: ✓"
