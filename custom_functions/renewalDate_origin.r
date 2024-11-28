if(
	prop("Recurrence") == "Monthly",
	let(
		monthGap,
		dateBetween(
			now().dateSubtract(1,"days"),
			prop("Charge Date"),
			"months"
		),
		prop("Charge Date").dateAdd(monthGap+1,"months")
	),
	let(
		yearGap,
		dateBetween(
			now().dateSubtract(1,"days"),
			prop("Charge Date"),
			"years"
		),
		prop("Charge Date").dateAdd(yearGap+1,"years")
	)
)