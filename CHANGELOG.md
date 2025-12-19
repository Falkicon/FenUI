# Changelog

All notable changes to FenUI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [2.0.0] - 2025-12-19

### Added

- **Blizzard-first architecture** - Complete rebuild using native WoW UI APIs
- **Three-tier design token system** - Primitive, semantic, and component tokens
- **Panel widget** - Window container with title, close button, and content slots
- **Tabs widget** - Tab groups with badges, disabled states, and focus handling
- **Grid widget** - CSS Grid-inspired layout with column definitions and data binding
- **Toolbar widget** - Horizontal slot-based layout for buttons and controls
- **EmptyState widget** - Centered overlay for empty content areas
- **Buttons** - Standard, icon, and close button variants
- **Containers** - Insets and scroll panels
- **Theme system** - Multiple built-in themes with easy switching
- **BlizzardBridge** - NineSlice layout helpers and Atlas utilities
- **Validation suite** - Detect Blizzard API changes with `/fenui validate`
- **Graceful degradation** - Addons work without FenUI installed
- **Dual API** - Config object and fluent builder patterns
- **Lifecycle hooks** - onCreate, onShow, onHide, onThemeChange

### Changed

- Rebuilt from scratch as a Blizzard-first library (previously Plumber-derived)
- Now distributed as an embedded library via `update_libs.ps1`

### Removed

- Plumber-style ornate borders (now uses native Blizzard themes)
- Custom texture assets (now uses Blizzard Atlas system)

## [1.x] - Legacy

Previous versions were based on Plumber and distributed as part of the Weekly addon.
FenUI 2.0 is a complete rewrite with a new architecture.
