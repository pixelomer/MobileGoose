# MobileGoose Mod Template

This is a template that can be installed to easily create mods with `nic.pl`.

**NOTE:** The template's Makefile doesn't contain `ARCHS` and `TARGET` values. Make sure you set them when you create a project. The preferred values can be found below.

```
# Change 8.0 to something else to target a different iOS version. iOS 8.0 is the lowest
# possible value, since MobileGoose doesn't support lower versions.
# Change 11.2 to something else to use a different SDK version.
TARGET = iphone:11.2:8.0

# Operating systems other than macOS might have trouble compiling
# for arm64e. Remove it if you have problems.
ARCHS = arm64e arm64 armv7
```
