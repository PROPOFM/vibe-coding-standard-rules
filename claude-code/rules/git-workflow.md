# Git Workflow Rules

Git commit and pull request standards.

## Commit Message Format

Follow conventional commits format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Test additions or changes
- `chore`: Build process or auxiliary tool changes

### Examples
```
feat(auth): add user login functionality

fix(api): resolve timeout issue in data fetching

docs(readme): update installation instructions
```

## Branch Naming

- `feature/description`: New features
- `fix/description`: Bug fixes
- `refactor/description`: Refactoring
- `docs/description`: Documentation updates

## Pull Request Process

1. **Create PR**: Link to related issue
2. **Description**: Clear description of changes
3. **Review**: At least one approval required
4. **Tests**: All tests must pass
5. **Coverage**: Maintain or improve test coverage

## Pre-Commit Checks

- [ ] Code follows project style guide
- [ ] All tests pass
- [ ] No console.log statements
- [ ] No hardcoded secrets
- [ ] Documentation updated if needed

