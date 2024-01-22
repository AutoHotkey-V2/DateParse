#Requires AutoHotkey v2.0-
#Warn
#SingleInstance force

#include "%A_ScriptDir%\..\lib\DateParse.ahk"

testcases := []
/*

> dt := DateParse("May1960") ; -> "19600501"
> dt := DateParse("25May1960") ; -> "19600525"
> dt := DateParse("201710") ; -> "20171001"

> ; YYYYMMDD is to be replaced with today
> dt := DateParse("1532") ; -> "YYYYMMDD1532"
> dt := DateParse("11:26") ; -> "YYYYMMDD1126"
> dt := DateParse("2:35 PM") ; -> "YYYYMMDD1435"
> dt := DateParse("11:22:24 AM") ; -> "YYYYMMDD112224"
*/

; date-time examples
testcases.Push(Map('data', "2:35 PM, 27 November, 2007",    'expected', "200711271435"))
testcases.Push(Map('data', "4:55 am Feb 27, 2004"      ,    'expected', "200402270455"))
testcases.Push(Map('data', "Mon, 17 Aug 2009 13:23:33 GMT", 'expected', "20090817132333"))
testcases.Push(Map('data', "07 Mar 2009 13:43:58",          'expected', "20090307134358"))
testcases.Push(Map('data', "2007-06-26T14:09:12Z",          'expected', "20070626140912"))
testcases.Push(Map('data', "2007-06-25 18:52",              'expected', "200706251852"))

; date-only examples
testcases.Push(Map('data', "19/2/05",                       'expected', "20050219"))
testcases.Push(Map('data', "10/12/2007",                    'expected', "20071210"))
testcases.Push(Map('data', "3/15/2009",                     'expected', "20090315"))
testcases.Push(Map('data', "05-Jan-00",                     'expected', "20000105"))
testcases.Push(Map('data', "Jan-06-00",                     'expected', "20000106"))
testcases.Push(Map('data', "Dec-31-13",                     'expected', "20131231"))
testcases.Push(Map('data', "Wed 6/27/2007",                 'expected', "20070627"))
testcases.Push(Map('data', "May1960",                       'expected', "19600501"))
testcases.Push(Map('data', "25May1960",                     'expected', "19600525"))
testcases.Push(Map('data', "201710",                        'expected', "20171001"))

; time only examples -> todays date should be added automatically in output
today := FormatTime(A_Now, "yyyyMMdd")
testcases.Push(Map('data', "1532",                          'expected', today . "1532"))
testcases.Push(Map('data', "11:26",                         'expected', today . "1126"))
testcases.Push(Map('data', "2:35 PM",                       'expected', today . "1435"))
testcases.Push(Map('data', "11:22:33 AM",                   'expected', today . "112233"))

For Index, Value in testcases {
	dt := DateParse(value["data"])
	str := Format("{:02.0f}", Index)
	if (dt != value["expected"]) {
		str:= str . " - ** FAILURE ** "
	} else {
		str:= str . " -    SUCCESS    "
	}
	str := str . " - Input: " Format("{:-30}",value["data"]) " * Expected: " Format("{:-15}",value["expected"]) " * Got: " Format("{:-15}",dt)
	OutputDebug str "`n"
}
ExitApp()