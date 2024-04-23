# Changelog

## Unreleased

Improvements:
- Better handling of default values in the configuration.
- Unify configuration to only use `choices` field in parameters, also for dynamic choices.

## Version `0.3.0`

Features:
- Support setting the execution shell when executing command in non-interactive mode.
- Support using a command for the choices rather than only a list.

Improvements:
- Also provide non-interactive commands when launched with `-i`.
- Show default in the command substitution if set.
- Allow to cleanly exit by aborting rofi.
- Fully stop logging.

Fixes:
- Correctly implement exclusive choices selection.
- Return non-zero exit code on aborts.

## Version `0.2.2`

Fixes:
- Correctly pick default value on parameter if none is passed.

## Version `0.2.1`

Fixes:
- Do not panic if no commands are found.

## Version `0.2.0`

Features:
- Support for an interactive mode with `-i` flag to enable embedding into shells.

Improvements:
- Prints mapped values (if any) in the parameter search terms.

## Version `0.1.0`

Initial release.
