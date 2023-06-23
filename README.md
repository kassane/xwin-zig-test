# Zig with XWin (Experimental)

## What is [xwin](https://github.com/Jake-Shadle/xwin)?

A utility for downloading and packaging the Microsoft CRT headers and libraries, and Windows SDK headers and libraries needed for compiling and linking programs targeting Windows.

## Note

It's important to remind that the libraries and headers are owned by Microsoft.
This experiment is for testing purposes only. Possibly to make it easier to build hermetically.

## Requirements

- [xwin](https://github.com/Jake-Shadle/xwin)
- [zig 0.11 or higher](https://ziglang.org/download)

## Testing

The main targets for this experiment are:

| Target | Native | Build | Host |
| --- | --- | --- | --- |
| msvc-x64 | Yes | 🆗 | Windows |
| msvc-x64 | No | 🆗 | Linux |
| msvc-x64 | No | 🆗 | MacOS |
| msvc-x86 | Yes | 🆗 | Windows |
| msvc-x86 | No | 🆗 | Linux |
| msvc-x86 | No | 🆗 | MacOS |
| msvc-arm64 | Yes | 🆗 | Windows |
| msvc-arm64 | No | 🆗 | Linux |
| msvc-arm64 | No | 🆗 | MacOS |

**Note:** On linux the LLD is case-sensitive. maybe solve don't use `xwin` `--disable-symlinks` flag. However, it breaks the macos build!
