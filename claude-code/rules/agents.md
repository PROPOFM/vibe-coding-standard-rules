# Agents Usage Rules

Guidelines for when and how to use specialized agents.

## Agent Selection

Use specialized agents for complex tasks that require focused expertise:

### Planner Agent
- **When**: Creating implementation plans for features
- **Use**: `/plan` command or invoke planner agent
- **Tools**: Read, Grep, Glob

### Code Reviewer Agent
- **When**: Before committing code changes
- **Use**: `/code-review` command or invoke code-reviewer agent
- **Tools**: Read, Grep, Glob, Bash

### TDD Guide Agent
- **When**: Implementing features with TDD
- **Use**: `/tdd` command or invoke tdd-guide agent
- **Tools**: Read, Grep, Glob, Bash

### Security Reviewer Agent
- **When**: Security-sensitive code changes
- **Use**: Invoke security-reviewer agent
- **Tools**: Read, Grep, Glob

## Best Practices

1. **Tool Limitation**: Agents should use minimal tools (5-10 tools max)
2. **Focused Tasks**: Use agents for specific, well-defined tasks
3. **User Approval**: Get user approval before major changes
4. **Clear Output**: Agents should provide clear, actionable output

## Agent Invocation

Agents can be invoked:
- Explicitly: Mention agent name in conversation
- Via commands: Use slash commands like `/tdd`, `/plan`
- Automatically: Claude may suggest agent use for complex tasks

