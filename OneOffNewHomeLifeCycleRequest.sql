
--1/07/2016 -- 30/06/2017 -- St
-- LifeCycle -- For Sale to Completed -- Status
--Age = New Home

-- Address Age Branch Commission (History tab)

/*
  POC = 22185568
*/
-- AGEID = 1000217
SELECT tmp.BranchReference,tmp.Address,tmp.[New Home],tmp.Commission,TMP.[InstructionDate],tmp.PropertyStatus
FROM(
	SELECT --[InstructionDate] = [dbo].prop_GetOrigInstDate(property.PropertyReference),
		   [InstructionDate] = pc.InstructionDate,
		   [Address] = [dbo].[GetAddressP](property.PropertyReference),
		   [PropertyStatus] = [dbo].[GetPropertyStatusDesc](PropertyStatus),
		   [Commission] = CASE 
						WHEN FeeType = 0 THEN CAST(FeeRate AS VARCHAR(10)) 
						ELSE ''
					 END,
		--    property_statusChk = (
					--CASE 
					--	WHEN Property.PropertyStatus IN (2,5) THEN 'For sale' 
					--	WHEN Property.PropertyStatus IN (6,9) THEN 'Under offer' 
					--	WHEN Property.PropertyStatus = 7 THEN 'Contracts exchanged' 
					--	WHEN Property.PropertyStatus = 8 THEN 'Sold'
					--	ELSE NULL
					--END),
		   [New Home] = dbo.GetAttributeDesc(Property.PropertyAgeID),
		   property.BranchReference
	FROM PROPERTY
	INNER JOIN PropertyStatus WITH (NOLOCK) ON Property.PropertyStatus = PropertyStatus.[Status] AND PropertyStatus.[Status] >= 2
	LEFT JOIN(
			SELECT PropertyReference,MIN(DateChanged) AS InstructionDate 
			FROM PropertyChanges
			WHERE ChangeType = 1 AND NewValue = 2  
			GROUP BY PropertyReference
	)PC ON property.PropertyReference = pc.PropertyReference
	LEFT JOIN MarketAppraisal WITH (NOLOCK) ON Property.PropertyReference = MarketAppraisal.PropertyReference AND MarketAppraisal.HalfCommission != 1
	WHERE --property.PropertyReference = 2185568
	 Property.PropertyAgeID = 1000217 -- New Home
	AND [dbo].prop_GetOrigInstDate(property.PropertyReference) BETWEEN '2016-07-01 00:00:21.553' AND '2017-06-30 23:59:21.553'
)tmp
ORDER BY tmp.BranchReference,tmp.Address--,tmp.InstructionDate


--1/07/2016 -- 30/06/2017 -- St