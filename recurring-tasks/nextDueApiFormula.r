if(test(prop("Next Due"), "Error") or empty(prop("Next Due")) or prop("Next Due") == false, 
    "∅", 
    "{\"start\":\"" + formatDate(dateStart(prop("Next Due")), "YYYY-MM-DDTHH:mm:ss.000") + 
    "\",\"end\":\"" + formatDate(dateEnd(prop("Next Due")), "YYYY-MM-DDTHH:mm:ss.000") + 
    "\"}")