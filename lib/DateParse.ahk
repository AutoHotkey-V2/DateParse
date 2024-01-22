; ===================================================================================
; AHK Version ...: Tested with AHK 2.0-a081-cad307c x64 Unicode
; Win Version ...: Tested with Windows 7 Professional x64 SP1
; Description ...: Converts almost any date format to a YYYYMMDDHH24MISS value.
; Modified ......: 2017.11.01
; Author ........:  * Original - dougal/polyethene (original)
; ...............   * 20171101 - hoppfrosch
; .............................. * update to V2
; .............................. * added more dates to be parsed
; Licence .......: https://creativecommons.org/publicdomain/zero/1.0/
; Source ........: Original: http://www.autohotkey.com/board/topic/18760-date-parser-convert-any-date-format-to-yyyymmddhh24miss/page-6#entry640277
; ................ V2 : https://github.com/AutoHotkey-V2/DateParse
; Version........: 2.0.0
; ===================================================================================

/*
	Function: DateParse
		Converts almost any date format to a YYYYMMDDHH24MISS value.

	Parameters:
		str - a date/time stamp as a string

	Returns:
		A valid YYYYMMDDHH24MISS value which can be used by FormatTime, DateDiff and other time commands.

	Example:
> dt := DateParse("2:35 PM, 27 November, 2007") ; -> "200711271435"
> dt := DateParse("4:55 am Feb 27, 2004") ; -> "200402270455"
> dt := DateParse("Mon, 17 Aug 2009 13:23:33 GMT") ; -> "20090817132333"
> dt := DateParse("07 Mar 2009 13:43:58") ; -> "20090307134358"
> dt := DateParse("2007-06-26T14:09:12Z") ; -> "20070626140912"
> dt := DateParse("2007-06-25 18:52") ; -> "200706251852"
> dt := DateParse("19/2/05") ; -> "20050219"
> dt := DateParse("10/12/2007") ; -> "20071210"
> dt := DateParse("3/15/2009") ; -> "20090315"
> dt := DateParse("05-Jan-00") ; -> "20000105"
> dt := DateParse("Jan-05-00") ; -> "20000105"
> dt := DateParse("Dec-31-13") ; -> "20131231"
> dt := DateParse("Wed 6/27/2007") ; -> "20070627"
> dt := DateParse("May1960") ; -> "19600501"
> dt := DateParse("25May1960") ; -> "19600525"
> dt := DateParse("201710") ; -> "20171001"
> ; YYYYMMDD is to be replaced with today
> dt := DateParse("1532") ; -> "YYYYMMDD1532"
> dt := DateParse("11:26") ; -> "YYYYMMDD1126"
> dt := DateParse("2:35 PM") ; -> "YYYYMMDD1435"
> dt := DateParse("11:22:24 AM") ; -> "YYYYMMDD112224"

	License:
		- Dedicated to the public domain (CC0 1.0) <http://creativecommons.org/publicdomain/zero/1.0/>
*/
/*
Modified return values:
	Partial date returns
		No month : nothing
		No year and no day : nothing
		Time and no day :nothing
		Month and year without time : substitute 1st for day
		Day and month : substitute current year
	   No date and time still substitutes current date
Allow no separator aorund named months (eg 25May60)
Only alphabetic Month name follow on characters to prevent month taking first 2 digits of 4 digit year if there are no separators eg in 25May1960 year group only gets 60 and becomes 2060
Separators relaxed, can be any character except letter or digit
Search for named months first to prevent number month incorrectly matching in "Feb 12 11" as day =12 month=11 and skipping named month match
With named months day or year are optional
if numeric month is > 12 and day is <= 12 swap month and day (probably american date)
*/
DateParse(str, americanOrder := 0) {
	; Definition of several RegExes
	static monthNames := "(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-zA-Z]*"
		, dayAndMonth := "(\d{1,2})[^a-zA-Z0-9:.]+(\d{1,2})"
		, dayAndMonthName := "(?:(?<Month>" . monthNames . ")[^a-zA-Z0-9:.]*(?<Day>\d{1,2})[^a-zA-Z0-9]+|(?<Day>\d{1,2})[^a-zA-Z0-9:.]*(?<Month>" . monthNames . "))"
		, monthNameAndYear := "(?<Month>" . monthNames . ")[^a-zA-Z0-9:.]*(?<Year>(?:\d{4}|\d{2}))"

	ampm := "am"
	if RegExMatch(str, "i)^\s*(?:(\d{4})([\s\-:\/])(\d{1,2})\2(\d{1,2}))?(?:\s*[T\s](\d{1,2})([\s\-:\/])(\d{1,2})(?:\6(\d{1,2})\s*(?:(Z)|(\+|\-)?(\d{1,2})\6(\d{1,2})(?:\6(\d{1,2}))?)?)?)?\s*$", &i) { ;ISO 8601 timestamps
		year := i.1, month := i.3, day := i.4, hour := i.5, minute := i.7, second := i.8
	}
	else if !RegExMatch(str, "^\W*(?<Hour>\d{1,2}+)(?<Minute>\d{2})\W*$", &t){ ; NOT timestring only eg 1535
		; Try to extract the time parts
		FoundPos := RegExMatch(str, "i)(\d{1,2})"	;hours
				. "\s*:\s*(\d{1,2})"				;minutes
				. "(?:\s*:\s*(\d{1,2}))?"			;seconds
				. "(?:\s*([ap]m))?", &timepart)		;am/pm
		if (FoundPos) {
			; Time is already parsed correctly from striing
			hour := timepart.1
			minute := timepart.2
			second := timepart.3
			ampm:= timepart.4
			; Remove time to parse the date part only
			str := StrReplace(str, timepart.0)
		}
		; Now handle the remaining string without time and try to extract date ...
		if RegExMatch(str, "Ji)" . dayAndMonthName . "[^a-zA-Z0-9]*(?<Year>(?:\d{4}|\d{2}))?", &d) { ; named month eg 22May14; May 14, 2014; 22May, 2014
			year := d.Year, month := d.Month, day := d.Day
		}
		else if RegExMatch(str, "i)" . monthNameAndYear, &d) { ; named month and year without day eg May14; May 2014
			year := d.Year, month := d.Month
		}
		else if RegExMatch(str, "i)" . "^\W*(?<Year>\d{4})(?<Month>\d{2})\W*$", &d) { ;  month and year as digit only eg 201710
			year := d.Year, month := d.Month
		}
		else {
			; Default values - if some parts are not given
			if (not IsSet(day) and not IsSet(month) and not IsSet(year)) {
				; No datepart is given - use today
				year :=  A_YYYY
				month :=  A_MM
				day :=  A_DD
			}
			if RegExMatch(str, "i)(\d{4})[^a-zA-Z0-9:.]+" . dayAndMonth, &d) { ;2004/22/03
				year := d.1, month := d.3, day := d.2
			}
			else if RegExMatch(str, "i)" . dayAndMonth . "(?:[^a-zA-Z0-9:.]+((?:\d{4}|\d{2})))?", &d) { ;22/03/2004 or 22/03/04
				year := d.3, month := d.2, day := d.1
			}
			if (RegExMatch(day, monthNames) or americanOrder and !RegExMatch(month, monthNames) or (month > 12 and day <= 12)) { ;try to infer day/month order
				tmp := month, month := day, day := tmp
			}
		}
	}
	else if RegExMatch(str, "^\W*(?<Hour>\d{1,2}+)(?<Minute>\d{2})\W*$", &timepart){ ; timestring only eg 1535
		hour := timepart.hour
		minute := timepart.minute
		; Default values - if some parts are not given
		if (not IsSet(day) and not IsSet(month) and not IsSet(year)) {
			; No datepart is given - use today
			year :=  A_YYYY
			month :=  A_MM
			day :=  A_DD
		}
	}

	if (IsSet(day) or IsSet(month) or IsSet(year)) and not (IsSet(day) and IsSet(month) and IsSet(year)) { ; partial date
		if (IsSet(year) and not IsSet(month)) or not (IsSet(day) or IsSet(month)) or (IsSet(hour) and not IsSet(day)) { ; partial date must have month and day with time or day or year without time
			return
		}
	}

	; Default values - if some parts are not given
	if (IsSet(year) and IsSet(month) and not IsSet(day)) {
		; year and month given without day - use first day
		day := 1
	}

	; Format the single parts
	oYear := (StrLen(year) == 2 ? "20" . year : (year))
	oYear := Format("{:02.0f}", oYear)

	if (isInteger(month)) {
		currMonthInt := month
	} else {
		currMonthInt := InStr(monthNames, SubStr(month, 1, 3)) //  4
	}
	; Original: oMonth := ((month := month + 0 ? month : InStr(monthNames, SubStr(month, 1, 3)) // 4 ) > 0 ? month + 0.0 : A_MM)
	; oMonth := ((month := month + 0 ? month : currMonthInt ) > 0 ? month + 0.0 : A_MM)
	; oMonth := Format("{:02.0f}", oMonth)
	oMonth := Format("{:02.0f}", currMonthInt)

	oDay := day
	oDay := Format("{:02.0f}", oDay)

	if (IsSet(hour)) {
		if (hour != "") {
			oHour := hour + (hour == 12 ? ampm = "am" ? -12.0 : 0.0 : ampm = "pm" ? 12.0 : 0.0)
			oHour := Format("{:02.0f}", oHour)

			if (IsSet(minute)) {
				oMinute := minute + 0.0
				oMinute := Format("{:02.0f}", oMinute)

				if (IsSet(second)) {
					if (second != "") {
						oSecond := second + 0.0
						oSecond := Format("{:02.0f}", oSecond)
					}
				}
			}
		}
	}

	retVal := oYear . oMonth . oDay
	if (IsSet(oHour)){
		retVal := retVal . oHour . oMinute
		if (IsSet(oSecond)) {
			retVal := retVal . oSecond
		}
	}
	return retVal
}
