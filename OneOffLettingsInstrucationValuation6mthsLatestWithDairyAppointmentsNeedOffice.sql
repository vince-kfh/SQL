/*
   Lettings Details -- Appriasals done for Jan\End of July

   1. Office Needed for null values -- 
	26 Pulborough Road -- Office detail needed - Southfields -- Part of Appraisal! - Mel
   2. Valuation Appointments -- Booked | Conducted.

*/

DECLARE @startdate DATETime =  DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
DECLARE @enddate DATETime = DATEADD(MONTH,7,@startdate)

--SELECT @startdate,@enddate

SELECT TOP 10 [Office] = CASE
							WHEN prop.A1Office Is NULL THEN prop.Mkoffice
							ELSE prop.A1Office
							end,
							[PropertyReference] = CAST(Prop.ppin_Reference AS VARCHAR(36)),
[Street] = RTRIM(LTRIM(RTRIM(LTRIM(Prop.ppro_StreetNo)) + ' ' + RTRIM(LTRIM(Prop.ppro_Street)))),
[Town] = RTRIM(LTRIM(Prop.ppro_Town)),
[Postcode] = Prop.ppro_PostCode,
--[Status] = Prop.LLDesc,
[LandlordUnit] = RTRIM(LTRIM(RTRIM(LTRIM(xAddress.xadr_Unit)) + ' ' + RTRIM(LTRIM(xAddress.xadr_Block)))),
[Landlord Street] = RTRIM(LTRIM(RTRIM(LTRIM(xAddress.xadr_StreetNo)) + ' ' + RTRIM(LTRIM(xAddress.xadr_Street)))),
[Landlord Town] = RTRIM(LTRIM(xAddress.xadr_Town)),
[Landlord PostCode] = RTRIM(LTRIM(xAddress.xadr_PostCode)),
InstructionType = Prop.LLInstType,
[BusinessType] = Prop.MAStatus,
--[BusinessType]= 'New Instruction',
[Marketing Office] = CASE
							WHEN prop.A1Office Is NULL THEN prop.Mkoffice
							ELSE prop.A1Office
							end,
