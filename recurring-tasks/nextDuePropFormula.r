if(!empty(prop("Recur Interval")) and !empty(prop("Due")),
    if(prop("Recur Interval") > 0 and prop("Recur Interval") == ceil(prop("Recur Interval")),
        lets(
            debug, false,
            
            recurUnit, ifs(
                or(prop("Recur Unit") == at(at(prop("Localization Key"), 1), 0), prop("Recur Unit") == "Day(s)"), "days",
                or(prop("Recur Unit") == at(at(prop("Localization Key"), 1), 1), prop("Recur Unit") == "Week(s)"), "weeks",
                or(prop("Recur Unit") == at(at(prop("Localization Key"), 1), 2), prop("Recur Unit") == "Month(s)"), "months",
                or(prop("Recur Unit") == at(at(prop("Localization Key"), 1), 3), prop("Recur Unit") == "Year(s)"), "years",
                or(prop("Recur Unit") == at(at(prop("Localization Key"), 1), 4), prop("Recur Unit") == "Month(s) on the Last Day"), "monthsonthelastday",
                or(prop("Recur Unit") == at(at(prop("Localization Key"), 1), 5), prop("Recur Unit") == "Month(s) on the First Weekday"), "monthsonthefirstweekday",
                or(prop("Recur Unit") == at(at(prop("Localization Key"), 1), 6), prop("Recur Unit") == "Month(s) on the Last Weekday"), "monthsonthelastweekday",
                "days"
            ),
            
            weekdays, match([
                if(
                    or(includes(prop("Days (Only if Set to 1 Day(s))"), at(at(prop("Localization Key"), 0), 1 - 1)), includes(prop("Days (Only if Set to 1 Day(s))"), "Monday")), 1, false
                ),
                
                if(
                    or(includes(prop("Days (Only if Set to 1 Day(s))"), at(at(prop("Localization Key"), 0), 2 - 1)), includes(prop("Days (Only if Set to 1 Day(s))"), "Tuesday")), 2, false
                ),
                
                if(
                    or(includes(prop("Days (Only if Set to 1 Day(s))"), at(at(prop("Localization Key"), 0), 3 - 1)), includes(prop("Days (Only if Set to 1 Day(s))"), "Wednesday")), 3, false
                ),
                
                if(
                    or(includes(prop("Days (Only if Set to 1 Day(s))"), at(at(prop("Localization Key"), 0), 4 - 1)), includes(prop("Days (Only if Set to 1 Day(s))"), "Thursday")), 4, false
                ),
                
                if(
                    or(includes(prop("Days (Only if Set to 1 Day(s))"), at(at(prop("Localization Key"), 0), 5 - 1)), includes(prop("Days (Only if Set to 1 Day(s))"), "Friday")), 5, false
                ),
                
                if(
                    or(includes(prop("Days (Only if Set to 1 Day(s))"), at(at(prop("Localization Key"), 0), 6 - 1)), includes(prop("Days (Only if Set to 1 Day(s))"), "Saturday")), 6, false
                ),
                
                if(
                    or(includes(prop("Days (Only if Set to 1 Day(s))"), at(at(prop("Localization Key"), 0), 7 - 1)), includes(prop("Days (Only if Set to 1 Day(s))"), "Sunday")), 7, false
                )
            ], "[1-7]"),
            
            dateDue, parseDate(formatDate(prop("Due"), "YYYY-MM-DD HH:mm")),
            
            dateDueEnd, parseDate(formatDate(dateEnd(prop("Due")), "YYYY-MM-DD HH:mm")),
            
            timeNow, now(),
            
            offsetTimeNow, dateAdd(timeNow, prop("UTC Offset"), "hours"),

            inUTC, if(formatDate(now(), "ZZ") == "+0000", true, false),
            
            hasValidOffset, if(!empty(prop("UTC Offset")) and prop("UTC Offset") >= -12 and prop("UTC Offset") <= 14, true, false),
            
            hasRange, dateEnd(dateDueEnd) > dateStart(dateDue),
            
            dueRange, dateBetween(dateDueEnd, dateDue, "minutes"),
            
            conditionalTimeNow, if(inUTC and hasValidOffset, offsetTimeNow, timeNow),
            
            conditionalDateNow, parseDate(formatDate(conditionalTimeNow, "YYYY-MM-DD")),
            
            recurUnitLapseLength, if(includes(["days", "weeks", "months", "years"], recurUnit), dateBetween(conditionalDateNow, dateDue, recurUnit) / prop("Recur Interval"), false),
            
            lastDayBaseDate, if(
                includes(["monthsonthelastday", "monthsonthefirstweekday", "monthsonthelastweekday"], recurUnit),
                if(year(conditionalDateNow) * 12 + month(conditionalDateNow) - (year(dateDue) * 12 + month(dateDue)) > 0,
                    dateSubtract(dateAdd(dateSubtract(dateAdd(dateDue, ceil((year(conditionalDateNow) * 12 + month(conditionalDateNow) - (year(dateDue) * 12 + month(dateDue))) / prop("Recur Interval")) * prop("Recur Interval"), "months"), date(dateAdd(dateDue, ceil((year(conditionalDateNow) * 12 + month(conditionalDateNow) - (year(dateDue) * 12 + month(dateDue))) / prop("Recur Interval")) * prop("Recur Interval"), "months")) - 1, "days"), 1, "months"), 1, "days"),
                    dateSubtract(dateAdd(dateSubtract(dateAdd(dateDue, prop("Recur Interval"), "months"), date(dateAdd(dateDue, prop("Recur Interval"), "months")) - 1, "days"), 1, "months"), 1, "days")),
                false
            ),
            
            firstDayBaseDate, if(lastDayBaseDate != false, dateSubtract(lastDayBaseDate, date(lastDayBaseDate) - 1, "days"), false),
            
            firstWeekdayBaseDate, if(lastDayBaseDate != false,
                if(
                    test(day(firstDayBaseDate), "6|7"), 
                    dateAdd(firstDayBaseDate, 8 - day(firstDayBaseDate), "days"),
                    firstDayBaseDate
                ),
                false
            ),
            
            lastWeekdayBaseDate, if(lastDayBaseDate != false,
                if(
                    test(day(lastDayBaseDate), "6|7"), 
                    dateSubtract(lastDayBaseDate, day(lastDayBaseDate) - 5, "days"),
                    lastDayBaseDate
                ),
                false
            ),
            
            nextLastBaseDate, if(lastDayBaseDate != false,
                dateSubtract(dateAdd(dateSubtract(dateAdd(lastDayBaseDate, prop("Recur Interval"), "months"), date(dateAdd(lastDayBaseDate, prop("Recur Interval"), "months")) - 1, "days"), 1, "months"), 1, "days"),
                false
            ),
            
            nextFirstBaseDate, if(lastDayBaseDate != false, dateSubtract(nextLastBaseDate, date(nextLastBaseDate) - 1, "days"), false),
            
            nextFirstWeekday, if(lastDayBaseDate != false,
                if(
                    test(day(nextFirstBaseDate), "6|7"), 
                    dateAdd(nextFirstBaseDate, 8 - day(nextFirstBaseDate), "days"),
                    nextFirstBaseDate
                ),
                false
            ),
            
            nextLastWeekday, if(lastDayBaseDate != false,
                if(
                    test(day(nextLastBaseDate), "6|7"), 
                    dateSubtract(nextLastBaseDate, day(nextLastBaseDate) - 5, "days"),
                    nextLastBaseDate
                ),
                false
            ),
            
            nextDueStart, ifs(
                recurUnit == "days" and length(weekdays) > 0 and prop("Recur Interval") == 1, 
                    if(conditionalDateNow >= dateDue,
                        ifs(
                            includes(weekdays, format(day(dateAdd(conditionalDateNow, 1, "days")))), dateAdd(conditionalDateNow, 1, "days"),
                            includes(weekdays, format(day(dateAdd(conditionalDateNow, 2, "days")))), dateAdd(conditionalDateNow, 2, "days"),
                            includes(weekdays, format(day(dateAdd(conditionalDateNow, 3, "days")))), dateAdd(conditionalDateNow, 3, "days"),
                            includes(weekdays, format(day(dateAdd(conditionalDateNow, 4, "days")))), dateAdd(conditionalDateNow, 4, "days"),
                            includes(weekdays, format(day(dateAdd(conditionalDateNow, 5, "days")))), dateAdd(conditionalDateNow, 5, "days"),
                            includes(weekdays, format(day(dateAdd(conditionalDateNow, 6, "days")))), dateAdd(conditionalDateNow, 6, "days"),
                            includes(weekdays, format(day(dateAdd(conditionalDateNow, 7, "days")))), dateAdd(conditionalDateNow, 7, "days"),
                            false
                        ),
                        ifs(
                            includes(weekdays, format(day(dateAdd(dateDue, 1, "days")))), dateAdd(dateDue, 1, "days"),
                            includes(weekdays, format(day(dateAdd(dateDue, 2, "days")))), dateAdd(dateDue, 2, "days"),
                            includes(weekdays, format(day(dateAdd(dateDue, 3, "days")))), dateAdd(dateDue, 3, "days"),
                            includes(weekdays, format(day(dateAdd(dateDue, 4, "days")))), dateAdd(dateDue, 4, "days"),
                            includes(weekdays, format(day(dateAdd(dateDue, 5, "days")))), dateAdd(dateDue, 5, "days"),
                            includes(weekdays, format(day(dateAdd(dateDue, 6, "days")))), dateAdd(dateDue, 6, "days"),
                            includes(weekdays, format(day(dateAdd(dateDue, 7, "days")))), dateAdd(dateDue, 7, "days"),
                            false
                        )
                    ),
                
                recurUnit == "monthsonthelastday", if(conditionalDateNow >= lastDayBaseDate, nextLastBaseDate, lastDayBaseDate),
                
                recurUnit == "monthsonthefirstweekday", if(conditionalDateNow >= firstWeekdayBaseDate, nextFirstWeekday, firstWeekdayBaseDate),
                
                recurUnit == "monthsonthelastweekday", if(conditionalDateNow >= lastWeekdayBaseDate, nextLastWeekday, lastWeekdayBaseDate),
                
                includes(["days", "weeks", "months", "years"], recurUnit), 
                    if(dateBetween(conditionalDateNow, dateDue, "days") >= 1,
                        if(recurUnitLapseLength == ceil(recurUnitLapseLength),
                            dateAdd(dateDue, (recurUnitLapseLength + 1) * prop("Recur Interval"), recurUnit),
                            dateAdd(dateDue, ceil(recurUnitLapseLength) * prop("Recur Interval"), recurUnit)
                        ),
                        dateAdd(dateDue, prop("Recur Interval"), recurUnit)
                    ),
                false
            ),
            
            nextDueEnd, if(hasRange and nextDueStart != false, 
                dateAdd(nextDueStart, dueRange, "minutes"),
                false
            ),
            
            nextDue, if(hasRange and nextDueEnd != false, dateRange(nextDueStart, nextDueEnd), nextDueStart),
            
            if(
                debug == true,
                "---------\n" + prop("Task") + "\n---------" +
                "\npropDue: " + prop("Due") +
                "\npropRecurInterval: " + prop("Recur Interval") +
                "\npropRecurUnit: " + prop("Recur Unit") +
                "\npropDays: " + prop("Days (Only if Set to 1 Day(s))") +
                "\npropLocalizationKey: " + prop("Localization Key") +
                "\npropLocalizationKeyFormatted: " + 
                    map(
                        prop("Localization Key"), 
                        ifs(index == 0,
                            "\n\tweekdays: " + current,
                            index == 1, "\n\trecur units: " + current,
                            false
                        )
                    ) +
                "\npropUTCOffset: " + prop("UTC Offset") +
                "\nrecurUnit: " + recurUnit +
                "\nweekdays: " + weekdays +
                "\ndateDue: " + dateDue +
                "\ndateDueEnd: " + dateDueEnd +
                "\ntimeNow: " + timeNow +
                "\noffsetTimeNow: " + offsetTimeNow +
                "\ninUTC: " + inUTC +
                "\nhasValidOffset: " + hasValidOffset +
                "\nhasRange: " + hasRange +
                "\ndueRange: " + dueRange +
                "\nconditionalTimeNow: " + conditionalTimeNow +
                "\nconditionalDateNow: " + conditionalDateNow +
                "\nrecurUnitLapseLength: " + recurUnitLapseLength +
                "\nlastDayBaseDate: " + lastDayBaseDate +
                "\nfirstDayBaseDate: " + firstDayBaseDate +
                "\nfirstWeekdayBaseDate: " + firstWeekdayBaseDate +
                "\nlastWeekdayBaseDate: " + lastWeekdayBaseDate +
                "\nnextLastBaseDate: " + nextLastBaseDate +
                "\nnextFirstBaseDate: " + nextFirstBaseDate +
                "\nnextFirstWeekday: " + nextFirstWeekday +
                "\nnextLastWeekday: " + nextLastWeekday +
                "\nnextDueStart: " + nextDueStart +
                "\nnextDueEnd: " + nextDueEnd +
                "\nnextDue: " + nextDue,
                nextDue
            )
        ),
    "Error: Non-Whole or Negative Recur Interval"),
"")