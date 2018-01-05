/*
  EPC Full
*/
DECLARE @Database VARCHAR(15) = 'RadarKFH'

DECLARE @RunDate DATETIME = GETDATE()
DECLARE @DaysWarning INT = 3650

--DECLARE @pRegionName VARCHAR(100) = 'South West'
--DECLARE @SearchDate DATETIME = DATEADD(DAY,-@DaysWarning,@RunDate)

DECLARE @pTenancyChk BIT = 0


DECLARE @FilePath VARCHAR(100) = 'file://\\10.200.2.70\RadarData\' + @Database + '\cc587231-d18f-42c6-ad9f-dee4f9bb6cab\'
DECLARE @FileURL VARCHAR(100) = 'http://radar.kfh.co.uk/' + @Database + '/Interop/FileAccess.ashx?file='
DECLARE @GraphURL VARCHAR(100) = 'http://radar.kfh.co.uk/' + @Database + '/Interop/EPC/ViewEPC.aspx?'
DECLARE @UpdateEPCURL VARCHAR(100) = 'http://radar.kfh.co.uk/' + @Database + '/Presentation/Editors/Post.aspx?dialog=Radar_Property_Management&'
DECLARE @PropertyURL VARCHAR(100) = 'http://radar.kfh.co.uk/' + @Database + '/RadarProperty.aspx?'
DECLARE @PropertyMAURL VARCHAR(100) = 'http://radar.kfh.co.uk/' + @Database + '/Presentation/Property/MarketAppraisal.aspx?'
DECLARE @InstructionURL VARCHAR(100) = 'http://radar.kfh.co.uk/' + @Database + '/Presentation/Property/Instruction.aspx?'

IF (@pTenancyChk = 0)
BEGIN
/*
    Pull back Non terminated transactions
*/ 
	SELECT *
