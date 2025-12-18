# Security Standards

## Authentication
- JWT tokens with expiration
- Refresh token rotation
- Secure password hashing (bcrypt)
- 2FA support where needed

## Authorization
- Role-based access control
- Resource ownership checks
- Principle of least privilege

## Data Protection
- Encrypt sensitive data at rest
- Use HTTPS only
- Secure headers (helmet)
- Rate limiting
- CSRF protection

## Input Validation
- Validate all user input
- Sanitize HTML
- Prevent SQL injection
- Prevent XSS attacks

## Secrets Management
- Environment variables only
- Never commit secrets
- Rotate secrets regularly
- Use secret management tools (Vault, etc.)
