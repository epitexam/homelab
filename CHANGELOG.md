# Changelog

All notable changes to this project are documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/),
following [Semantic Versioning](https://semver.org/).

## Format

- Added = new features
- Changed = changes to existing features
- Deprecated = features that will be removed
- Removed = features that have been removed
- Fixed = bug fixes
- Security = security fixes

---

## [1.0.0] - 2025-02-05

### Added
- Initial project structure
- AdGuard Home service (DNS + ad blocker)
- Home Assistant service (home automation)
- Jellyfin service (media server)
- Complete documentation (800+ lines)
- Automatic setup script
- Health checks for all services
- .env.example templates

### Changed
- Reorganized structure: services/ directory

### Fixed
- Jellyfin volume permissions
- Home Assistant network configuration

---

## Versioning Guide

We use Semantic Versioning: MAJOR.MINOR.PATCH

- MAJOR (1.0.0 -> 2.0.0) = incompatible change
- MINOR (1.0.0 -> 1.1.0) = new feature, compatible
- PATCH (1.0.0 -> 1.0.1) = bug fix

Tag each version on Git:
```bash
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0
```
