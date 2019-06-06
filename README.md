## Overview
This is a simple tool to display battery charge/discharge events for Apple laptops running Mac OS. The data is historical and goes back as far as the data in the built-in power management log allows.

The output is not always 100% complete due to how `pmset` logs and provides the necessary information, but it is a fairly accurate approximation of real usage including wake events that weren't user initiated. (i.e. Power Nap)

Having the Mac OS command line tools installed (`xcode-select --install`) is strongly recommended but not strictly required. See the Makefile for information on manually concatenating the bash/awk portions of the code.

If `gawk` is available it will be used and will speed up output slightly, but the built-in version of `awk` will work as well.

## Sample output
```
$ battery-duration 
Reading input from: pmset -g log
2019-06-05
Awake from 02:09:33 (100%) to 02:30:28 (98%)
Awake from 12:05:39 (94%) to 13:37:06 (67%)
Awake from 20:24:35 (63%) to 21:23:16 (48%)
2019-06-06
Awake from 11:47:50 (43%) to present (37%)*
Awake for 03:08:43
```

An asterisk (`*`) in the output indicates that a corresponding sleep/wake event couldn't be found in the log, so an approximate value was used. This is most commonly seen on the most recent entry since you are still using the computer.

## Usage
```
$ battery-duration -h
Usage: battery-duration [-q] [-f FILE]
	-q	Quiet mode. Only show daily totals, not each event.
	-f	Use FILE for input instead of `pmset -g log`. Use - for STDIN.
```

## Installation
Just clone the repo or download an archive and run make. The Makefile is very simple and just concatenates the bash header that handles options parsing and pmset commands with the awk component that parses the actual log data.

```
git clone https://github.com/demonbane/battery-duration
cd battery-duration
make
./battery-duration
```

There is no `install` target, so just copy/symlink `battery-duration` to a location in your PATH. (e.g. `/usr/local/bin`)
