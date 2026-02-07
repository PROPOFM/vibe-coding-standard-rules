#!/bin/bash
# Setup script for AI rules submodule
# This script helps set up the AI rules in a project

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RULES_DIR="${PROJECT_ROOT}/.ai-rules"

echo "🚀 Setting up AI rules..."

# Check if .ai-rules exists
if [ ! -d "${RULES_DIR}" ]; then
    echo "❌ Error: .ai-rules directory not found"
    echo "Please add the submodule first:"
    echo "  git submodule add https://github.com/your-org/vibe-coding-standard-rules.git .ai-rules"
    exit 1
fi

# Check if .rules directory exists, create if not
RULES_PROJECT_DIR="${PROJECT_ROOT}/.rules"
if [ ! -d "${RULES_PROJECT_DIR}" ]; then
    echo "📁 Creating .rules directory..."
    mkdir -p "${RULES_PROJECT_DIR}"
fi

# Copy templates if they don't exist
if [ ! -f "${RULES_PROJECT_DIR}/project-specs.md" ]; then
    echo "📝 Creating project-specs.md from template..."
    cp "${RULES_DIR}/templates/project-specs.template.md" "${RULES_PROJECT_DIR}/project-specs.md"
    echo "⚠️  Please edit .rules/project-specs.md with your project-specific information"
fi

if [ ! -f "${RULES_PROJECT_DIR}/overrides.md" ]; then
    echo "📝 Creating overrides.md from template..."
    cp "${RULES_DIR}/templates/overrides.template.md" "${RULES_PROJECT_DIR}/overrides.md"
    echo "⚠️  Please edit .rules/overrides.md if you need to override any global rules"
fi

# Create .cursorrules if it doesn't exist
if [ ! -f "${PROJECT_ROOT}/.cursorrules" ]; then
    echo "📝 Creating .cursorrules from template..."
    cp "${RULES_DIR}/cursor/.cursorrules.base" "${PROJECT_ROOT}/.cursorrules"
    echo "⚠️  Please edit .cursorrules with your project-specific context"
fi

# Create .clauderules if it doesn't exist
if [ ! -f "${PROJECT_ROOT}/.clauderules" ]; then
    echo "📝 Creating .clauderules from template..."
    cp "${RULES_DIR}/claudecode/.clauderules.base" "${PROJECT_ROOT}/.clauderules"
    echo "⚠️  Please edit .clauderules with your project-specific context"
fi

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit .rules/project-specs.md with your project information"
echo "2. Edit .cursorrules and .clauderules with your project context"
echo "3. Restart Cursor/Claude Code to load the new rules"

