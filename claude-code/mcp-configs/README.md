# MCP Configuration Templates

Model Context Protocol (MCP) server configuration templates.

## Important Notes

⚠️ **MCP Activation Limit**: Keep active MCP servers to **10 or fewer** to prevent context window reduction (200k → 70k).

## Configuration Strategy

1. **Configure 20-30 MCP servers** in config file
2. **Enable only 10 or fewer** per project
3. **Disable unused MCPs** using `disabledMcpServers`
4. **Keep active tools under 80**

## Usage

1. Copy relevant MCP config to `~/.claude.json`
2. Replace `YOUR_*_HERE` placeholders with actual values
3. Enable only necessary MCPs for your project
4. Disable others using `disabledMcpServers`

## Available Templates

- `github.json` - GitHub integration
- `supabase.json` - Supabase integration
- `vercel.json` - Vercel integration
- `railway.json` - Railway integration

## Example Configuration

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR_TOKEN_HERE"
      }
    }
  },
  "disabledMcpServers": [
    "supabase",
    "vercel"
  ]
}
```

