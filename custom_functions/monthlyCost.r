if ((prop("Recurrence") == "Once"), 
  0 ,
  if ((prop("Recurrence") == "4Weeks"),
     (prop("Cost") / 28 * 31),
    if((prop("Recurrence") == "Monthly"), 
      prop("Cost"), 
      (prop("Cost") / 12)
    )
  )
)