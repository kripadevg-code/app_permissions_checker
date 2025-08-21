# Security Policy

## Supported Versions

We actively support the following versions of App Permissions Checker:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability, please follow these steps:

### 🔒 Private Disclosure

**DO NOT** create a public GitHub issue for security vulnerabilities.

Instead, please report security issues privately by:

1. **Email**: Send details to kripadev.g@gmail.com
2. **GitHub Security**: Use GitHub's private vulnerability reporting feature
3. **Encrypted Communication**: Use our PGP key for sensitive information

### 📋 What to Include

Please include the following information in your report:

- **Description**: Clear description of the vulnerability
- **Impact**: Potential impact and attack scenarios
- **Reproduction**: Step-by-step instructions to reproduce
- **Environment**: Android version, device info, app version
- **Proof of Concept**: Code or screenshots (if applicable)

### ⏱️ Response Timeline

- **Initial Response**: Within 24 hours
- **Triage**: Within 72 hours
- **Fix Timeline**: Depends on severity
  - Critical: 1-7 days
  - High: 1-2 weeks
  - Medium: 2-4 weeks
  - Low: Next release cycle

### 🏆 Recognition

We appreciate security researchers who help keep our users safe:

- **Hall of Fame**: Public recognition (with permission)
- **Coordinated Disclosure**: We'll work with you on timing
- **Credit**: Acknowledgment in release notes and documentation

## Security Best Practices

### For Users

1. **Keep Updated**: Always use the latest version
2. **Minimal Permissions**: Only request necessary permissions
3. **User Consent**: Inform users about permission analysis
4. **Secure Storage**: Don't store sensitive permission data

### For Developers

1. **Input Validation**: Validate all package names and inputs
2. **Error Handling**: Implement proper error handling
3. **Rate Limiting**: Avoid excessive permission queries
4. **Privacy**: Follow privacy-by-design principles

## Known Security Considerations

### Android Permissions

- **QUERY_ALL_PACKAGES**: Required but sensitive permission
- **Scope**: Limited to publicly available app metadata
- **Privacy**: No access to app content or user data

### Data Handling

- **Local Processing**: All analysis happens on-device
- **No Network**: No data transmission to external servers
- **Temporary Storage**: Permission data not persisted

## Compliance

This plugin is designed to comply with:

- **Android Privacy Guidelines**
- **Google Play Store Policies**
- **GDPR Privacy Requirements**
- **Platform Security Standards**

## Contact

For security-related questions or concerns:

- 🔒 **Security Email**: kripadev.g@gmail.com
- 🛡️ **Security Team**: @security-team
- 📞 **Emergency Contact**: Available upon request

---

**Remember**: Security is a shared responsibility. Help us keep the Flutter community safe!