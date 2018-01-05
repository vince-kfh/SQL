USE RadarKFH
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

IF OBJECT_ID('tempdb..#LastViewing') IS NOT NULL DROP TABLE #LastViewing
IF OBJECT_ID('tempdb..#ClientEmailAddresses') IS NOT NULL DROP TABLE #ClientEmailAddresses

SELECT * INTO #LastViewing FROM (
 SELECT VF.pprovf_Instruction, MAX(VFA.xapp_End) AS LastViewed
 FROM pPropViewingFeedback VF WITH (NOLOCK)
 INNER JOIN xAppointment VFA WITH (NOLOCK) ON VF.pprovf_Appointment = VFA.xapp_ID AND VFA.xapp_IsCompleted = 1 AND VFA.xapp_IsArchived = 0
 GROUP BY VF.pprovf_Instruction
) AS #LastViewing


CREATE NONCLUSTERED INDEX #NIX_LastViewing ON #LastViewing(pprovf_Instruction ASC)

SELECT * INTO #ClientEmailAddresses FROM
(
	SELECT 
	ClientID = xClient.xcli_ID,
	ROW_NUMBER() OVER(PARTITION BY xClient.xcli_ID ORDER by  xClientParty.xcpty_Index) AS ClientIndex,
	--xClientParty.xcpty_Index AS ClientIndex,
	KnownAs = CASE WHEN CHARINDEX(' ', xContact.xcnt_Firstname, 0) < 1 THEN xContact.xcnt_Firstname ELSE LEFT(xContact.xcnt_Firstname, CHARINDEX(' ', xContact.xcnt_Firstname, 0) - 1) END, 
	EmailAddress = xComm.xcom_Email1
	FROM xClient WITH (NOLOCK)
	INNER JOIN xClientType WITH (NOLOCK) ON xClient.xcli_ID = xClientType.xclt_Client
	INNER JOIN xClientParty WITH (NOLOCK) ON xClient.xcli_ID = xClientParty.xcpty_Client
	INNER JOIN xContact WITH (NOLOCK) ON xContact.xcnt_ID = xClientParty.xcpty_Contact
	INNER JOIN xComm WITH (NOLOCK) ON xcom_Owner = xContact.xcnt_ID
	WHERE xClientType.xclt_Type IN
	(
		'FE1ED5C2-FAE6-4574-8A58-34B85F9E4D34' -- Landlord
	)
	AND  xClientParty.xcpty_Index != -1
) AS ClientEmailAddresses


CREATE NONCLUSTERED INDEX #NIX_ClientEmailAddresses ON #ClientEmailAddresses(ClientID ASC)



IF OBJECT_ID('tempdb..#CurrentData') IS NOT NULL DROP TABLE #CurrentData
SELECT * INTO #CurrentData FROM (

