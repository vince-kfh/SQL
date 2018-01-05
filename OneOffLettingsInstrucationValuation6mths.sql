/*
   Lettings Analysis

   POC = P124147

*/

--property Details
SELECT TOP 10 ppin_Reference,pPropIN.ppin_Prop,ppro_Unit,ppro_StreetNo,ppro_Street,ppro_District,ppro_Town,ppro_County,ppro_PostCode,A1Status.xlib_Desc
--pPropStatus.*
FROM pPropIN
INNER JOIN pProp on pProp.ppro_ID = pPropIN.ppin_Prop --and pProp.ppro_Hidden = 0
inner JOIN pPropStatus WITH (NOLOCK) ON pPropStatus.ppStatus_Property = pProp.ppro_ID
INNER JOIN pPropDRA on pPropDRA.ppdra_Prop = pProp.ppro_ID
INNER JOIN xLibrary A1Status WITH (NOLOCK) ON pPropIN.ppin_Status = A1Status.xlib_ID
--LandLord Details
WHERE pPropIN.ppin_Reference = 'P124147'


--Landlord Details
SELECT TOP 10 xadr_Unit,xadr_StreetNo,xadr_District,xadr_Town,xadr_Country,xadr_MailAddr,*
FROM pLandlord WITH (NOLOCK)
LEFT JOIN xClient WITH (NOLOCK) ON xClient.xcli_ID = pLandlord.pll_Client
LEFT JOIN xContact WITH (NOLOCK) ON xContact.xcnt_ID = xClient.xcli_DefaultContact
LEFT JOIN xComm WITH (NOLOCK) ON xContact.xcnt_ID = xComm.xcom_Owner
LEFT JOIN xAddressLink WITH (NOLOCK) ON xAddressLink.xadrl_Contact = xContact.xcnt_ID AND xAddressLink.xadrl_Type = 'A6F54051-F804-4E12-A3AC-0FDA48E8D1A6' AND xadrl_TypeIndex = 0
LEFT JOIN xAddress WITH (NOLOCK) ON xAddressLink.xadrl_Address = xAddress.xadr_ID
WHERE xadr_MailAddr LIKE '%86 Bedford Road%'

-- INNER JOIN xClientType WITH (NOLOCK) ON xClientType.xclt_Client = xClient.xcli_ID AND xClientType.xclt_Type = 'FE1ED5C2-FAE6-4574-8A58-34B85F9E4D34' -- LL:Landlord
SELECT TOP 1 *
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

	LEFT JOIN xClient WITH (NOLOCK) ON xClient.xcli_ID = pLandlord.pll_Client
LEFT JOIN xContact WITH (NOLOCK) ON xContact.xcnt_ID = xClient.xcli_DefaultContact
LEFT JOIN xComm WITH (NOLOCK) ON xContact.xcnt_ID = xComm.xcom_Owner
LEFT JOIN xAddressLink WITH (NOLOCK) ON xAddressLink.xadrl_Contact = xContact.xcnt_ID AND xAddressLink.xadrl_Type = 'A6F54051-F804-4E12-A3AC-0FDA48E8D1A6' AND xadrl_TypeIndex = 0
LEFT JOIN xAddress WITH (NOLOCK) ON xAddressLink.xadrl_Address = xAddress.xadr_ID