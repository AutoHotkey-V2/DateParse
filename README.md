# DateParse [![AutoHotkey2](https://img.shields.io/badge/Language-AutoHotkey2-red.svg)](https://autohotkey.com/)
Converts almost any date format to a YYYYMMDDHH24MISS value.

This library uses *AutoHotkey Version 2*.

This repository only offers released version of this library - **development is taking place unter [DateParse-Develop](https://github.com/hoppfrosch/DateParse-Develop)**

## Usage 

Include `DateParse.ahk`from the `lib` folder into your project using standard AutoHotkey-include methods.


## Examples

For more examples see module source.

```autohotkey
#include DateParse.ahk
dt := DateParse("2:35 PM, 27 November, 2007") ; -> "200711271435"
```