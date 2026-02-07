# Coding Style Rules

Immutable coding style rules that apply to all code.

## Code Organization

### File Structure
- Follow project-specific directory structure
- Group related files together
- Use clear, descriptive file names
- One main export per file (when applicable)

### Naming Conventions
- **Variables**: camelCase
- **Constants**: UPPER_SNAKE_CASE
- **Functions**: camelCase with verb prefix (get, set, create, etc.)
- **Classes**: PascalCase
- **Files**: kebab-case or camelCase (follow project convention)
- **Directories**: kebab-case

## Code Quality

### DRY Principle
- Don't Repeat Yourself
- Extract common logic into reusable functions
- Use composition over duplication

### Single Responsibility
- Each function/class should have one clear purpose
- Functions should be small and focused
- Classes should represent a single concept

### Readability
- Code should be self-documenting
- Use descriptive variable and function names
- Add comments for "why", not "what"
- Prefer explicit over implicit

## Formatting

- Follow project's formatting rules (Prettier, ESLint, etc.)
- Consistent indentation (2 or 4 spaces, follow project)
- Consistent quote style (single or double, follow project)
- Trailing commas in multi-line structures

## Best Practices

- **Early returns**: Use early returns to reduce nesting
- **Guard clauses**: Check conditions early
- **Avoid magic numbers**: Use named constants
- **Type safety**: Use TypeScript types or JSDoc types
- **Error handling**: Handle errors explicitly

