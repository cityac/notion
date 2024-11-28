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
	if(
		prop("Recurrence") == "4Weeks",
		let(
			fourWeeksGap,
			dateBetween(
				now().dateSubtract(1,"days"),
				prop("Charge Date"),
				"days"
			),
			prop("Charge Date").dateAdd(28,"days")
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
)