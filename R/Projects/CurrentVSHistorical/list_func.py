def alternateList(teams_date, teams_record):
	
    return [sub[item] for item in range(len(teams_record)) 
                      for sub in [teams_date, teams_record]] 