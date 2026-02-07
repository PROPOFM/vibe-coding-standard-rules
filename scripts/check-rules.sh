#!/bin/bash
# Check script to verify .ai-rules submodule contents
# This script helps verify that the submodule is properly initialized and files are accessible

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RULES_DIR="${PROJECT_ROOT}/.ai-rules"

echo "🔍 Checking .ai-rules submodule contents..."
echo ""

# Check if .ai-rules exists
if [ ! -d "${RULES_DIR}" ]; then
    echo "❌ Error: .ai-rules directory not found"
    echo "Please add the submodule first:"
    echo "  git submodule add https://github.com/your-org/vibe-coding-standard-rules.git .ai-rules"
    exit 1
fi

echo "✅ .ai-rules directory exists"
echo ""

# Check directory structure
echo "📁 Directory structure:"
echo "---"
cd "${RULES_DIR}"
ls -la | grep -E "^d" | awk '{print "  " $9}'
echo ""

# Check core directory
echo "📂 core/ directory:"
if [ -d "core" ]; then
    echo "  Files in core/:"
    ls -1 core/ 2>/dev/null | sed 's/^/    - /' || echo "    (empty or .gitkeep only)"
else
    echo "  ❌ core/ directory not found"
fi
echo ""

# Check claude-code directory
echo "📂 claude-code/ directory:"
if [ -d "claude-code" ]; then
    echo "  Subdirectories:"
    find claude-code -maxdepth 1 -type d | sed 's|^|    |'
    echo ""
    echo "  Files in claude-code/:"
    find claude-code -maxdepth 2 -type f -name "*.md" -o -name "*.json" -o -name "*.base" | head -10 | sed 's|^|    |'
else
    echo "  ❌ claude-code/ directory not found"
fi
echo ""

# Check cursor directory
echo "📂 cursor/ directory:"
if [ -d "cursor" ]; then
    echo "  Files in cursor/:"
    find cursor -type f | sed 's|^|    |'
else
    echo "  ❌ cursor/ directory not found"
fi
echo ""

# Check for referenced files in .cursorrules (if exists)
if [ -f "${PROJECT_ROOT}/.cursorrules" ]; then
    echo "📄 Checking files referenced in .cursorrules:"
    echo "---"
    while IFS= read -r line; do
        if [[ "$line" =~ \.ai-rules/ ]]; then
            file_path=$(echo "$line" | sed -E 's/.*- (.+)$/\1/' | xargs)
            if [ -n "$file_path" ] && [[ "$file_path" =~ \.(md|base)$ ]]; then
                full_path="${RULES_DIR}/${file_path}"
                if [ -f "$full_path" ]; then
                    echo "  ✅ $file_path"
                else
                    echo "  ⚠️  $file_path (not found - will be created later)"
                fi
            fi
        fi
    done < "${PROJECT_ROOT}/.cursorrules"
    echo ""
fi

# Summary
echo "📊 Summary:"
echo "---"
echo "  Core rules: $(find core -name "*.md" 2>/dev/null | wc -l | xargs) files"
echo "  Claude Code agents: $(find claude-code/agents -name "*.md" 2>/dev/null | wc -l | xargs) files"
echo "  Claude Code skills: $(find claude-code/skills -name "*.md" 2>/dev/null | wc -l | xargs) files"
echo "  Claude Code commands: $(find claude-code/commands -name "*.md" 2>/dev/null | wc -l | xargs) files"
echo "  Claude Code rules: $(find claude-code/rules -name "*.md" 2>/dev/null | wc -l | xargs) files"
echo "  Cursor skills: $(find cursor/skills -name "*.md" 2>/dev/null | wc -l | xargs) files"
echo ""

echo "💡 Tip: Use 'cat .ai-rules/core/base-prompt.md' to view a specific file"
echo "💡 Tip: Use 'find .ai-rules -name \"*.md\"' to find all markdown files"

