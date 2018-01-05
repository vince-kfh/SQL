
SELECT offer.propertyreference,dbo.OfferStatus.*,*
FROM Contact 
INNER JOIN ContactAddress ON Contact.ContactReference = ContactAddress.ContactReference AND Contact.PrimaryContact = ContactAddress.ContactNo
INNER JOIN Applicant on Contact.ContactReference = Applicant.ContactReference AND PrimaryApplicant = 1
INNER JOIN Financial on Contact.ContactReference = Financial.ContactReference
INNER JOIN dbo.Offer ON dbo.Contact.ContactReference = dbo.Offer.ApplicantReference 
INNER JOIN dbo.OfferStatus ON dbo.Offer.OfferStatus = dbo.OfferStatus.OfferStatus
--PropertyChain
INNER JOIN (SELECT property.PropertyReference
			FROM dbo.Property
			INNER JOIN dbo.PropertyStatus ON dbo.Property.PropertyStatus = dbo.PropertyStatus.Status
			INNER JOIN dbo.MarketAppraisal ON dbo.Property.PropertyReference = dbo.MarketAppraisal.PropertyReference
			where property.PropertyStatus IN(2,5,6,7) -- For sale | Under Offer | Exchanged
			AND dbo.MarketAppraisal.HalfCommission = 0
			) PropertyChain  ON Offer.PropertyReference = PropertyChain.PropertyReference
WHERE Contact.ContactReference = 2705359 AND dbo.Contact.Archived = 0
--Verification
AND IDVerified = 0
AND  Offer.OfferStatus IN (2,4) -- Accepted and Exchanged Not Completed