FROM(
	SELECT 
	[Due] = DATEDIFF(DAY, @RunDate, pcpld_End),
	[Check] = (
	CASE
	WHEN pcpld_End <= @RunDate + @DaysWarning + 1 THEN 'Y'
	ELSE 'N'
	END
	),
	[Reference] = COALESCE(pPropIN.ppin_Reference, pPropMA.ppma_Reference),
	[Property] = pProp.ppro_ID,
	[Region] = xGroup.xgrp_Name,
	[Branch] = xOffice.xof_Name, [Property Address] = REPLACE(REPLACE(pProp.ppro_MailAddr,'  ',' '),CHAR(13) + CHAR(10),', '),
	[Post Code] = pProp.ppro_PostCode,
	[Property Status] = COALESCE(CASE WHEN INStatus.xlib_Code = 'COM' THEN 'Let' ELSE INStatus.xlib_Desc END, MAStatus.xlib_Desc),
	[Tenancy Start] = Tenancy.paprt_TenancyStart,
	[Tenancy End] = Tenancy.paprt_TenancyEnd,
	[Tenancy Status] = CASE
					WHEN paprt_TenancyStatus = 'F' THEN 'Fixed'
					WHEN paprt_TenancyStatus = 'P' THEN 'Periodic'
					WHEN paprt_TenancyStatus = 'V' THEN 'Vacating'
					END,
	[Deal Status] = DLStatus.xlib_Desc,
	[First EPC Date] = pPropDRA.ppdra_EPCDate,
	pPropDRA.ppdra_EERCur, pPropDRA.ppdra_EERPot, pPropDRA.ppdra_EIRCur, pPropDRA.ppdra_EIRPot,
	[Compliance Type] = 'Energy Performance Certificate',
	pcpl_Due,
	pcpl_Notes,
	pcpld_Prop, pcpld_Media,
	pcpld_Start, pcpld_End,
	pcpld_Reference,
	pcpld_MostRecent,
	[EERC] = pcpld_Custom01, [EERP] = pcpld_Custom02, [EIRC] = pcpld_Custom03, [EIRP] = pcpld_Custom04,
	[EPC File] = (
	CASE WHEN XMED2.xmed_Source = 'Fixed' THEN XMED2.xmed_FixedPathHigh
	WHEN XMED2.xmed_Source = 'RADAR2012' THEN @FilePath + CONVERT(VARCHAR(4), YEAR(XMED2.xmed_DateCreated)) + '\' + CONVERT(VARCHAR(2), MONTH(XMED2.xmed_DateCreated))+ '\' + CONVERT(VARCHAR(36), XMED2.xmed_ID) + XMED2.xmed_FileExtention
	ELSE @FileURL + CONVERT(VARCHAR(36), XMED2.xmed_ID) + '&displayMode=4' 						
	END
	),
	[Graph File] = (
	CASE WHEN XMED3.xmed_Source = 'Fixed' THEN XMED3.xmed_FixedPathHigh
	WHEN XMED3.xmed_Source = 'RADAR2012' THEN @FilePath + CONVERT(VARCHAR(4), YEAR(XMED3.xmed_DateCreated)) + '\' + CONVERT(VARCHAR(2), MONTH(XMED3.xmed_DateCreated))+ '\' + CONVERT(VARCHAR(36), XMED3.xmed_ID) + XMED3.xmed_FileExtention
	ELSE @FileURL + CONVERT(VARCHAR(36), XMED3.xmed_ID) + '&displayMode=4' 						
	END
	),
	[Graph Generated] = (CASE WHEN pcpld_Custom05 IS NULL AND pcpld_Custom01 IS NOT NULL THEN 'Y' ELSE 'N' END),
	[Graph URL] = @GraphURL + 'eerc=' + CONVERT(VARCHAR, pcpld_Custom01) + '&eerp=' + CONVERT(VARCHAR, pcpld_Custom02) + '&eirc=' + CONVERT(VARCHAR, pcpld_Custom03) + '&eirp=' + CONVERT(VARCHAR, pcpld_Custom04),
	[Update EPC URL] = (CASE WHEN pPropIN.ppin_ID IS NOT NULL THEN @UpdateEPCURL + 'context=' + CONVERT(VARCHAR(36), pProp.ppro_ID) + '&mode=cpl' ELSE NULL END),
	[Radar URL] = (CASE WHEN pPropMA.ppma_Id IS NULL THEN @PropertyURL + 'idarm=' + CONVERT(VARCHAR(36), pProp.ppro_ID) WHEN pPropIN.ppin_ID IS NULL THEN @PropertyMAURL + 'appraisal=' + CONVERT(VARCHAR(36), pPropMA.ppma_Id) ELSE @InstructionURL + 'guid=' + CONVERT(VARCHAR(36), pProp.ppro_ID) + '&dept=RL' END),
	LLName = LLContact.xcnt_Name,
	LLEmail = LLComm.xcom_Email1,
	LLEmail2 = LLComm.xcom_Email2,
	INType = INType.pist_Desc
	FROM pPropStatus WITH (NOLOCK)
	-- property information
	INNER JOIN -- [1|1]
		pProp WITH (NOLOCK) ON pPropStatus.ppStatus_Property = pProp.ppro_ID
	INNER JOIN -- [1|1]
		pPropDRA WITH (NOLOCK) ON pPropDRA.ppdra_Prop = pProp.ppro_ID

	-- landlord
	INNER JOIN -- [1|1]
		pPropOwner WITH (NOLOCK) ON pPropOwner.ppown_Prop = pProp.ppro_ID AND pPropOwner.ppown_Current = 1
	INNER JOIN -- [1|1]
		xClient LLClient WITH (NOLOCK) ON LLClient.xcli_ID = pPropOwner.ppown_Client
	INNER JOIN -- [1|1]
		xContact LLContact WITH (NOLOCK) ON LLContact.xcnt_ID = LLClient.xcli_DefaultContact
	INNER JOIN -- [1|1]
		xComm LLComm WITH (NOLOCK) ON LLComm.xcom_Owner = LLContact.xcnt_ID
	-- appraisals and instructions
	INNER JOIN -- [1|?]
		pPropMA WITH (NOLOCK) ON pPropMa.ppma_Id = pPropStatus.ppStatus_MaId
	LEFT OUTER JOIN -- [1|?]
		pPropIN WITH (NOLOCK) ON pPropIN.ppin_ID = pPropStatus.ppStatus_InstructionLongLettings OR pPropIN.ppin_ID = pPropStatus.ppStatus_InstructionShortLettings
	LEFT OUTER JOIN
		pInstructionType INType WITH (NOLOCK) ON INType.pist_ID = pPropIN.ppin_InstructionType
	-- epc details
	LEFT OUTER JOIN -- [1|1]
		pPropCompliance WITH (NOLOCK) ON pPropCompliance.pcpl_Code = 'EPC' AND pPropCompliance.pcpl_Prop = pProp.ppro_ID
	LEFT OUTER JOIN -- [1|?]
		pPropComplianceDoc WITH (NOLOCK) ON pPropComplianceDoc.pcpld_Prop = pProp.ppro_ID AND pPropComplianceDoc.pcpld_Code = 'EPC'
LEFT OUTER JOIN
	xMedia XMED2 WITH (NOLOCK) ON XMED2.xmed_ID = pPropComplianceDoc.pcpld_Media
	LEFT OUTER JOIN
		xMedia XMED3 WITH (NOLOCK) ON XMED3.xmed_ID = pPropComplianceDoc.pcpld_Custom05	

	-- deal and tenancy details
	LEFT OUTER JOIN -- [1|?]
		pDeal WITH (NOLOCK) ON (pDeal.pde_Instruction = pPropStatus.ppStatus_InstructionLongLettings OR pDeal.pde_Instruction = pPropStatus.ppStatus_InstructionShortLettings) AND pde_Status = '824A3C56-4676-4E0E-B48D-1E144654A827' -- live tenancies
	
	--Use Function to Call Subset of Data
	OUTER APPLY (
		SELECT paprt_TenancyStart, paprt_TenancyEnd,paprt_TenancyStatus
		FROM pAprTenancy WITH (NOLOCK)
		WHERE pAprTenancy.paprt_Deal = pDeal.pde_ID
		--AND pAprTenancy.paprt_TenancyStatus != 'T'
	) Tenancy
	-- additional library information

	LEFT OUTER JOIN
		xLibrary INStatus WITH (NOLOCK) ON INStatus.xlib_ID = pPropIN.ppin_Status
	LEFT OUTER JOIN
		xLibrary MAStatus WITH (NOLOCK) ON MAStatus.xlib_ID = pPropStatus.ppStatus_MaLettingsStatus
	LEFT OUTER JOIN
		xLibrary DLStatus WITH (NOLOCK) ON DLStatus.xlib_ID = pDeal.pde_Status
	LEFT OUTER JOIN
		xOffice WITH (NOLOCK) ON xOffice.xof_Id = pPropDRA.ppdra_Office
	LEFT OUTER JOIN
		xGroupOffice WITH (NOLOCK) ON xGroupOffice.xgrpo_Office = xOffice.xof_Id 
	INNER JOIN
		xGroup WITH (NOLOCK) ON xGroup.xgrp_ID = xGroupOffice.xgrpo_Group
		AND xGroup.xgrp_Parent = '7B9C644F-0C55-412B-AA2E-7BBB812EF8B6'
			AND xGroup.xgrp_Name IN('Central','North & West','South East','South West')--@pRegionName
	WHERE pProp.ppro_Hidden = 0 
	AND pPropIN.ppin_Status != 'B29123EA-701A-4A9A-9B00-4E4AF2A9AED6' 
	AND Tenancy.paprt_TenancyStatus != 'T'
	)src
	WHERE src.[Check] = 'Y' 
	ORDER BY src.Region,src.Due

