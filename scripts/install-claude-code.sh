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

# Copy hooks to settings.json (merge, don't overwrite)
if [ -d "${SCRIPT_DIR}/claude-code/hooks" ]; then
    echo "📁 Setting up hooks..."
    if [ ! -f "${CLAUDE_HOME}/settings.json" ]; then
        echo '{"hooks": []}' > "${CLAUDE_HOME}/settings.json"
    fi
    # Note: Manual merge required for hooks
    echo "⚠️  Hooks need to be manually added to ~/.claude/settings.json"
    echo "   See claude-code/hooks/ for hook definitions"
fi

echo "✅ Claude Code configuration installed!"
echo ""
echo "Next steps:"
echo "1. Review ~/.claude/ directory structure"
echo "2. Add hooks to ~/.claude/settings.json if needed"
echo "3. Configure MCP servers in ~/.claude.json if needed"
echo "4. Restart Claude Code to load new settings"

