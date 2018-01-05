	/*
	  Data-Subscription for Land and new Homes
	*/
	SELECT  eDate = CONVERT(VARCHAR(20),DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0),111),sDate = CONVERT(VARCHAR(20),DATEADD(Week,-1,DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0)),111),RegionName = 'LandAndNewHomes', DirectorReference = 'JEAST', DirectorName = 'John East', DirectorEmail = 'jeast@kfh.co.uk', RegionReference = 100
		UNION ALL
	SELECT  eDate = CONVERT(VARCHAR(20),DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0),111),sDate = CONVERT(VARCHAR(20),DATEADD(Week,-1,DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0)),111),RegionName = 'LandAndNewHomes', DirectorReference = 'TONEILL', DirectorName = 'Tony ONeill', DirectorEmail = 'aoneill@kfh.co.uk', RegionReference = 100
		UNION ALL
 	SELECT  eDate = CONVERT(VARCHAR(20),DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0),111),sDate = CONVERT(VARCHAR(20),DATEADD(Week,-1,DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0)),111),RegionName = 'LandAndNewHomes', DirectorReference = 'NTURNER', DirectorName = 'Nick Turner', DirectorEmail = 'nturner@kfh.co.uk', RegionReference = 100
		UNION ALL
	SELECT  eDate = CONVERT(VARCHAR(20),DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0),111),sDate = CONVERT(VARCHAR(20),DATEADD(Week,-1,DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0)),111),RegionName = 'LandAndNewHomes', DirectorReference = 'NHSEST', DirectorName = 'New Homes SE', DirectorEmail = 'newhomesse@kfh.co.uk', RegionReference = 100
		UNION ALL
	SELECT  eDate = CONVERT(VARCHAR(20),DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0),111),sDate = CONVERT(VARCHAR(20),DATEADD(Week,-1,DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0)),111),RegionName = 'LandAndNewHomes', DirectorReference = 'NHOME', DirectorName = 'NewHome', DirectorEmail = 'newhomes@kfh.co.uk', RegionReference = 100
