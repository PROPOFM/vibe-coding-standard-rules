#!/bin/bash
# Validation script for AI rules
# This script validates that all referenced rule files exist

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0

echo "🔍 Validating AI rules..."

# Check if .cursorrules exists
if [ -f "${PROJECT_ROOT}/.cursorrules" ]; then
    echo "📄 Checking .cursorrules..."
    while IFS= read -r line; do
        # Extract file paths from .cursorrules
        if [[ "$line" =~ \.ai-rules/ ]] || [[ "$line" =~ \.rules/ ]]; then
            file_path=$(echo "$line" | sed -E 's/.*- (.+)$/\1/' | xargs)
            if [ -n "$file_path" ] && [[ "$file_path" =~ \.(md|base)$ ]]; then
                full_path="${PROJECT_ROOT}/${file_path}"
                if [ ! -f "$full_path" ]; then
                    echo "❌ Missing file: $file_path"
                    ERRORS=$((ERRORS + 1))
                fi
            fi
        fi
    done < "${PROJECT_ROOT}/.cursorrules"
fi

# Check if .clauderules exists
if [ -f "${PROJECT_ROOT}/.clauderules" ]; then
    echo "📄 Checking .clauderules..."
    while IFS= read -r line; do
        # Extract file paths from .clauderules
        if [[ "$line" =~ \.ai-rules/ ]] || [[ "$line" =~ \.rules/ ]]; then
            file_path=$(echo "$line" | sed -E 's/.*: `(.+)`.*/\1/' | xargs)
            if [ -n "$file_path" ] && [[ "$file_path" =~ \.(md|base)$ ]]; then
                full_path="${PROJECT_ROOT}/${file_path}"
                if [ ! -f "$full_path" ]; then
                    echo "❌ Missing file: $file_path"
                    ERRORS=$((ERRORS + 1))
                fi
            fi
        fi
    done < "${PROJECT_ROOT}/.clauderules"
fi

# Check core rule files
echo "📁 Checking core rule files..."
CORE_FILES=(
    "core/base-prompt.md"
    "core/coding-style.md"
    "core/architecture.md"
    "core/test-standard.md"
    "core/security.md"
    "core/error-handling.md"
    "core/logging.md"
    "core/configuration.md"
    "core/code-review.md"
    "core/development-process.md"
    "core/documentation.md"
)

for file in "${CORE_FILES[@]}"; do
    if [ ! -f "${PROJECT_ROOT}/${file}" ]; then
        echo "⚠️  Core file not found (expected in future): ${file}"
    fi
done

if [ $ERRORS -eq 0 ]; then
    echo "✅ All referenced rule files exist!"
    exit 0
else
    echo "❌ Found $ERRORS missing file(s)"
    exit 1
fi

