# Performance Rules

Model selection and context management guidelines.

## Model Selection

### Opus (Claude Sonnet 4.5)
- **Use for**: Complex reasoning, architecture decisions, code reviews
- **When**: High-quality output is critical
- **Cost**: Higher token usage

### Sonnet (Claude Sonnet 4)
- **Use for**: General development tasks
- **When**: Balanced quality and speed needed
- **Cost**: Moderate token usage

### Haiku (Claude Haiku 3.5)
- **Use for**: Simple tasks, quick responses
- **When**: Speed is priority
- **Cost**: Lower token usage

## Context Management

### MCP Servers
- **Limit**: Enable 10 or fewer MCP servers per project
- **Impact**: Too many MCPs reduce context window (200k → 70k)
- **Strategy**: Configure 20-30, enable only needed ones

### Active Tools
- **Limit**: Keep active tools under 80
- **Impact**: Too many tools reduce efficiency
- **Strategy**: Disable unused tools

### Agent Tools
- **Limit**: 5-10 tools per agent
- **Impact**: Fewer tools = faster, more focused agents
- **Strategy**: Give agents only necessary tools

## Best Practices

1. **Progressive Loading**: Load resources on-demand
2. **Context Efficiency**: Keep context focused and relevant
3. **Tool Selection**: Use minimal tools for each task
4. **Model Selection**: Choose appropriate model for task complexity

