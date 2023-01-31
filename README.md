# Scripts for Building Things on Windows

This is a somewhat rough set of scripts to find an installed version of Visual Studio and use it to build a simple program. The scripts support Visual Studio 2017, 2019, and 2022. If none are specified, they will try to find the latest of those versions. See `tools\options.cmd` for command-line options to `tools\build.cmd`. Here are some examples:

- `tools\build.cmd` (defaults to a debug build)
- `tools\build.cmd debug` (explicitly sets debug build-options)
- `tools\build.cmd release` (explicitly sets release build-options)
- `tools\build.cmd clean build` (remove previous debug-build and builds another)
- `tools\build.cmd vs2017 clean` (remove previous VS2017 debug-build)
- `tools\build.cmd vs2017 clean build` (remove previous VS2017 debug-build and builds another)