[Base Type] = Prop.PropertyType,
DateBooked = CONVERT(VARCHAR(20),prop.ppmd_CreationDate,103),
DateConducted = CONVERT(VARCHAR(20),Prop.MAValDate,103)
FROM pLandlord WITH (NOLOCK)
LEFT JOIN xClient WITH (NOLOCK) ON xClient.xcli_ID = pLandlord.pll_Client
LEFT JOIN xContact WITH (NOLOCK) ON xContact.xcnt_ID = xClient.xcli_DefaultContact
LEFT JOIN xComm WITH (NOLOCK) ON xContact.xcnt_ID = xComm.xcom_Owner
LEFT JOIN xAddressLink WITH (NOLOCK) ON xAddressLink.xadrl_Contact = xContact.xcnt_ID AND xAddressLink.xadrl_Type = 'A6F54051-F804-4E12-A3AC-0FDA48E8D1A6' AND xadrl_TypeIndex = 0
LEFT JOIN xAddress WITH (NOLOCK) ON xAddressLink.xadrl_Address = xAddress.xadr_ID
--PropertyDetails
LEFT JOIN (
 SELECT a1.ppin_Reference,pPropOwner.ppown_Client, pProp.*,A1Office= A1Office.xof_Name,
 LLCode = A1Status.xlib_Code, LLDesc = A1Status.xlib_Desc,
 SLCode = A2Status.xlib_Code, SLDesc = A2Status.xlib_Desc,
 LLInstType = A1IT.pist_Desc, LLInstTypeCode = A1IT.pist_Code,
 PropertyType = PropType.xlib_Desc, PropertyTypeCode = PropType.xlib_Code,
 MAStatus = MAStatus.xlib_Desc, MAValDate = VAL.xapp_Start,--pPropMADetails.ppmd_CreationDate,
 pPropMADetails.*,
 Mkoffice = mkOffice.xof_Name
 FROM pPropOwner WITH (NOLOCK)
 LEFT JOIN pProp WITH (NOLOCK) ON pProp.ppro_ID = pPropOwner.ppown_Prop
 LEFT JOIN pPropStatus WITH (NOLOCK) ON pPropStatus.ppStatus_Property = pProp.ppro_ID
 LEFT JOIN pPropDRA WITH (NOLOCK) ON pPropDRA.ppdra_Prop = pProp.ppro_ID
 LEFT JOIN pPropMA WITH (NOLOCK) ON pPropMA.ppma_Id = pPropStatus.ppStatus_MaId
 LEFT JOIN pPropMADetails WITH (NOLOCK) ON pPropMA.ppma_Id = pPropMADetails.ppmd_MarketAppraisal
 LEFT JOIN pPropIN A1 WITH (NOLOCK) ON pPropStatus.ppStatus_InstructionLongLettings = A1.ppin_ID
 LEFT JOIN pInstructionType A1IT WITH (NOLOCK) ON A1IT.pist_ID = A1.ppin_InstructionType
 LEFT JOIN pPropIN A2 WITH (NOLOCK) ON pPropStatus.ppStatus_InstructionShortLettings = A2.ppin_ID
 LEFT JOIN pInstructionType A2IT WITH (NOLOCK) ON A2IT.pist_ID = A2.ppin_InstructionType
 LEFT JOIN xLibrary A1Status WITH (NOLOCK) ON A1.ppin_Status = A1Status.xlib_ID
 LEFT JOIN xLibrary A2Status WITH (NOLOCK) ON A2.ppin_Status = A2Status.xlib_ID
 LEFT JOIN xLibrary MAStatus WITH (NOLOCK) ON pPropStatus.ppStatus_MaLettingsStatus = MAStatus.xlib_ID
 LEFT JOIN xOffice A1Office WITH (NOLOCK) ON A1Office.xof_ID = A1.ppin_Office
 LEFT JOIN xOffice A2Office WITH (NOLOCK) ON A2Office.xof_ID = A2.ppin_Office
 LEFT JOIN xAppointment VAL WITH (NOLOCK) ON VAL.xapp_ID = pPropMA.ppma_Appointment
 --Market Appraisal Details
 LEFT JOIN pvwKPIstatsAppraisalsAttended kpiWITH (NOLOCK) ON pPropMADetails.ppmd_MarketAppraisal = kpiWITH.AppraisalId
 left JOIN xOffice mkOffice WITH (NOLOCK) ON mkOffice.xof_ID = kpiWITH.OfficeId
 LEFT JOIN (
 SELECT a.xlib_ID AS ID, b.xlib_Desc, b.xlib_Code
 FROM xLibrary a WITH (NOLOCK)
 INNER JOIN xLibrary b WITH (NOLOCK) ON a.xlib_LibraryType = '556C0F44-C6A6-4074-A22E-82066FE1CEC1' AND a.xlib_Parent = b.xlib_ID
 ) PropType ON PropType.ID = pPropdra.ppdra_Type
 
 WHERE pPropOwner.ppown_Current = 1 AND ppro_ID IS NOT NULL AND pProp.ppro_Hidden = 0

) Prop ON Prop.ppown_Client = pLandlord.pll_Client
WHERE RTRIM(LTRIM(RTRIM(LTRIM(Prop.ppro_StreetNo)) + ' ' + RTRIM(LTRIM(Prop.ppro_Street)))) LIKE  '26 Pulborough Road%'--'169 Sternhold Avenue'  --'30 Chestnut Grove%'
 --CAST(Prop.ppin_Reference AS VARCHAR(36)) = 'P124265'
 AND PROP.ppmd_MarketAppraisal = '0DCB878D-A02F-4FAD-84D3-F3A71EB859FD'
 AND Prop.MAValDate BETWEEN @startdate AND @enddate --2017-01-01 00:02:02.817' AND '2017-08-01 00:02:02.817' 
ORDER BY prop.A1Office,Prop.MAValDate DESC

--SELECT TOP 200 CONVERT(VARCHAR(20),ppmd_CompletedDate,103) ,* FROM pPropMADetails
--WHERE CONVERT(VARCHAR(20),ppmd_CompletedDate,103) = '31/07/2017' 
--AND ppmd_RecommendedPrice = 4000.00

GO
--SELECT *
--FROM dbo.pvwKPIstatsAppraisalsAttended AS PKIAA
--WHERE CONVERT(VARCHAR(20),PKIAA.Date,103) = '31/07/2017' 
--AND PKIAA.SalePrice = 4000.00
--SELECT *
--FROM dbo.xUser AS XU
--WHERE xu.xusr_ID = '303C676F-5706-4B4F-A491-DA6D80CC4C9D'
--GO
--SELECT *---xu.x0f_Name
--FROM dbo.xoffice AS XU
--WHERE XU.xof_Id = '68121525-3B81-45FA-A8F3-48DCC392A92D'

