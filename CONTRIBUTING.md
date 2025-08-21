# Contributing to App Permissions Checker

Thank you for your interest in contributing! We welcome contributions from the community and are excited to see what you'll bring to the project.

## 🚀 Quick Start

1. **Fork** the repository
2. **Clone** your fork locally
3. **Create** a feature branch
4. **Make** your changes
5. **Test** thoroughly
6. **Submit** a pull request

## 📋 Types of Contributions

### 🐛 Bug Reports

Found a bug? Help us fix it!

**Before reporting:**
- Search existing [issues](https://github.com/kripadevg-code/app_permissions_checker/issues)
- Check if it's already fixed in the latest version
- Verify it's reproducible

**When reporting:**
- Use the bug report template
- Include device/OS information
- Provide clear reproduction steps
- Add screenshots/logs if helpful

### 💡 Feature Requests

Have an idea for improvement?

**Before requesting:**
- Check existing [discussions](https://github.com/kripadevg-code/app_permissions_checker/discussions)
- Consider if it fits the plugin's scope
- Think about implementation complexity

**When requesting:**
- Use the feature request template
- Explain the use case clearly
- Provide examples if possible
- Consider backwards compatibility

### 🔧 Code Contributions

Ready to code? Here's how:

#### Development Setup

```bash
# Clone your fork
git clone https://github.com/kripadevg-code/app_permissions_checker.git
cd app_permissions_checker

# Install dependencies
flutter pub get

# Run example app
cd example
flutter run
```

#### Code Standards

- **Dart Style**: Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- **Linting**: Use provided `analysis_options.yaml`
- **Documentation**: Document all public APIs
- **Testing**: Write tests for new functionality
- **Null Safety**: Maintain null safety compliance

#### Commit Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

feat(api): add permission filtering by category
fix(android): resolve crash on Android 14
docs(readme): update installation instructions
test(unit): add tests for permission parsing
```

**Types:**
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `test`: Test additions/changes
- `refactor`: Code refactoring
- `style`: Code style changes
- `chore`: Maintenance tasks

### 📚 Documentation

Help improve our docs:

- **API Documentation**: Improve dartdoc comments
- **README**: Enhance examples and clarity
- **Tutorials**: Create step-by-step guides
- **Translations**: Help with internationalization

### 🧪 Testing

We value thorough testing:

#### Running Tests

```bash
# Unit tests
flutter test

# Integration tests
cd example
flutter test integration_test/

# Android specific tests
cd android
./gradlew test
```

#### Test Guidelines

- **Unit Tests**: Test individual functions/classes
- **Integration Tests**: Test plugin functionality end-to-end
- **Platform Tests**: Test native Android code
- **Coverage**: Aim for >80% code coverage

#### Writing Tests

```dart
// Example unit test
test('should parse permission correctly', () {
  final permission = PermissionDetail.fromMap({
    'permission': 'android.permission.CAMERA',
    'granted': true,
    'protectionLevel': 'dangerous',
  });
  
  expect(permission.permission, 'android.permission.CAMERA');
  expect(permission.granted, isTrue);
  expect(permission.isDangerous, isTrue);
});
```

## 🔄 Pull Request Process

### Before Submitting

- [ ] Code follows style guidelines
- [ ] Tests pass locally
- [ ] Documentation is updated
- [ ] CHANGELOG.md is updated
- [ ] No breaking changes (or properly documented)

### PR Template

Use our PR template and include:

- **Description**: What changes were made and why
- **Type**: Bug fix, feature, documentation, etc.
- **Testing**: How the changes were tested
- **Screenshots**: For UI changes
- **Breaking Changes**: Any backwards incompatible changes

### Review Process

1. **Automated Checks**: CI/CD runs tests and linting
2. **Code Review**: Maintainers review the code
3. **Feedback**: Address any requested changes
4. **Approval**: Once approved, we'll merge the PR

## 🏗️ Architecture Guidelines

### Project Structure

```
lib/
├── src/
│   ├── models/           # Data models
│   ├── platform/         # Platform interfaces
│   └── utils/           # Utility functions
├── errors/              # Custom exceptions
└── app_permissions_checker.dart  # Main API

android/
├── src/main/kotlin/     # Android implementation
└── src/test/kotlin/     # Android tests

example/
├── lib/                 # Example app code
└── integration_test/    # Integration tests
```

### Design Principles

- **Simplicity**: Keep APIs simple and intuitive
- **Performance**: Optimize for speed and memory usage
- **Reliability**: Handle errors gracefully
- **Extensibility**: Design for future enhancements
- **Privacy**: Respect user privacy and data

## 🎯 Roadmap

### Current Priorities

- [ ] iOS support investigation
- [ ] Performance optimizations
- [ ] Enhanced filtering options
- [ ] Better error handling
- [ ] Accessibility improvements

### Future Ideas

- [ ] Permission usage analytics
- [ ] Custom permission categories
- [ ] Export functionality
- [ ] Integration with security scanners

## 🤝 Community Guidelines

### Code of Conduct

We follow the [Contributor Covenant](https://www.contributor-covenant.org/):

- **Be Respectful**: Treat everyone with respect
- **Be Inclusive**: Welcome diverse perspectives
- **Be Constructive**: Provide helpful feedback
- **Be Patient**: Remember we're all learning

### Communication

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and ideas
- **Pull Requests**: For code contributions
- **Email**: For security issues only

## 🏆 Recognition

Contributors are recognized in:

- **CONTRIBUTORS.md**: List of all contributors
- **Release Notes**: Major contributions highlighted
- **README**: Special thanks section
- **GitHub**: Contributor badges and stats

## 📞 Getting Help

Need help contributing?

- 📖 **Documentation**: Check existing docs first
- 💬 **Discussions**: Ask questions in GitHub Discussions
- 🐛 **Issues**: Search existing issues
- 📧 **Email**: Contact maintainers directly

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to App Permissions Checker!** 🎉

Your contributions help make Android app security analysis better for everyone in the Flutter community.