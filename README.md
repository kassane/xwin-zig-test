# Zig with XWin (Experimental)

## Whats is [xwin](https://github.com/Jake-Shadle/xwin)?

A utility for downloading and packaging the Microsoft CRT headers and libraries, and Windows SDK headers and libraries needed for compiling and linking programs targeting Windows.

## Note

It's important to remind that the libraries and headers are owned by Microsoft.
This experiment is for testing purposes only. Possibly to make it easier to build hermetically.

## Requirements

- [xwin](https://github.com/Jake-Shadle/xwin)
- [zig 0.11 or higher](https://ziglang.org/download)

## Testing

The main targets for this experiment are:

| Target | Native | Build | 
| --- | --- | --- |
| msvc-x64 | Yes | Ok |
| msvc-x64 | No | Fail |
| msvc-x86 | Yes | None |
| msvc-x86 | No | None |
| msvc-arm64 | Yes | None |
| msvc-arm64 | No | None |