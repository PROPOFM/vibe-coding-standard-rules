#!/bin/bash
# Install Claude Code configuration files
# This script copies Claude Code settings to the appropriate directories

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_HOME="${HOME}/.claude"

echo "🚀 Installing Claude Code configuration..."

# Create .claude directory if it doesn't exist
mkdir -p "${CLAUDE_HOME}"/{agents,skills,commands,rules}

# Copy agents
if [ -d "${SCRIPT_DIR}/claude-code/agents" ]; then
    echo "📁 Copying agents..."
    cp -r "${SCRIPT_DIR}/claude-code/agents"/* "${CLAUDE_HOME}/agents/" 2>/dev/null || true
fi

# Copy skills
if [ -d "${SCRIPT_DIR}/claude-code/skills" ]; then
    echo "📁 Copying skills..."
    cp -r "${SCRIPT_DIR}/claude-code/skills"/* "${CLAUDE_HOME}/skills/" 2>/dev/null || true
fi

# Copy commands
if [ -d "${SCRIPT_DIR}/claude-code/commands" ]; then
    echo "📁 Copying commands..."
    cp -r "${SCRIPT_DIR}/claude-code/commands"/* "${CLAUDE_HOME}/commands/" 2>/dev/null || true
fi

# Copy rules
if [ -d "${SCRIPT_DIR}/claude-code/rules" ]; then
    echo "📁 Copying rules..."
    cp -r "${SCRIPT_DIR}/claude-code/rules"/* "${CLAUDE_HOME}/rules/" 2>/dev/null || true
fi

# Copy settings.json (default configuration with auto-execute)
if [ -f "${SCRIPT_DIR}/claude-code/settings.json" ]; then
    echo "📁 Setting up Claude Code settings..."
    if [ ! -f "${CLAUDE_HOME}/settings.json" ]; then
        cp "${SCRIPT_DIR}/claude-code/settings.json" "${CLAUDE_HOME}/settings.json"
        echo "✅ Created ~/.claude/settings.json with default configuration (auto-execute enabled)"
    else
        echo "⚠️  ~/.claude/settings.json already exists"
        echo "   To use the default configuration, manually merge or backup your existing settings:"
        echo "   cp ~/.claude/settings.json ~/.claude/settings.json.backup"
        echo "   cp ${SCRIPT_DIR}/claude-code/settings.json ~/.claude/settings.json"
        echo "   Or merge the 'agent' section from the template manually"
    fi
fi

echo "✅ Claude Code configuration installed!"
echo ""
echo "Next steps:"
echo "1. Review ~/.claude/ directory structure"
echo "2. Add hooks to ~/.claude/settings.json if needed"
echo "3. Configure MCP servers in ~/.claude.json if needed"
echo "4. Restart Claude Code to load new settings"

