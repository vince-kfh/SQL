/*
   1. One Off Sales
*/

-- Can you please re-run these reports again for the period of 1st January 2017 to 31st October 2017.


DECLARE @startdate DATETime =  '2017-01-01 01:59:32.000'--DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
DECLARE @enddate DATETime = '2017-10-31 20:59:32.000'--DATEADD(MONTH,7,@startdate)

--SELECT GETDATE()

--SELECT @startdate,@enddate
SELECT 
R.RegionReference,
Region = R.Description,
P.BranchReference,
ValuationDate = CONVERT(VARCHAR(20),RVD.DateChanged,103),-- AS DATE),
P.PropertyReference,
--Address = dbo.GetAddressP(P.PropertyReference),
RecommendedAskingPrice = MA.InitialPrice,
InstructionDate = dbo.prop_GetOrigInstDate(P.PropertyReference),
--MA.Outcome,
--OutcomeDesc = MAO.Description,
LostToAgent = dbo.GetAttributeDesc(MA.LostToAgent),
--P.PropertyStatus,
--PropertyStatusDescription = PS.Description,
--Valuated = 1,
MA.Valuer,
BusinessLostReason = dbo.GetAttributeDesc(MA.LostToReasonID),
--DateCompleted = AppointmentDateTime,
  property_Floor = a.AttributeText,
  property_BuildingNumber = p.BuildingNumber,
  property_BuildingName =  p.BuildingName,
  Property_StreetNumber = p.StreetNumber,
  Property_StreetName = p.StreetName,
  Property_Town = p.Town,
  Property_County = p.County,
  Property_PostCode = P.PostCode,
  --'VendorDetails',
  Vendor_BuildingNumber = vca.BuildingNumber,
  Vendor_BuildingName = vca.BuildingName,
  Vendor_StreetNumber =  vca.StreetNumber,
  Vendor_StreeetName = vca.StreetName,
  Vendor_Town = vca.Town,
  Vendor_County= vca.County,
  Vendor_PostCode = vca.PostCode
 --appointment.*
FROM Property P
INNER JOIN MarketAppraisal MA ON P.PropertyReference = MA.PropertyReference
AND MA.HalfCommission = 0 AND COALESCE(MA.AgencyType,0) <> 3 -- Half Comm
INNER JOIN PropertyChanges RVD ON P.PropertyReference = RVD.PropertyReference AND RVD.ChangeType = 1 AND RVD.NewValue = 0
INNER JOIN RegionBranches RB ON P.BranchReference = RB.BranchReference
INNER JOIN Region R ON R.RegionReference = RB.RegionReference
INNER JOIN PropertyStatus PS ON P.PropertyStatus = PS.Status
INNER JOIN MarketAppraisalOutcome MAO ON MA.Outcome = MAO.Outcome
INNER JOIN dbo.Attribute AS A ON p.FloorLevelID = a.AttributeID
--Vendor
INNER JOIN 
	Contact AS VendorContact WITH (NOLOCK) ON p.ContactReference = VendorContact.ContactReference
INNER JOIN
	ContactAddress AS vca WITH (NOLOCK) ON VendorContact.ContactReference = vca.ContactReference AND VendorContact.PrimaryContact = vca.ContactNo
WHERE RVD.DateChanged BETWEEN @startdate AND @enddate
--AND p.PropertyReference = 2184373
ORDER BY P.RegionID,P.BranchReference, RVD.DateChanged


--



