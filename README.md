# DateParse 

[![AutoHotkey2](https://img.shields.io/badge/Language-AutoHotkey2-green?style=plastic&logo=autohotkey)](https://autohotkey.com/)

<sub><sup>This library uses [AutoHotkey Version 2](https://autohotkey.com/v2/). (Tested with [AHK v2.0-11](https://github.com/AutoHotkey/AutoHotkey/releases))</sup></sub>

Converts almost any date format to a YYYYMMDDHH24MISS value.

## Usage 

Include `DateParse.ahk`from the `lib` folder into your project using standard AutoHotkey-include methods.


## Examples

For more examples see unittests.

```autohotkey
#include DateParse.ahk
dt := DateParse("2:35 PM, 27 November, 2007") ; -> "200711271435"
```