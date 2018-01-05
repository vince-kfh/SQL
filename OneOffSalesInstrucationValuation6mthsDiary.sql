DECLARE @startdate DATETime =  DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
DECLARE @enddate DATETime = DATEADD(MONTH,7,@startdate)

SELECT BranchReference,
     StreetName = REPLACE(V.StreetName,',',' '),
	Town,
	County,
	PostCode,
	Bedrooms = Beds,
	PropertyStatus = 'Appointment',
	AppointmentBooked = CONVERT(VARCHAR(20),A.CreationDate,103),
	AppointmentConducted = CONVERT(VARCHAR(20),A.EndTime,103)
FROM
	Valuation V
INNER JOIN
	Appointment A ON V.AppointmentNo = A.AppointmentNo
WHERE A.StartTime BETWEEN @startdate AND @enddate
ORDER BY A.BranchReference,A.StartTime






--SELECT TOP 1 
--	BranchReference,
--	BuildingNumber,
--	BuildingName,
--	StreetNumber,
--	StreetName,
--	Town,
--	County,
--	PostCode,
--	PropertyTypeID,
--	Bedrooms,
--	PropertyStatus = PS.Description
--FROM
--	Property P
--INNER JOIN
--	PropertyStatus PS ON P.PropertyStatus = PS.Status
--WHERE p.PropertyReference = 2184761 
--      --AND P.PropertyStatus IN (0, 1, 4, 8)
--UNION ALL