END
IF (@pTenancyChk = 1)
BEGIN
/*
    Pull back terminated transactions
*/ 
SELECT *
FROM(
	SELECT 
	[Due] = DATEDIFF(DAY, @RunDate, pcpld_End),
	[Check] = (
	CASE
	WHEN pcpld_End <= @RunDate + @DaysWarning + 1 THEN 'Y'
	ELSE 'N'
	END
	),
	[Reference] = COALESCE(pPropIN.ppin_Reference, pPropMA.ppma_Reference),
	[Property] = pProp.ppro_ID,
	[Region] = xGroup.xgrp_Name,
	[Branch] = xOffice.xof_Name, [Property Address] = REPLACE(REPLACE(pProp.ppro_MailAddr,'  ',' '),CHAR(13) + CHAR(10),', '),
	[Post Code] = pProp.ppro_PostCode,
	[Property Status] = COALESCE(CASE WHEN INStatus.xlib_Code = 'COM' THEN 'Let' ELSE INStatus.xlib_Desc END, MAStatus.xlib_Desc),
	[Tenancy Start] = Tenancy.paprt_TenancyStart,
	[Tenancy End] = Tenancy.paprt_TenancyEnd,
	[Tenancy Status] = 'Terminating',
	[Deal Status] = DLStatus.xlib_Desc,
	[First EPC Date] = pPropDRA.ppdra_EPCDate,
	pPropDRA.ppdra_EERCur, pPropDRA.ppdra_EERPot, pPropDRA.ppdra_EIRCur, pPropDRA.ppdra_EIRPot,
	[Compliance Type] = 'Energy Performance Certificate',
	pcpl_Due,
	pcpl_Notes,
	pcpld_Prop, pcpld_Media,
	pcpld_Start, pcpld_End,
	pcpld_Reference,
	pcpld_MostRecent,
	[EERC] = pcpld_Custom01, [EERP] = pcpld_Custom02, [EIRC] = pcpld_Custom03, [EIRP] = pcpld_Custom04,
	[EPC File] = (
	CASE WHEN XMED2.xmed_Source = 'Fixed' THEN XMED2.xmed_FixedPathHigh
	WHEN XMED2.xmed_Source = 'RADAR2012' THEN @FilePath + CONVERT(VARCHAR(4), YEAR(XMED2.xmed_DateCreated)) + '\' + CONVERT(VARCHAR(2), MONTH(XMED2.xmed_DateCreated))+ '\' + CONVERT(VARCHAR(36), XMED2.xmed_ID) + XMED2.xmed_FileExtention
	ELSE @FileURL + CONVERT(VARCHAR(36), XMED2.xmed_ID) + '&displayMode=4' 						
	END
	),
	[Graph File] = (
	CASE WHEN XMED3.xmed_Source = 'Fixed' THEN XMED3.xmed_FixedPathHigh
	WHEN XMED3.xmed_Source = 'RADAR2012' THEN @FilePath + CONVERT(VARCHAR(4), YEAR(XMED3.xmed_DateCreated)) + '\' + CONVERT(VARCHAR(2), MONTH(XMED3.xmed_DateCreated))+ '\' + CONVERT(VARCHAR(36), XMED3.xmed_ID) + XMED3.xmed_FileExtention
	ELSE @FileURL + CONVERT(VARCHAR(36), XMED3.xmed_ID) + '&displayMode=4' 						
	END
	),
	[Graph Generated] = (CASE WHEN pcpld_Custom05 IS NULL AND pcpld_Custom01 IS NOT NULL THEN 'Y' ELSE 'N' END),
	[Graph URL] = @GraphURL + 'eerc=' + CONVERT(VARCHAR, pcpld_Custom01) + '&eerp=' + CONVERT(VARCHAR, pcpld_Custom02) + '&eirc=' + CONVERT(VARCHAR, pcpld_Custom03) + '&eirp=' + CONVERT(VARCHAR, pcpld_Custom04),
	[Update EPC URL] = (CASE WHEN pPropIN.ppin_ID IS NOT NULL THEN @UpdateEPCURL + 'context=' + CONVERT(VARCHAR(36), pProp.ppro_ID) + '&mode=cpl' ELSE NULL END),
	[Radar URL] = (CASE WHEN pPropMA.ppma_Id IS NULL THEN @PropertyURL + 'idarm=' + CONVERT(VARCHAR(36), pProp.ppro_ID) WHEN pPropIN.ppin_ID IS NULL THEN @PropertyMAURL + 'appraisal=' + CONVERT(VARCHAR(36), pPropMA.ppma_Id) ELSE @InstructionURL + 'guid=' + CONVERT(VARCHAR(36), pProp.ppro_ID) + '&dept=RL' END),
	LLName = LLContact.xcnt_Name,
	LLEmail = LLComm.xcom_Email1,
	LLEmail2 = LLComm.xcom_Email2,
	INType = INType.pist_Desc
	FROM pPropStatus WITH (NOLOCK)
	-- property information
	INNER JOIN -- [1|1]
		pProp WITH (NOLOCK) ON pPropStatus.ppStatus_Property = pProp.ppro_ID
	INNER JOIN -- [1|1]
		pPropDRA WITH (NOLOCK) ON pPropDRA.ppdra_Prop = pProp.ppro_ID

	-- landlord
	INNER JOIN -- [1|1]
		pPropOwner WITH (NOLOCK) ON pPropOwner.ppown_Prop = pProp.ppro_ID AND pPropOwner.ppown_Current = 1
	INNER JOIN -- [1|1]
		xClient LLClient WITH (NOLOCK) ON LLClient.xcli_ID = pPropOwner.ppown_Client
	INNER JOIN -- [1|1]
		xContact LLContact WITH (NOLOCK) ON LLContact.xcnt_ID = LLClient.xcli_DefaultContact
	INNER JOIN -- [1|1]
		xComm LLComm WITH (NOLOCK) ON LLComm.xcom_Owner = LLContact.xcnt_ID
	-- appraisals and instructions
	INNER JOIN -- [1|?]
		pPropMA WITH (NOLOCK) ON pPropMa.ppma_Id = pPropStatus.ppStatus_MaId
	LEFT OUTER JOIN -- [1|?]
		pPropIN WITH (NOLOCK) ON pPropIN.ppin_ID = pPropStatus.ppStatus_InstructionLongLettings OR pPropIN.ppin_ID = pPropStatus.ppStatus_InstructionShortLettings
	LEFT OUTER JOIN
		pInstructionType INType WITH (NOLOCK) ON INType.pist_ID = pPropIN.ppin_InstructionType
	-- epc details
	LEFT OUTER JOIN -- [1|1]
		pPropCompliance WITH (NOLOCK) ON pPropCompliance.pcpl_Code = 'EPC' AND pPropCompliance.pcpl_Prop = pProp.ppro_ID
	LEFT OUTER JOIN -- [1|?]
		pPropComplianceDoc WITH (NOLOCK) ON pPropComplianceDoc.pcpld_Prop = pProp.ppro_ID AND pPropComplianceDoc.pcpld_Code = 'EPC'
LEFT OUTER JOIN
	xMedia XMED2 WITH (NOLOCK) ON XMED2.xmed_ID = pPropComplianceDoc.pcpld_Media
	LEFT OUTER JOIN
		xMedia XMED3 WITH (NOLOCK) ON XMED3.xmed_ID = pPropComplianceDoc.pcpld_Custom05	

	-- deal and tenancy details
	LEFT OUTER JOIN -- [1|?]
		pDeal WITH (NOLOCK) ON (pDeal.pde_Instruction = pPropStatus.ppStatus_InstructionLongLettings OR pDeal.pde_Instruction = pPropStatus.ppStatus_InstructionShortLettings) AND pde_Status = '824A3C56-4676-4E0E-B48D-1E144654A827' -- live tenancies
	
	--Use Function to Call Subset of Data
	OUTER APPLY (
		SELECT paprt_TenancyStart, paprt_TenancyEnd,paprt_TenancyStatus
		FROM pAprTenancy WITH (NOLOCK)
		WHERE pAprTenancy.paprt_Deal = pDeal.pde_ID
		AND pAprTenancy.paprt_TenancyStatus = 'T'
	) Tenancy
	-- additional library information

	LEFT OUTER JOIN
		xLibrary INStatus WITH (NOLOCK) ON INStatus.xlib_ID = pPropIN.ppin_Status
	LEFT OUTER JOIN
		xLibrary MAStatus WITH (NOLOCK) ON MAStatus.xlib_ID = pPropStatus.ppStatus_MaLettingsStatus
	LEFT OUTER JOIN
		xLibrary DLStatus WITH (NOLOCK) ON DLStatus.xlib_ID = pDeal.pde_Status
	LEFT OUTER JOIN
		xOffice WITH (NOLOCK) ON xOffice.xof_Id = pPropDRA.ppdra_Office
	LEFT OUTER JOIN
		xGroupOffice WITH (NOLOCK) ON xGroupOffice.xgrpo_Office = xOffice.xof_Id 
	INNER JOIN
		xGroup WITH (NOLOCK) ON xGroup.xgrp_ID = xGroupOffice.xgrpo_Group
		AND xGroup.xgrp_Parent = '7B9C644F-0C55-412B-AA2E-7BBB812EF8B6'
		AND xGroup.xgrp_Name IN('Central','North & West','South East','South West')--@pRegionName
	WHERE pProp.ppro_Hidden = 0 
	AND pPropIN.ppin_Status != 'B29123EA-701A-4A9A-9B00-4E4AF2A9AED6' 
	AND Tenancy.paprt_TenancyStatus = 'T'
	--AND DATEDIFF(DAY, @RunDate, pcpld_End) <= @DaysWarning
	--AND DATEDIFF(DAY, @RunDate, pcpld_End) IS NOT NULL -- Less than Search Date
	--AND pPropIN.ppin_Reference = 'P133831'

	)src
	WHERE src.[Check] = 'Y' 
	ORDER BY src.Region,src.Due


END



