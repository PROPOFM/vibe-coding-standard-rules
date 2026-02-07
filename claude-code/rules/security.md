# Security Rules

Mandatory security checks that must be performed before committing code.

## Pre-Commit Security Checklist

### Secrets Management
- [ ] No hardcoded API keys, passwords, or tokens
- [ ] Secrets stored in environment variables or secret management systems
- [ ] `.env` files are in `.gitignore`
- [ ] No secrets in commit history

### Input Validation
- [ ] All user inputs are validated
- [ ] Input sanitization for XSS prevention
- [ ] SQL injection prevention (parameterized queries)
- [ ] File upload validation and restrictions

### Authentication & Authorization
- [ ] Authentication checks on protected routes
- [ ] Authorization checks for user permissions
- [ ] Session management is secure
- [ ] Password hashing (bcrypt, argon2, etc.)

### Error Handling
- [ ] Error messages don't leak sensitive information
- [ ] Stack traces not exposed in production
- [ ] Proper error logging without exposing secrets

### Dependencies
- [ ] Dependencies scanned for known vulnerabilities
- [ ] Outdated packages updated
- [ ] No unnecessary dependencies

### Data Protection
- [ ] Sensitive data encrypted at rest
- [ ] HTTPS for data in transit
- [ ] PII (Personally Identifiable Information) handled according to regulations

## OWASP Top 10 Compliance

Ensure code addresses:
1. Broken Access Control
2. Cryptographic Failures
3. Injection
4. Insecure Design
5. Security Misconfiguration
6. Vulnerable Components
7. Authentication Failures
8. Software and Data Integrity Failures
9. Security Logging Failures
10. Server-Side Request Forgery

## Security Review

Before committing, run security review agent:
```
Use security-reviewer agent to check for vulnerabilities
```

