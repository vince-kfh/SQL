SELECT Region = R.Description,
P.BranchReference,P.PropertyReference,
           Address = dbo.GetAddressP(P.PropertyReference),--,OutcomeDesc = MAO.Description,
            BusinessLostReason = dbo.GetAttributeDesc(MA.LostToReasonID)
FROM dbo.Property AS P
INNER JOIN PropertyStatus ON PropertyStatus.Status = P.PropertyStatus AND PropertyStatus.Status = 1 -- 'Valuation archived'
INNER JOIN MarketAppraisal MA ON P.PropertyReference = MA.PropertyReference
INNER JOIN MarketAppraisalOutcome MAO ON MA.Outcome = MAO.Outcome AND MAO.Outcome = 2 -- Business lost
INNER JOIN RegionBranches RB ON P.BranchReference = RB.BranchReference
INNER JOIN Region R ON R.RegionReference = RB.RegionReference
ORDER BY P.RegionID,rb.BranchReference,P.PropertyReference