SELECT
[Landlord ID] = xClient.xcli_ReferenceCode,
[Landlord Type] = CT.xlib_Desc,
[Date Registered] = xClient.xcli_DateRegistered,
[Registered Office] = xOffice.xof_Ref,
[Registered Office Name] = xOffice.xof_Name,
[Landlord Title] = xContact.xcnt_Title,
[Landlord Forename] = xContact.xcnt_Firstname,
[Landlord Surname] = xContact.xcnt_Surname,
[Landlord Name] = xContact.xcnt_Name,
[Correspondence Property] = RTRIM(LTRIM(RTRIM(LTRIM(xAddress.xadr_Unit)) + ' ' + RTRIM(LTRIM(xAddress.xadr_Block)))),
[Correspondence Street] = RTRIM(LTRIM(RTRIM(LTRIM(xAddress.xadr_StreetNo)) + ' ' + RTRIM(LTRIM(xAddress.xadr_Street)))),
[Correspondence Locality] = RTRIM(LTRIM(xAddress.xadr_District)),
[Correspondence Town] = RTRIM(LTRIM(xAddress.xadr_Town)),
[Correspondence Postcode] = xAddress.xadr_PostCode,
[Property ID] = CAST(Prop.ppro_ID AS VARCHAR(36)),
[Property Office] = Prop.OwningOfficeID,
[Property Office Name] = Prop.OwningOffice,
[Property] = RTRIM(LTRIM(RTRIM(LTRIM(Prop.ppro_Unit)) + ' ' + RTRIM(LTRIM(Prop.ppro_Block)))),
[Street] = RTRIM(LTRIM(RTRIM(LTRIM(Prop.ppro_StreetNo)) + ' ' + RTRIM(LTRIM(Prop.ppro_Street)))),
[Locality] = RTRIM(LTRIM(Prop.ppro_District)),
[Town] = RTRIM(LTRIM(Prop.ppro_Town)),
[Postcode] = Prop.ppro_PostCode,
Prop.PropertyType, Prop.PropertyTypeCode,
LLStatusCode = Prop.LLCode,
LLStatusDesc = Prop.LLDesc,
SLStatusCode = Prop.SLCode,
SLStatusDesc = Prop.SLDesc,
LLInstType = Prop.LLInstType,
LLInstTypeCode = Prop.LLInstTypeCode,
SLInstType = Prop.SLInstType,
SLInstTypeCode = Prop.SLInstTypeCode,
MAStatus = Prop.MAStatus,
--MAValuedDays = DATEDIFF(DAY,Prop.MAValDate,GETDATE()),
MAValuedDays = NULL,
MAValued = Prop.MAValDate,
--MALastViewedLLDays = DATEDIFF(DAY,Prop.MALastViewedLL,GETDATE()),
MALastViewedLLDays = NULL,
--MALastViewedSLDays = DATEDIFF(DAY,Prop.MALastViewedSL,GETDATE()),
MALastViewedSLDays=NULL,
MALastViewedLL = Prop.MALastViewedLL,
MALastViewedSL = Prop.MALastViewedSL,
[Phone] = xComm.xcom_Phone1,
[Email] = COALESCE((SELECT TOP 1 EmailAddress FROM #ClientEmailAddresses WHERE ClientID = xClient.xcli_ID AND ClientIndex = 1), ''),
[Mobile] = xComm.xcom_Mobile1,
[Fax] = xComm.xcom_Fax1,
WithdrawnReason,
WithdrawnChaseDate = NULL,
InstructionDate,
UnderOfferDate,
CompletedDate,
RenewalDate = NULL,
LiveTenancy = CASE WHEN TenancyEnd > GETDATE() THEN 'Y' ELSE 'N' END,
[AllowPost] = 'Y',--CASE WHEN (xcli_InternationalMkt = 1) THEN 'Y' ELSE 'N' END,
[AllowEmail] = 'Y',--CASE WHEN (xcli_InternationalMkt = 1) THEN 'Y' ELSE 'N' END,
[AllowSMS] = 'Y',--CASE WHEN (xcli_InternationalMkt = 1) THEN 'Y' ELSE 'N' END,
[AllowPhone] = 'Y',--CASE WHEN (xcli_InternationalMkt = 1)  THEN 'Y' ELSE 'N' END,
[TenancyEnd] = TenancyEnd,
[Source_Dupe] = 'N',
InstructionNotWonReasons = CASE WHEN ppmd_NotWonReason IS NOT NULL THEN dbo.xfnLibraryName(ppmd_NotWonReason) ELSE '' END,
TenancyStartDate = TenancyStart,
LandlordWithdrawnDate = WithdrawnDate,
[KnownAs1] = COALESCE((SELECT TOP 1 KnownAs FROM #ClientEmailAddresses WHERE ClientID = xClient.xcli_ID AND ClientIndex = 1), ''),
[EmailAddress2] = COALESCE((SELECT TOP 1 EmailAddress FROM #ClientEmailAddresses WHERE ClientID = xClient.xcli_ID AND ClientIndex = 2), ''),
[KnownAs2] = COALESCE((SELECT TOP 1 KnownAs FROM #ClientEmailAddresses WHERE ClientID = xClient.xcli_ID AND ClientIndex = 2), ''),
[EmailAddress3] = COALESCE((SELECT TOP 1 EmailAddress FROM #ClientEmailAddresses WHERE ClientID = xClient.xcli_ID AND ClientIndex = 3), ''),
[KnownAs3] = COALESCE((SELECT TOP 1 KnownAs FROM #ClientEmailAddresses WHERE ClientID = xClient.xcli_ID AND ClientIndex = 3), ''),
[EmailAddress4] = COALESCE((SELECT TOP 1 EmailAddress FROM #ClientEmailAddresses WHERE ClientID = xClient.xcli_ID AND ClientIndex = 4), ''),
[KnownAs4] = COALESCE((SELECT TOP 1 KnownAs FROM #ClientEmailAddresses WHERE ClientID = xClient.xcli_ID AND ClientIndex = 4), '')
FROM pLandlord WITH (NOLOCK)
LEFT JOIN xClient WITH (NOLOCK) ON xClient.xcli_ID = pLandlord.pll_Client
LEFT JOIN xContact WITH (NOLOCK) ON xContact.xcnt_ID = xClient.xcli_DefaultContact
LEFT JOIN xComm WITH (NOLOCK) ON xContact.xcnt_ID = xComm.xcom_Owner
LEFT JOIN xAddressLink WITH (NOLOCK) ON xAddressLink.xadrl_Contact = xContact.xcnt_ID AND xAddressLink.xadrl_Type = 'A6F54051-F804-4E12-A3AC-0FDA48E8D1A6' AND xadrl_TypeIndex = 0
LEFT JOIN xAddress WITH (NOLOCK) ON xAddressLink.xadrl_Address = xAddress.xadr_ID
LEFT JOIN (
 SELECT pPropOwner.ppown_Client, pProp.*,
 LLCode = A1Status.xlib_Code, LLDesc = A1Status.xlib_Desc,
 SLCode = A2Status.xlib_Code, SLDesc = A2Status.xlib_Desc,
 LLInstType = A1IT.pist_Desc, LLInstTypeCode = A1IT.pist_Code,
 SLInstType = A2IT.pist_Desc, SLInstTypeCode = A2IT.pist_Code,
 MAStatus = MAStatus.xlib_Desc, MAValDate = VAL.xapp_Start,
 MALastViewedLL = ViewingsSummary.LastViewed, MALastViewedSL = ViewingsSummary2.LastViewed,
 PropertyType = PropType.xlib_Desc, PropertyTypeCode = PropType.xlib_Code,
 COALESCE(A2Office.xof_Ref, A1Office.xof_Ref) AS OwningOfficeID, COALESCE(A2Office.xof_Name,A1Office.xof_Name) AS OwningOffice,
 COALESCE(WithdrawnReasonLL.xlib_Desc, WithdrawnReasonSL.xlib_Desc) AS WithdrawnReason,
 COALESCE(A1.ppin_DeInstructed, A2.ppin_DeInstructed) AS WithdrawnDate,
 COALESCE(A1.ppin_DateCreated, A2.ppin_DateCreated) AS InstructionDate,
 A1.ppin_ID AS LLInstructionID, A2.ppin_ID AS SLInstructionID,
 UnderOfferDate.UnderOfferDate,
 CompletedDate.CompletedDate,
 WithdrawnChaseDate.WithdrawnChaseDate,
 LiveTenancies.TenancyStart,
 LiveTenancies.TenancyEnd,
 ppmd_NotWonReason
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
 
 LEFT JOIN (
 SELECT a.xlib_ID AS ID, b.xlib_Desc, b.xlib_Code
 FROM xLibrary a WITH (NOLOCK)
 INNER JOIN xLibrary b WITH (NOLOCK) ON a.xlib_LibraryType = '556C0F44-C6A6-4074-A22E-82066FE1CEC1' AND a.xlib_Parent = b.xlib_ID
 ) PropType ON PropType.ID = pPropdra.ppdra_Type
 
 LEFT JOIN xAppointment VAL WITH (NOLOCK) ON VAL.xapp_ID = pPropMA.ppma_Appointment
 LEFT JOIN #LastViewing AS ViewingsSummary ON A1.ppin_ID = ViewingsSummary.pprovf_Instruction
 LEFT JOIN #LastViewing AS ViewingsSummary2 ON A2.ppin_ID = ViewingsSummary2.pprovf_Instruction
 LEFT JOIN xLibrary WithdrawnReasonLL WITH (NOLOCK) ON WithdrawnReasonLL.xlib_ID = A1.ppin_DeInstructedReason
 LEFT JOIN xLibrary WithdrawnReasonSL WITH (NOLOCK) ON WithdrawnReasonSL.xlib_ID = A2.ppin_DeInstructedReason
 
 LEFT JOIN (
  SELECT A.pde_Instruction, MAX(paprt_TenancyStart) AS TenancyStart, MAX(paprt_TenancyEnd) AS TenancyEnd
  FROM pDeal A WITH (NOLOCK)
  INNER JOIN pAprTenancy B WITH (NOLOCK) ON A.pde_ID = B.paprt_Deal AND B.paprt_TenancyStatus != 'T'
  GROUP BY A.pde_Instruction
 ) AS LiveTenancies ON LiveTenancies.pde_Instruction = A1.ppin_ID OR LiveTenancies.pde_Instruction = A2.ppin_ID

 LEFT JOIN (
  SELECT ppin_ID, MAX(xstl_Date) AS UnderOfferDate
  FROM pDeal WITH (NOLOCK)
  INNER JOIN pPropIN WITH (NOLOCK) ON ppin_ID = pde_Instruction
  INNER JOIN xStatusLog WITH (NOLOCK) ON xstl_Source = pde_ID AND xStatusLog.xstl_NewStatus = '1C4076D3-E09C-409C-9792-F3F86B8281A6' -- ADM:Under Offer
  GROUP BY ppin_ID
 ) AS UnderOfferDate ON UnderOfferDate.ppin_ID = COALESCE(A1.ppin_ID, A2.ppin_ID)
 
 LEFT JOIN (
  SELECT ppin_ID, MAX(xstl_Date) AS CompletedDate
  FROM pDeal WITH (NOLOCK)
  INNER JOIN pPropIN WITH (NOLOCK) ON ppin_ID = pde_Instruction
  INNER JOIN xStatusLog WITH (NOLOCK) ON xstl_Source = pde_ID AND xStatusLog.xstl_NewStatus = '6CF51E96-0733-485E-B0E0-A7AD331D002E' -- COM:Completed
  GROUP BY ppin_ID
 ) AS CompletedDate ON CompletedDate.ppin_ID = COALESCE(A1.ppin_ID, A2.ppin_ID)
 
 LEFT JOIN (
  SELECT xc_Context, MAX(xc_Due) AS WithdrawnChaseDate FROM xChase WITH (NOLOCK)
  WHERE xc_ContextType = 'i' -- Instruction
  GROUP BY xc_Context
 ) AS WithdrawnChaseDate ON WithdrawnChaseDate.xc_Context = COALESCE(A1.ppin_ID, A2.ppin_ID)
 
 WHERE pPropOwner.ppown_Current = 1 AND ppro_ID IS NOT NULL --AND pProp.ppro_Hidden = 0

) Prop ON Prop.ppown_Client = pLandlord.pll_Client

INNER JOIN xClientType WITH (NOLOCK) ON xClientType.xclt_Client = xClient.xcli_ID AND xClientType.xclt_Type = 'FE1ED5C2-FAE6-4574-8A58-34B85F9E4D34' -- LL:Landlord
LEFT JOIN xOffice WITH (NOLOCK) ON xOffice.xof_Id = xClient.xcli_Office
LEFT JOIN xLibrary CT WITH (NOLOCK) ON pLandlord.pll_LandlordType = CT.xlib_ID
WHERE xcli_DateRegistered >= '2008-01-01 00:00:00' AND Prop.ppro_ID IS NOT NULL AND CT.xlib_ID NOT IN
(
'1E040F90-4D2A-457A-BC34-72CA38AADA4F', -- 10:Trust
'294697CD-781C-4B16-B66F-86467F402A80' -- OAG:Other Agent
)
--AND (xcli_Post = 1 OR xcli_Email = 1) -- Mailing preferences

) AS CurrentData
