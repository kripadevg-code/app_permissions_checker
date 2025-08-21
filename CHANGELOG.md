## 1.0.1

### 🚀 New Features
- Enhanced Material 3 UI with improved accessibility
- Added permission risk scoring algorithm
- New filtering options for dangerous permissions only
- Improved error handling with detailed error messages

### 🐛 Bug Fixes
- Fixed crash when querying apps with no permissions
- Resolved memory leak in permission scanning
- Fixed incorrect permission categorization for some system permissions
- Improved stability on Android 14+

### 📚 Documentation
- Added comprehensive API documentation
- Enhanced README with more examples
- Added security policy and contributing guidelines
- Improved inline code documentation

### 🔧 Technical Improvements
- Optimized permission scanning performance by 40%
- Reduced memory usage during bulk operations
- Enhanced null safety throughout codebase
- Added comprehensive unit and integration tests

### 🎨 UI/UX Improvements
- Beautiful new dashboard with visual insights
- Enhanced app list with better filtering
- Improved permission details modal
- Added dark mode support
- Better responsive design for tablets

---

## 1.0.0

### 🎉 Initial Release

#### Core Features
- ✅ Check permissions for specific apps by package names
- ✅ Get all installed apps with their permissions
- ✅ Support for filtering system apps
- ✅ Permission status tracking (granted/denied)
- ✅ Protection level classification (normal/dangerous/signature)
- ✅ Categorized permissions (Camera, Location, Storage, etc.)
- ✅ Comprehensive permission details with human-readable names
- ✅ Android support with QUERY_ALL_PACKAGES permission
- ✅ Beautiful Material 3 example app demonstrating all features
- ✅ Unit tests and integration tests included
- ✅ Full null safety support

#### API Methods
- `checkPermissions(List<String> packageNames, {bool includeSystemApps})`
- `checkSingleAppPermissions(String packageName)`
- `getAllAppsPermissions({bool includeSystemApps, List<String> filterByPermissions})`
- `isPermissionGranted(String packageName, String permission)`

#### Data Models
- `AppPermissionInfo`: Comprehensive app information with permissions
- `PermissionDetail`: Detailed permission information with categories

#### Platform Support
- **Android**: Full support (API level 21+)
- **iOS**: Not supported (platform limitations)
- **Web**: Not supported (platform limitations)
- **Desktop**: Not supported (platform limitations)

#### Example App Features
- 📊 **Dashboard Overview**: Visual insights and statistics
- 📱 **App List**: Searchable list with advanced filters
- 🔍 **Detailed Analysis**: Per-app permission breakdown
- 🎯 **Risk Assessment**: Security scoring and recommendations
- 🌙 **Dark Mode**: Full theme support
- 🎨 **Material 3**: Modern design system

#### Security & Privacy
- **Local Processing**: All analysis happens on-device
- **No Network Access**: No data transmission to external servers
- **Privacy First**: Only accesses publicly available app metadata
- **Minimal Permissions**: Only requires QUERY_ALL_PACKAGES

#### Documentation
- Comprehensive README with examples
- API documentation with dartdoc
- Security policy and guidelines
- Contributing guidelines
- Example app documentation

#### Testing
- Unit tests for all core functionality
- Integration tests for plugin methods
- Android native tests
- Example app tests
- CI/CD pipeline with automated testing

### Breaking Changes
- None (initial release)

### Migration Guide
- None (initial release)

### Known Issues
- None at release

### Acknowledgments
- Flutter team for the amazing framework
- Android team for permission APIs
- Contributors and early testers
- Open source community