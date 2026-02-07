# Testing Rules

Testing standards and requirements for all code changes.

## Test-Driven Development (TDD)

- **Required**: TDD workflow for new features
- **Cycle**: RED → GREEN → REFACTOR
- **Coverage**: Minimum 80% test coverage

## Test Coverage Requirements

### Minimum Coverage
- **Overall**: 80%+
- **Critical paths**: 100%
- **Business logic**: 90%+
- **Utilities**: 80%+

### What to Test
- ✅ Happy paths
- ✅ Error cases
- ✅ Edge cases
- ✅ Boundary conditions
- ✅ Integration points

### What Not to Test
- ❌ Third-party library code
- ❌ Framework code
- ❌ Simple getters/setters (unless critical)

## Test Structure

### Unit Tests
```typescript
describe('ComponentName', () => {
  describe('methodName', () => {
    it('should expected behavior when condition', () => {
      // Arrange
      // Act
      // Assert
    });
  });
});
```

### Integration Tests
- Test component interactions
- Test API endpoints
- Test database operations

### E2E Tests
- Test complete user flows
- Test critical business paths

## Test Quality

- **Fast**: Tests should run quickly
- **Independent**: Tests should not depend on each other
- **Repeatable**: Tests should produce same results
- **Self-validating**: Tests should clearly pass or fail
- **Timely**: Tests written before or alongside code

## Running Tests

```bash
# Run all tests
npm test

# Run with coverage
npm test -- --coverage

# Run specific test file
npm test -- path/to/test.ts
```

## Continuous Integration

- All tests must pass before merge
- Coverage reports generated
- Coverage threshold enforced (80%+)

