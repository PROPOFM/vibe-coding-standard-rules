---
name: tdd-workflow
description: Test-driven development workflow following RED-GREEN-REFACTOR cycle with 80%+ coverage requirement
---

# TDD Workflow Skill

This skill guides you through the Test-Driven Development (TDD) workflow.

## When to Use

- Implementing new features
- Refactoring existing code
- When user requests TDD approach
- When `/tdd` command is invoked

## Workflow Steps

### 1. RED Phase - Write Failing Test

**Goal**: Write a test that describes the desired behavior

**Steps**:
1. Identify the behavior to implement
2. Write a test that describes this behavior
3. Run the test - it should fail (RED)
4. Ensure the test fails for the right reason

**Example**:
```typescript
describe('UserService', () => {
  it('should create a new user', async () => {
    const user = await userService.create({ name: 'John' });
    expect(user.id).toBeDefined();
    expect(user.name).toBe('John');
  });
});
```

### 2. GREEN Phase - Make Test Pass

**Goal**: Write minimal code to make the test pass

**Steps**:
1. Write the simplest code that makes the test pass
2. Don't worry about code quality yet
3. Run the test - it should pass (GREEN)
4. Avoid over-engineering

**Example**:
```typescript
async create(userData: CreateUserDto): Promise<User> {
  const user = {
    id: generateId(),
    ...userData,
    createdAt: new Date()
  };
  return user;
}
```

### 3. REFACTOR Phase - Improve Code

**Goal**: Improve code quality while keeping tests green

**Steps**:
1. Review the code for improvements
2. Remove duplication
3. Improve readability
4. Maintain test coverage
5. Run tests to ensure they still pass

## Test Coverage Requirements

- **Minimum**: 80% coverage
- **Critical paths**: 100% coverage
- **Edge cases**: Must be tested
- **Error handling**: Must be tested

## Best Practices

1. **One test at a time**: Focus on one behavior per test
2. **Fast feedback**: Run tests frequently
3. **Clean tests**: Tests should be readable
4. **Test structure**: Use Arrange-Act-Assert pattern
5. **Test names**: Descriptive test names that explain behavior

## Common Patterns

### Testing Async Code
```typescript
it('should handle async operations', async () => {
  const result = await service.asyncOperation();
  expect(result).toBeDefined();
});
```

### Testing Error Cases
```typescript
it('should throw error when invalid input', async () => {
  await expect(service.operation(invalidInput))
    .rejects.toThrow('Invalid input');
});
```

### Testing Edge Cases
```typescript
it('should handle empty array', () => {
  const result = service.process([]);
  expect(result).toEqual([]);
});
```

