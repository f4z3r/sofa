# Changelog

## [0.5.0] - 2024-05-04

### Added

- Support for `fzf` as a picker.
- Logging support.

### Fixed

- `sofa` can now be launched without a configuration.

## [0.4.0] - 2024-04-30

### Added

- Support for Lua version 5.2, 5.3, and 5.4.

### Changed

- Better handling of default values in the configuration.
- Unify configuration to only use `choices` field in parameters, also for dynamic choices.

## [0.3.0] - 2024-04-18

### Added

- Support setting the execution shell when executing command in non-interactive mode.
- Support using a command for the choices rather than only a list.

### Changed

- Also provide non-interactive commands when launched with `-i`.
- Show default in the command substitution if set.
- Allow to cleanly exit by aborting rofi.
- Fully stop logging.

### Fixed

- Correctly implement exclusive choices selection.
- Return non-zero exit code on aborts.

## [0.2.2] - 2024-04-12

### Fixed

- Correctly pick default value on parameter if none is passed.

## [0.2.1] - 2024-04-12

### Fixed

- Do not panic if no commands are found.

## [0.2.0] - 2024-04-12

### Added

- Support for an interactive mode with `-i` flag to enable embedding into shells.

### Changed

- Prints mapped values (if any) in the parameter search terms.

## [0.1.0] - 2024-04-12

Initial release.

[0.5.0]: https://github.com/f4z3r/sofa/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/f4z3r/sofa/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/f4z3r/sofa/compare/v0.2.2...v0.3.0
[0.2.2]: https://github.com/f4z3r/sofa/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/f4z3r/sofa/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/f4z3r/sofa/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/f4z3r/sofa/releases/tag/v0.1.0
